//
//  ProfileViewController.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/13/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationItem.title = "Profile"
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Following", style: .Plain, target: self, action: "followingTapped")
    }
    
    func followingTapped() {
        self.performSegueWithIdentifier("showFollowing", sender: self)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }

    
    //TODO: modify this
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showFollowing" {
            let vc = segue.destinationViewController as! FollowingFollowerVC
            
            // Parse
            
            let query = PFUser.query()
            query?.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
                if let users = objects {
                    for object in users {
                        if let user = object as? PFUser {
                            
                            if user.objectId! != PFUser.currentUser()?.objectId {
                                
                                vc.usernames.append(user.username!)
                                vc.userids.append(user.objectId!)
                                
                                let query = PFQuery(className: "activity")
                                
                                query.whereKey("type", equalTo: "following")
                                query.whereKey("fromUser", equalTo: PFUser.currentUser()!.objectId!)
                                query.whereKey("toUser", equalTo: user.objectId!)
                                
                                query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                                    
                                    if let objects = objects {
                                        
                                        if objects.count > 0 {
                                            
                                            vc.isFollowing[user.objectId!] = true
                                            
                                        } else {
                                            
                                            vc.isFollowing[user.objectId!] = false
                                            
                                        }
                                    }
                                    
                                    if vc.isFollowing.count == vc.usernames.count {
                                        vc.tableView.reloadData()
                                    }
                                    
                                    
                                })
                                
                                
                                
                            }
                        }
                        
                    }
                    
                    
                    
                }
                
                
                
            }
            
        }
    }
    
}
























