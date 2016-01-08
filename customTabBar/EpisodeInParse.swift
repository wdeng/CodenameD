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

class EpisodeInParse {
    var episodeTitle: String?
    var episodeURL: NSURL?
    var imageSets: [PFFile]?
    var thumb: UIImage?
    var sectionDurations: [Float]?
}

class ChannelFeed {
    var username: String?
    var userThumb: UIImage?
    var episodes: [EpisodeInParse] = []
}

class HomeFeedFromParse: NSObject {
    var channels: [ChannelFeed] = []
    
    
//    init(withItems items: [AnyObject], toNewAudio: String = "combined.m4a") {
//        super.init()
//        
//    }
    
    
    
    class func fetchFollowingPosts(skip: Int, size: Int, finished:([ChannelFeed]) -> Void ) {
        var feeds = [ChannelFeed]()
        
        let query = PFQuery(className: "Activities")
        query.whereKey("fromUser", equalTo: PFUser.currentUser()!.objectId!)
        query.whereKey("type", equalTo: "following")
        query.orderByDescending("updatedAt")
        query.skip = skip
        query.limit = size
        query.findObjectsInBackgroundWithBlock { (us, error) in
            if (error != nil) {
                print("couldn't find following users")
                return
            }
            
            guard let us = us else {return}
            // TODO: if channel 
//            var following = [String]()
//            for u in us {
//                if let userId = u["toUser"] as? String {
//                    following.append(userId)
//                }
//            }
//            let q = PFQuery(className: "Episode")
//            q.whereKey("userId", containedIn: following)
//            q.orderByDescending("updatedAt")
            
            
            
            for u: PFObject in us as [PFObject] {
                
                let ch = ChannelFeed()
                ch.username = u["toUsername"] as? String
                
                let q = PFQuery(className: "Episode")
                q.whereKey("userId", equalTo: u["toUser"])
                q.orderByDescending("updatedAt")
                q.limit = 3
                q.findObjectsInBackgroundWithBlock{ (posts, error) in
                    if error != nil {
                        print("couldn't fetch home")
                        return
                    }
                    
                    for p in posts! {
                        let e = EpisodeInParse()
                        if let urlString = (p["audio"] as? PFFile)?.url {
                            e.episodeURL = NSURL(string: urlString)
                        }
                        e.episodeTitle = p["title"] as? String
                        e.imageSets = p["images"] as? [PFFile]
                        print("Title: \(e.episodeTitle), url: \(e.episodeURL), image: \(e.imageSets)")
                        ch.episodes.append(e)
                    }
                    
                    feeds.append(ch)
                    
                    if feeds.count == us.count {
                        finished(feeds)
                    }
                }
                
                
                
            }
        }
    }
    
    
    
    
    
    
    
}




















