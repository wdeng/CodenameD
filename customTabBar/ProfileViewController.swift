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
    
    @IBOutlet weak var isFollowing: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationItem.title = "Profile"
        
        //tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Following", style: .Plain, target: self, action: "followingTapped")
        //let item = UIBarButtonItem(title: "Following", style: .Plain, target: self, action: "followingTapped")
        
        //if tabBarController?.navigationItem.rightBarButtonItems?.count > 0 {
        //    tabBarController?.navigationItem.rightBarButtonItems!.append(item)
        //} else {
        //    tabBarController?.navigationItem.rightBarButtonItems = [item]
        //}
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if tabBarController?.navigationItem.rightBarButtonItems?.count > 1 {
            tabBarController?.navigationItem.rightBarButtonItems?.removeLast()
        }
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
        let vc = segue.destinationViewController as! FollowingFollowerVC
        if segue.identifier == "showFollowing" {
            let query = PFQuery(className: "Activities")
            query.whereKey("type", equalTo: "following")
            query.whereKey("fromUser", equalTo: PFUser.currentUser()!.objectId!)
            query.limit = 100
            
            query.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
                if error != nil {
                    print("couldn't fetch users")
                    return
                }
                
                guard let followings = objects else {return}
                
                for following in followings {
                    let id = following["toUser"] as! String
                    vc.userids.append(id)
                    vc.usernames.append(following["toUsername"] as! String)
                    vc.isFollowing[id] = true
                }
                vc.tableView.reloadData()
            }
            
        } else if segue.identifier == "showFollowers" {
            
            ParseActions.fetchActivities(.Followers, finished: { (followings: [PFObject]) -> Void in
                for following in followings {
                    let id = following["fromUser"] as! String
                    vc.userids.append(id)
                    vc.usernames.append(following["fromUsername"] as! String)
                    vc.isFollowing[id] = false
                }
                vc.tableView.reloadData()
            })
            
        }
    }
    
}
























