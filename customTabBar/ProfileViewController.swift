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
    
    var options: [String : AnyObject?]!
    
    
    //TODO: change this to something else
    func setupProfile(withOptions options: [String: AnyObject?]) {
        profileView.setupProfile(withOptions: options)
        tabBarController?.navigationItem.title = profileView.profileName.text
    }
    
    @IBOutlet weak var profileView: ProfileHeaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProfile(withOptions: options)
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let headerView = tableView.tableHeaderView!
        let maxSize = CGSize(width: UIScreen.mainScreen().bounds.width - 24.0, height: CGFloat.max)
        let userLinkHeight = profileView.userLink.titleForState(.Normal)?.characters.count > 0 ? profileView.userLink.sizeThatFits(maxSize).height : 0
        headerView.frame.size.height = 148 + profileView.userIntro.sizeThatFits(maxSize).height + userLinkHeight
        
        tableView.tableHeaderView = headerView // everytime this was called, layout subviews will be called
        
        
        //tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Following", style: .Plain, target: self, action: "followingTapped")
        //let item = UIBarButtonItem(title: "Following", style: .Plain, target: self, action: "followingTapped")
        
        //if tabBarController?.navigationItem.rightBarButtonItems?.count > 0 {
        //    tabBarController?.navigationItem.rightBarButtonItems!.append(item)
        //} else {
        //    tabBarController?.navigationItem.rightBarButtonItems = [item]
        //}
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 20
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("episodeCell", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath)
    }
    
    // show following followers
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "editProfile" {
            if profileView.isFollowing.titleLabel?.text == "Edit Profile" {return true}
            else {return false}
        }
        else {
            return super.shouldPerformSegueWithIdentifier(identifier, sender: sender)
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //let vc = segue.destinationViewController as! FollowingFollowerVC
        guard let userID = options[UserProfileKeys.UserID] as? String else {return}
        if segue.identifier == "showFollowing" || segue.identifier == "showFollowers" {
            
            let actiType = segue.identifier == "showFollowing" ? ActivityType.Following : ActivityType.Followers
            
            let vc = segue.destinationViewController as! FollowingFollowerVC
            
            ParseActions.fetchActivities(actiType, forUserID: userID, finished: { (followings: [PFObject]) -> Void in
                
                if actiType == .Following {
                    for following in followings {
                        let id = following["toUser"] as! String
                        vc.userids.append(id)
                        vc.usernames.append(following["toUsername"] as! String)
                        vc.isFollowing[id] = true
                        vc.navigationItem.title = "Following"
                    }
                } else {
                    for following in followings {
                        let id = following["fromUser"] as! String
                        vc.userids.append(id)
                        vc.usernames.append(following["fromUsername"] as! String)
                        vc.isFollowing[id] = false
                        vc.navigationItem.title = "Followers"
                    }
                }
                
                vc.tableView.reloadData()
            })
            
        }
        
        
//        if segue.identifier == "showFollowing" {
//            let query = PFQuery(className: "Activities")
//            query.whereKey("type", equalTo: "following")
//            query.whereKey("fromUser", equalTo: PFUser.currentUser()!.objectId!)
//            query.limit = 100
//            
//            query.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
//                if error != nil {
//                    print("couldn't fetch users")
//                    return
//                }
//                
//                guard let followings = objects else {return}
//                
//                for following in followings {
//                    let id = following["toUser"] as! String
//                    vc.userids.append(id)
//                    vc.usernames.append(following["toUsername"] as! String)
//                    vc.isFollowing[id] = true
//                }
//                vc.tableView.reloadData()
//            }
//            
//        } else if segue.identifier == "showFollowers" {
//            
//            ParseActions.fetchActivities(.Followers, finished: { (followings: [PFObject]) -> Void in
//                for following in followings {
//                    let id = following["fromUser"] as! String
//                    vc.userids.append(id)
//                    vc.usernames.append(following["fromUsername"] as! String)
//                    vc.isFollowing[id] = false
//                }
//                vc.tableView.reloadData()
//            })
//            
//        }
    }
    
    @IBAction func followUnfollow(sender: UIButton) {
        let title = sender.titleLabel?.text?.lowercaseString
        guard let id = options[UserProfileKeys.UserID] as? String else {return}
        guard let username = options[UserProfileKeys.Username] as? String else {return}
        if (title == "following") || (title == "follow") {
                        
            ParseActions.followUnfollow(sender, withID: id, andUsername: username)
        }
    }
    
    
}
























