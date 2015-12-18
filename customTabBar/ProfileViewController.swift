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

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showFollowing" {
            let vc = segue.destinationViewController as! FollowingFollowerVC
            
            
            guard let queryA = PFUser.query() else {return}
            let queryB = PFQuery(className: "activity")
            
            queryB.whereKey("fromUser", equalTo: PFUser.currentUser()!.objectId!)
            queryB.whereKey("type", equalTo: "following")
            queryA.whereKey("objectId", matchesKey: "toUser", inQuery: queryB)
            
            
            queryA.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
                if error != nil {
                    print("couldn't fetch users")
                    return
                }
                
                guard let users = objects else {return}
                
                for object in users {
                    guard let u = object as? PFUser else {return}
                    //if u.objectId! == PFUser.currentUser()?.objectId {continue}
                    vc.userids.append(u.objectId!)
                    vc.usernames.append(u.username!)
                    vc.isFollowing[u.objectId!] = true
                }
                vc.tableView.reloadData()
            }
            
        }
    }
    
}
























