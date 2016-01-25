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
    //THIS IS MAINLY FOR DISPLAY OTHER USERS PROFILE
    
    struct Options {
        static var followText = "Loading"
        static var hideFollowing = true
        static var username = PFUser.currentUser()?.username
        static var userId = PFUser.currentUser()?.objectId
        static var profileName = "Profile Name"
    }
    
    @IBOutlet weak var isFollowing: UIButton!
    @IBOutlet weak var followingNum: UIButton!
    @IBOutlet weak var followerNum: UIButton!
    
    @IBOutlet weak var profileUsername: UILabel!
    @IBOutlet weak var profileName: UILabel!

    @IBOutlet weak var profileView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true
        
        
        //profileView.frame.size.height = UITableViewAutomaticDimension
        //tableView.tableHeaderView = profileView //        
        //tableView.tableHeaderView?.frame.size.height = UITableViewAutomaticDimension
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        isFollowing.setTitle(Options.followText, forState: .Normal) //TODO: unwrap an optinal value?????
        isFollowing.enabled = false
        isFollowing.hidden = Options.hideFollowing
        if !isFollowing.hidden {
            ParseActions.isFollowingFollower([Options.userId!], withType: .Following) { (x) -> Void in
                self.isFollowing.enabled = true
                if x.first == true {
                    self.isFollowing.setTitle("Following", forState: .Normal)
                } else {
                    self.isFollowing.setTitle("Follow", forState: .Normal)
                }
                
            }
        }
        
        if let un = Options.username {
            profileUsername.text = "@" + un
        } else {
            profileUsername.text = ""
        }
        
        profileName.text = Options.profileName
        tabBarController?.navigationItem.title = profileName.text
        
        
        
        //tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Following", style: .Plain, target: self, action: "followingTapped")
        //let item = UIBarButtonItem(title: "Following", style: .Plain, target: self, action: "followingTapped")
        
        //if tabBarController?.navigationItem.rightBarButtonItems?.count > 0 {
        //    tabBarController?.navigationItem.rightBarButtonItems!.append(item)
        //} else {
        //    tabBarController?.navigationItem.rightBarButtonItems = [item]
        //}
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
    
    // show following followers
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
    
    @IBAction func followUnfollow(sender: UIButton) {
        guard let id = Options.userId else {return}
        guard let username = Options.username else {return}
        
        ParseActions.followUnfollow(sender, withID: id, andUsername: username)
    }
    
    
}
























