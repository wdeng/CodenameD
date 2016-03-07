//
//  AudioInParse.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/24/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import Foundation
import AVFoundation
import Parse

class EpisodeToPlay: NSObject, NSCoding {
    var episodeTitle: String?
    var episodeURL: NSURL?
    var imageSets: [[AnyObject]] = []
    var thumb: AnyObject?
    var sectionDurations: [Double] = []
    var episodeId: String?
    var authorId: String?
    var uploadDate: NSDate?
    
    struct Keys {
        static let title = "title"
        static let url = "url"
        static let imsets = "imagesets"
        static let thumb = "thumb"
        static let durs = "durations"
        static let id = "id"
    }
    
    // MARK: - NSCoding
    
    func encodeWithCoder(archiver: NSCoder) {
        archiver.encodeObject(episodeTitle, forKey: Keys.title)
        archiver.encodeObject(episodeURL, forKey: Keys.url)
        archiver.encodeObject(sectionDurations, forKey: Keys.durs)
        if let thumbData = thumb as? NSData {
            archiver.encodeObject(thumbData, forKey: Keys.thumb)
            archiver.encodeObject(imageSets, forKey: Keys.imsets)
        }
        else {
            archiver.encodeObject(episodeId, forKey: Keys.id)
        }
        
    }
    
    override init() {
        super.init()
    }
    
    required init(coder unarchiver: NSCoder) {
        super.init()
        // Unarchive the data, one property at a time
        episodeTitle = unarchiver.decodeObjectForKey(Keys.title) as? String
        episodeURL = unarchiver.decodeObjectForKey(Keys.url) as? NSURL
        sectionDurations = (unarchiver.decodeObjectForKey(Keys.durs) as? [Double]) ?? []
        if let thumbData = unarchiver.decodeObjectForKey(Keys.thumb) as? NSData {
            imageSets = (unarchiver.decodeObjectForKey(Keys.imsets) as? [[AnyObject]]) ?? []
            thumb = thumbData
        } else {
            episodeId = unarchiver.decodeObjectForKey(Keys.id) as? String
        }
        
    }
    
    
}

class ChannelFeed {
    //var username: String?
    //var userThumb: PFFile?
    //var userId: String?
    var episodes: [EpisodeToPlay] = []
    var user: PFUser?
}

class HomeFeedFromParse: NSObject {
    var channels: [ChannelFeed] = []
    
    class func fetchProfilePosts(forUserID userId: String, skip: Int, size: Int = HomeFeedsSettings.sectionsInPage, finished:([EpisodeToPlay]) -> Void ) {
        
        var feeds = [EpisodeToPlay]()
        
        let q = PFQuery(className: "Episode")
        q.whereKey("userId", equalTo: userId)
        q.orderByDescending("updatedAt")
        q.limit = HomeFeedsSettings.itemsInSection
        q.findObjectsInBackgroundWithBlock{ (posts, error) in
            if error != nil {
                print("couldn't fetch episodes")
                return
            }
            
            for p in posts! {
                let e = EpisodeToPlay()
                if let urlString = (p["audio"] as? PFFile)?.url {
                    e.episodeURL = NSURL(string: urlString)
                }
                e.episodeTitle = p["title"] as? String
                e.thumb = p["thumb"]
                e.imageSets = (p["images"] as? [[AnyObject]]) ?? []
                e.sectionDurations = (p["durations"] as? [Double]) ?? []
                e.episodeId = p.objectId
                e.authorId = userId
                
                feeds.append(e)
            }
            
            finished(feeds)
        }
        
    }
    
    
    
    class func fetchFollowingPosts(skip: Int, size: Int = HomeFeedsSettings.sectionsInPage, finished:([ChannelFeed]) -> Void ) {
        
        guard let id = PFUser.currentUser()?.objectId else { return}
        
        var feeds = [ChannelFeed]()
        
        var errorMessage = "Please try again later"
        
        guard let queryA = PFUser.query() else {return}
        let queryB = PFQuery(className: "Activities")
        queryB.whereKey("fromUser", equalTo: id)
        queryB.whereKey("type", equalTo: "following")
        
