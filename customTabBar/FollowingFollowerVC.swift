//
//  FollowingFollowerVC.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/13/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import Parse

class FollowingFollowerVC: UITableViewController {
    
    var usernames = [String]()
    var userids = [String]()
    var isFollowing = [String: Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("followCell", forIndexPath: indexPath) as! FollowCell
        
        cell.textLabel?.text = usernames[indexPath.row]
        let followedObjectID = userids[indexPath.row]
        
        cell.isFollowing.tag = indexPath.row
        cell.isFollowing.addTarget(self, action: "followUnfollow:", forControlEvents: .TouchUpInside)
        if isFollowing[followedObjectID] == true {
            cell.isFollowing.setTitle("Following", forState: .Normal)
        } else {
            cell.isFollowing.setTitle("Follow", forState: .Normal)
        }
        
        return cell
    }
    
    func followUnfollow(b: UIButton) {
        let id = userids[b.tag]
        if b.titleLabel?.text == "Following" {
            b.setTitle("Follow", forState: .Normal)
            isFollowing[id] = false
            
            //Parse
            let query = PFQuery(className: "followers")
            query.whereKey("follower", equalTo: PFUser.currentUser()!.objectId!)
            query.whereKey("follower", equalTo: userids[b.tag])
            
            query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                if let objects = objects {
                    for object in objects {
                        object.deleteInBackground()
                    }
                }
            })
            //End Parse
        } else {
            b.setTitle("Following", forState: .Normal)
            isFollowing[id] = true
            
            //Parse
            
            
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
