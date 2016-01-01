//
//  ParseActivities.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/15/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import Parse

class ParseActions: NSObject {
    //func signUpLogin(isSignUp: Bool, withUsername username: String, andPassword password: String) {}
    
    func addActivityInParse(type: String, isRepeatable: Bool) {
        
        
        
    }
    
    
    func tmp() {
    //photoCountLabel.text = "0 photos"
    
    let queryPhotoCount = PFQuery(className: "Photo")
    queryPhotoCount.whereKey("user", equalTo: PFUser.currentUser()!)
    queryPhotoCount.cachePolicy = PFCachePolicy.CacheThenNetwork
    queryPhotoCount.countObjectsInBackgroundWithBlock { (number, error) in
    if error == nil {
    //let appendS = (number == 1) ? "" : "s"
    //photoCountLabel.text = "\(number) photo\(appendS)"
    //PAPCache.sharedCache.setPhotoCount(Int(number), user: self.user!)
    }
    }
    
    
    
    
    
    
    
    let query = PFQuery(className: "Activities")
    query.whereKey("photo", equalTo: PFObject())//self.photo!)   //PFObject
    query.includeKey("fromUser")
    query.whereKey("type", equalTo: "comment")
    query.orderByAscending("createdAt")
        
        
        
    // PFUser query
        
    let queryA = PFUser.query()
    let queryB = PFQuery(className: "Activities")
    
    queryB.whereKey("fromUser", equalTo: PFUser.currentUser()!.objectId!)
    queryB.whereKey("type", equalTo: "following")
    queryA!.whereKey("objectId", doesNotMatchKey: "toUser", inQuery: queryB)
    
    
    }
    
    
    class func unfollowUserEventually(user: PFUser) {
        let query = PFQuery(className: "Activities")
        query.whereKey("fromUser", equalTo: PFUser.currentUser()!)
        query.whereKey("toUser", equalTo: user)
        query.whereKey("type", equalTo: "following")
        query.findObjectsInBackgroundWithBlock { (followActivities, error) in
            // While normally there should only be one follow activity returned, we can't guarantee that.
            if error == nil {
                for followActivity: PFObject in followActivities! as [PFObject] {
                    followActivity.deleteEventually()
                }
            }
        }
        //TODO: cache thing sometime in the future
        //PAPCache.sharedCache.setFollowStatus(false, user: user)
    }
    
    
    
    
    // Abandoned
    var episode = EpisodeInParse()
    func fetchFollowingPosts(skip: Int = 0) {
        let query = PFQuery(className: "Activities")
        query.whereKey("fromUser", equalTo: PFUser.currentUser()!)
        query.whereKey("type", equalTo: "following")
        query.orderByDescending("postUpdatedAt")
        query.skip = skip
        query.limit = 6
        query.findObjectsInBackgroundWithBlock { (users, error) in
            // While normally there should only be one follow activity returned, we can't guarantee that.
            if error == nil {
                for u: PFObject in users! as [PFObject] {
                    
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
                        
                    }
                    
                }
            }
        }

    }
    
    
    
}
