        queryA.whereKey("objectId", matchesKey: "toUser", inQuery: queryB)
        queryA.skip = skip
        queryA.limit = size
        queryA.orderByDescending("postUpdatedAt")
        queryA.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
            if error != nil {
                if let errorString = error!.userInfo["error"] as? String {
                    errorMessage = errorString
                }
                debugPrint("couldn't find following users, \(errorMessage)")
                return
            }
            
            guard let users = objects else {return}
            if users.count == 0 {
                finished(feeds)
            }
            
            var counter = 0
            
            for object in users {
                guard let u = object as? PFUser else {return}
                
                let ch = ChannelFeed()
                //ch.username = (u["profileName"] as? String) ?? u.username
                //ch.userThumb = u["userThumb"] as? PFFile
                //ch.userId = u.objectId
                ch.user = u
                
                feeds.append(ch)
                
                let q = PFQuery(className: "Episode")
                q.whereKey("userId", equalTo: u.objectId!)
                q.orderByDescending("updatedAt")
                q.limit = HomeFeedsSettings.itemsInSection
                q.findObjectsInBackgroundWithBlock{ (posts, error) in
                    if error != nil {
                        print("couldn't fetch home")
                        return
                    }
                    
                    for p in posts! {
                        let e = EpisodeToPlay()
                        if let urlString = (p["audio"] as? PFFile)?.url {
                            e.episodeURL = NSURL(string: urlString)
                        }
                        e.episodeTitle = p["title"] as? String
                        e.thumb = p["thumb"]
                        e.imageSets = (p["images"] as? [[AnyObject]]) ?? []
                        e.sectionDurations = (p["durations"] as? [Double]) ?? []
                        e.episodeId = p.objectId
                        e.uploadDate = p.updatedAt
                        e.authorId = u.objectId
                        
                        ch.episodes.append(e)
                    }
                    // shouldn't only be like this, doesn't load this one when all feeds loaded, us is []
                    if (++counter) == users.count {
                        finished(feeds)
                    }
                }
                
                
            }
        }
        
        
        
//        let query = PFQuery(className: "Activities")
//        query.whereKey("fromUser", equalTo: PFUser.currentUser()!.objectId!)
//        query.whereKey("type", equalTo: "following")
//        query.orderByDescending("updatedAt")
//        query.skip = skip
//        query.limit = size
//        query.findObjectsInBackgroundWithBlock { (users, error) in
//            //print(users)
//            if (error != nil) {
//                print("couldn't find following users")
//                return
//            }
//            //TODO: if us is []
//            guard let us = users else {return}
//            if us.count == 0{
//                finished(feeds)
//            }
//            
//            var counter = 0
//            
//            for u: PFObject in us as [PFObject] {
//                let ch = ChannelFeed()
//                
//                ch.username = u["toUsername"] as? String
//                ch.userThumb = u["thumb"] as? PFFile
//                ch.userId = u["toUser"] as? String
//                
//                feeds.append(ch)
//                let q = PFQuery(className: "Episode")
//                q.whereKey("userId", equalTo: u["toUser"])
//                q.orderByDescending("updatedAt")
//                q.limit = HomeFeedsSettings.itemsInSection
//                q.findObjectsInBackgroundWithBlock{ (posts, error) in
//                    if error != nil {
//                        print("couldn't fetch home")
//                        return
//                    }
//                    
//                    for p in posts! {
//                        let e = EpisodeToPlay()
//                        if let urlString = (p["audio"] as? PFFile)?.url {
//                            e.episodeURL = NSURL(string: urlString)
//                        }
//                        e.episodeTitle = p["title"] as? String
//                        e.thumb = p["thumb"]
//                        e.imageSets = (p["images"] as? [[AnyObject]]) ?? []
//                        e.sectionDurations = (p["durations"] as? [Double]) ?? []
//                        e.episodeId = p.objectId
//                        
//                        //print("Title: \(e.episodeTitle), url: \(e.episodeURL), image: \(e.imageSets)")
//                        ch.episodes.append(e)
//                    }
//                    // shouldn't only be like this, doesn't load this one when all feeds loaded, us is []
//                    if (++counter) == us.count {
//                        finished(feeds)
//                    }
//                }
//                
//            }
//        }
        
    }
    
    
}




















