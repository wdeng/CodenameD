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
    let appendS = (number == 1) ? "" : "s"
    //photoCountLabel.text = "\(number) photo\(appendS)"
    //PAPCache.sharedCache.setPhotoCount(Int(number), user: self.user!)
    }
    }
    
    
    
    
    
    
    
    let query = PFQuery(className: "activity")
    query.whereKey("photo", equalTo: PFObject())//self.photo!)   //PFObject
    query.includeKey("fromUser")
    query.whereKey("type", equalTo: "comment")
    query.orderByAscending("createdAt")
    
    
    
    }
    
    
    class func unfollowUserEventually(user: PFUser) {
        let query = PFQuery(className: "activity")
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
}
































