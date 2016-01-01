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

class EpisodeInParse: NSObject {
    var episodeTitle: String?
    var episodeURL: NSURL?
    var imageSets: [PFFile]?
    var sectionDurations: [Float]?
}

class ChannelFeed {
    var username: String?
    var userThumb: UIImage?
    var episodes: [EpisodeInParse] = []
}

class HomeFeedFromParse: NSObject {
    var channels: [ChannelFeed] = []
    
    
    init(withItems items: [AnyObject], toNewAudio: String = "combined.m4a") {
        super.init()
        
    }
    
    
    
    func fetchFollowingPosts(skip: Int = 0) {
        let query = PFQuery(className: "Activities")
        query.whereKey("fromUser", equalTo: PFUser.currentUser()!)
        query.whereKey("type", equalTo: "following")
        query.orderByDescending("postUpdatedAt")
        query.skip = skip
        query.limit = 6
        query.findObjectsInBackgroundWithBlock { (us, error) in
            // While normally there should only be one follow activity returned, we can't guarantee that.
            if (us == nil) || (error != nil) {
                return
            }
            
            for u: PFObject in us! as [PFObject] {
                
                let ch = ChannelFeed()
                ch.username = u["toUsername"] as? String
                
                let q = PFQuery(className: "Episode")
                q.whereKey("userId", equalTo: u["toUser"])
                q.orderByDescending("UpdatedAt")
                q.limit = 3
                q.findObjectsInBackgroundWithBlock{ (posts, error) in
                    if posts == nil {
                        //AppUtils.displayAlert("Fetching Feed Failed", message: "Please try again later", onViewController: (self as? UIViewController)!)
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
                        ch.episodes.append(e)
                    }
                    
                    self.channels.append(ch)
                }
                
                
                
                
                
                
                
            }
        }
        
    }
    
    
    
    
    
    
    
}