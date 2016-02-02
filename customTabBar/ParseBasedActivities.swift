//
//  ParseActivities.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/15/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import Parse

enum ActivityType {
    case Following
    case Followers
    case Comment
    case Like
    case Dislike
}

class ParseActions: NSObject {
    //func signUpLogin(isSignUp: Bool, withUsername username: String, andPassword password: String) {}
    
    class func fetchImages(names: [AnyObject], finished: ([AnyObject]) -> Void) {
        var imagesData: [NSData] = []
        
        let queue = dispatch_queue_create("com.customtabbar.getimages", DISPATCH_QUEUE_SERIAL)
        
        if let names = names as? [PFFile] {
            for fileName in names {
                //TODO: should check if images are correct sequence
                dispatch_async(queue){
                    do {
                        let data = try fileName.getData()
                        imagesData.append(data)
                    } catch _ {}
                }
            }
            dispatch_async(queue){
                dispatch_async(dispatch_get_main_queue()){
                    finished(imagesData)
                }
            }
        } else if let data = names as? [NSData] {
            finished(data)
        } else if let images = names as? [UIImage] {
            finished(images)
        }
        
    }
    
    // Find followers, following, comments, and likes
    class func fetchActivities(type: ActivityType, finished:([PFObject]) -> Void ) {
        let query = PFQuery(className: "Activities")
        switch type {
        case .Followers:
            query.whereKey("type", equalTo: "following")
            query.whereKey("toUser", equalTo: PFUser.currentUser()!.objectId!)
        case .Following:
            query.whereKey("type", equalTo: "following")
            query.whereKey("fromUser", equalTo: PFUser.currentUser()!.objectId!)
        default:
            return
        }
        query.limit = 100
        
        query.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
            if error != nil {
                print("couldn't fetch Activities")
                return
            }
            
            // pass the objects to block
            guard let objects = objects else {return}
            finished(objects)
        }
        
    }
    
    class func isFollowingFollower(userIds: [String]?, withType type: ActivityType, finished:([Bool]) -> Void ) {
        var isFollowing = [Bool]()
        guard let checkingUsers = userIds else {return}
        var typeToCheck = "toUser"
        
        let query = PFQuery(className: "Activities")
        query.whereKey("type", equalTo: "following")
        switch type {
        case .Followers:
            query.whereKey("fromUser", containedIn: checkingUsers)
            query.whereKey("toUser", equalTo: PFUser.currentUser()!.objectId!)
            typeToCheck = "fromUser"
        case .Following:
            query.whereKey("fromUser", equalTo: PFUser.currentUser()!.objectId!)
            query.whereKey("toUser", containedIn: checkingUsers)
        default:
            return
        }
        
        
        query.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
            if error != nil {
                print("couldn't fetch Activities")
                return
            }
            
            // pass the objects to block
            guard let obs = objects else {return}
            var users = [String]()
            for u in obs {
                users.append(u[typeToCheck] as! String)
            }

            for u in checkingUsers {
                if users.contains(u) {
                    isFollowing.append(true)
                } else {
                    isFollowing.append(false)
                }
            }
            
            finished(isFollowing)
        }
        
    }
    class func fetchFollowingFollowerNumber(type: ActivityType, finished:(Int) -> Void ) {
        let query = PFQuery(className: "Activities")
        switch type {
        case .Followers:
            query.whereKey("type", equalTo: "following")
            query.whereKey("toUser", equalTo: PFUser.currentUser()!.objectId!)
        case .Following:
            query.whereKey("type", equalTo: "following")
            query.whereKey("fromUser", equalTo: PFUser.currentUser()!.objectId!)
        default:
            return
        }
        query.limit = 1000
        query.countObjectsInBackgroundWithBlock { (count, error) -> Void in
            if error != nil {
                print("couldn't fetch Activities")
                return
            }
            
            finished(Int(count))
            
        }
        
    }
    
    class func followUnfollow(b: UIButton, withID id: String, andUsername username: String) {
        if b.titleLabel?.text == "Following" {
            b.setTitle("Follow", forState: .Normal)
            
            let query = PFQuery(className: "Activities")
            query.whereKey("type", equalTo: "following")
            query.whereKey("fromUser", equalTo: PFUser.currentUser()!.objectId!)
            query.whereKey("toUser", equalTo: id)
            
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if let objects = objects {
                    for object in objects {
                        object.deleteInBackground()
                    }
                }
            })
            
        } else {
            b.setTitle("Following", forState: .Normal)
            
            let following = PFObject(className: "Activities")
            following["type"] = "following"
            following["fromUser"] = PFUser.currentUser()?.objectId
            following["fromUsername"] = PFUser.currentUser()?.username
            following["toUser"] = id
            following["toUsername"] = username
            
            //TODO: change to NSDate
            //following["postUpdatedAt"] = nil
            following.saveInBackground()
        }
    }
    
    
    
    
    // Down below are recycled
    
    func tmp() {
        //photoCountLabel.text = "0 photos"
        
        let queryPhotoCount = PFQuery(className: "Photo")
        queryPhotoCount.whereKey("user", equalTo: PFUser.currentUser()!.objectId!)
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
        query.whereKey("fromUser", equalTo: PFUser.currentUser()!.objectId!)
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
































