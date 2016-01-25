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

class EpisodeToPlay {
    var episodeTitle: String?
    var episodeURL: NSURL?
    var imageSets: [[AnyObject]] = []
    var thumb: AnyObject?
    var sectionDurations: [Double] = []
}

class ChannelFeed {
    var username: String?
    var userThumb: PFFile?
    var userId: String?
    var episodes: [EpisodeToPlay] = []
}

enum LoadType {
    case AddOn
    case Reload
}

class HomeFeedFromParse: NSObject {
    var channels: [ChannelFeed] = []
    
    
//    init(withItems items: [AnyObject], toNewAudio: String = "combined.m4a") {
//        super.init()
//        
//    }
    
    
    
    class func fetchFollowingPosts(skip: Int, size: Int = HomeFeedsSettings.sectionsInPage, finished:([ChannelFeed]) -> Void ) {
        var feeds = [ChannelFeed]()
        
        let query = PFQuery(className: "Activities")
        query.whereKey("fromUser", equalTo: PFUser.currentUser()!.objectId!)
        query.whereKey("type", equalTo: "following")
        query.orderByDescending("updatedAt")
        query.skip = skip
        query.limit = size
        query.findObjectsInBackgroundWithBlock { (users, error) in
            if (error != nil) {
                print("couldn't find following users")
                return
            }
            //TODO: if us is []
            guard let us = users else {return}
            if us.count == 0{
                finished(feeds)
            }
            
            var counter = 0
            
            for u: PFObject in us as [PFObject] {
                let ch = ChannelFeed()
                
                ch.username = u["toUsername"] as? String
                ch.userThumb = u["thumb"] as? PFFile
                ch.userId = u["toUser"] as? String
                
                feeds.append(ch)
                let q = PFQuery(className: "Episode")
                q.whereKey("userId", equalTo: u["toUser"])
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
                        
                        //print("Title: \(e.episodeTitle), url: \(e.episodeURL), image: \(e.imageSets)")
                        ch.episodes.append(e)
                    }
                     // shouldn't only be like this, doesn't load this one when all feeds loaded, us is []
                    if (++counter) == us.count {
                        finished(feeds)
                    }
                }
                
            }
        }
        
    }
    
    
    
    
    
    
}




















