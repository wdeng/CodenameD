//
//  ProfileViewController.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/13/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: InfiniteTableViewController {
    
    var user = PFUser()
    var options = [String : AnyObject?]()
    var fetchedEpisodes = [EpisodeToPlay]()
    var navBarShouldHide = true
    
    @IBOutlet weak var profileView: ProfileHeaderView!
    
    func setupProfile(withUser user: PFUser) {
        let profileName = AppUtils.getMeaningfulString(user["profileName"]) ?? user.username
        let opts : [String : AnyObject?] = [
            UserProfileKeys.UserID : user.objectId,
            UserProfileKeys.Username : user.username,
            UserProfileKeys.Name : profileName,
            UserProfileKeys.Intro : user["introduction"] ?? nil,
            UserProfileKeys.Weblink : user["website"] ?? nil,
        ]
        profileView.setupProfile(withOptions: opts)
        
        if navBarShouldHide {
            tabBarController?.navigationController?.setNavigationBarHidden(true, animated: false)
        } else {
            tabBarController?.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfile(withUser: user)
        
        settingsButton.hidden = true
        tableView.rowHeight = 100.0
        tableView.registerNib(UINib(nibName: "EpisodeCell", bundle: nil), forCellReuseIdentifier: "episodeCell")
    }
    
    @IBAction func settings(sender: AnyObject) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            
        }
        alertController.addAction(cancelAction)
        
        let destroyAction = UIAlertAction(title: "Logout", style: .Destructive) { (action) in
            
            PFUser.logOut()
            //TODO: clear all the user defaults
            let loginVC = self.storyboard!.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
            self.presentViewController(loginVC, animated: true, completion: nil)
        }
        alertController.addAction(destroyAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var settingsButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Reset HeaderView height
        let headerView = tableView.tableHeaderView!
        let maxSize = CGSize(width: UIScreen.mainScreen().bounds.width - 24.0, height: CGFloat.max)
        let userLinkHeight = profileView.userLink.titleForState(.Normal)?.characters.count > 0 ? profileView.userLink.sizeThatFits(maxSize).height : 6
        headerView.frame.size.height = 148 + profileView.userIntro.sizeThatFits(maxSize).height + userLinkHeight
        tableView.tableHeaderView = headerView // everytime this was called, layout subviews will be called
        
        
        tabBarController?.navigationItem.title = profileView.profileName.text
        navigationItem.title = profileView.profileName.text
        
        if let id = PFUser.currentUser()?.objectId { // TODO: may should change this
            if id == user.objectId {
                settingsButton.hidden = false
                tableView.scrollIndicatorInsets.bottom = TabBarSettings.height
                tableView.contentInset.bottom = TabBarSettings.height
            }
        }
        
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
    
    override func loadItems(type: LoadType, size: Int) {
        if isLoadingItems {
            return
        }
        var start = 0
        if type == .Reload {
            if let query = PFUser.query() {
                if let id = user.objectId {
                    query.whereKey("objectId", equalTo: id)
                    query.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
                        if objects?.count > 0 {
                            if let user = objects?.first as? PFUser {
                                self.user = user
                                self.setupProfile(withUser: user)
                            }
                        }
                    }
                }
            }
            
            start = 0
        } else if type == .AddOn {
            start = fetchedEpisodes.count
        }
        fetchEpisodes(start, size: size)
    }
    
    func fetchEpisodes(skip: Int, size: Int) {
        guard let id = user.objectId else {return}
        
        isLoadingItems = true
        var errorMessage = "Please try again later"
        
        let query = PFQuery(className: "Episode")
        query.whereKey("userId", equalTo: id)
        query.orderByDescending("updatedAt")
        
        query.limit = size
        query.skip = skip
        query.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
            self.refreshControl?.endRefreshing()
            self.isLoadingItems = false
            
            if error != nil {
                if let errorString = error!.userInfo["error"] as? String {
                    errorMessage = errorString
                }
                AppUtils.displayAlert("Fetching Posts Failed", message: errorMessage, onViewController: self)
                return
            }
            
            guard let posts = objects else {return}
            
            if skip <= 0 {
                self.fetchedEpisodes.removeAll()
            }
            
            for p in posts {
                let e = EpisodeToPlay()
                if let urlString = (p["audio"] as? PFFile)?.url {
                    e.episodeURL = NSURL(string: urlString)
                }
                e.episodeTitle = p["title"] as? String
                e.thumb = p["thumb"]
                e.imageSets = (p["images"] as? [[AnyObject]]) ?? []
                e.sectionDurations = (p["durations"] as? [Double]) ?? []
                e.episodeId = p.objectId
                e.authorId = id
                e.uploadDate = p.updatedAt
                
                //print("Title: \(e.episodeTitle), url: \(e.episodeURL), image: \(e.imageSets)")
                self.fetchedEpisodes.append(e)
            }
            
            if skip <= 0 {
                self.tableView.reloadData()
            } else {
                
                var idxPath = [NSIndexPath]()
                for i in skip ..< self.fetchedEpisodes.count {
                    idxPath.append(NSIndexPath(forRow: i, inSection: 0))
                }
                self.tableView.insertRowsAtIndexPaths(idxPath, withRowAnimation: .None)
            }
            
            if posts.count < size {
                self.allItemsLoaded = true
            }
        }
    }
    
    
    // MARK: - Table view data source
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedEpisodes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("episodeCell", forIndexPath: indexPath) as! EpisodeCell
        
        //Image Files are PFFile type
        let episode = fetchedEpisodes[indexPath.row]
        
        cell.episodeThumb.image = nil
        episode.thumb?.getDataInBackgroundWithBlock { (data, error) -> Void in
            guard let data = data else {return}
            cell.episodeThumb.image = UIImage(data: data)
        }
        
        cell.title.text = episode.episodeTitle
        cell.uploadTime.text = AppUtils.dateToUploadTime(episode.uploadDate)
        
        let dur = AppUtils.durationToClockTime(episode.sectionDurations.reduce(0, combine: +))
        cell.durationAndLikes.text = dur
        
        let query = PFQuery(className: "Activities")
        query.whereKey("type", equalTo: "like")
        if let id = episode.episodeId {
            query.whereKey("episode", equalTo: id)
            query.countObjectsInBackgroundWithBlock{ (count, error) -> Void in
                if error != nil {
                    debugPrint("couldn't fetch Activities")
                    return
                }
                
                let appendix = count > 1 ? "s" : ""
                if count > 0 {
                    cell.durationAndLikes.text = dur + " • \(count) like" + appendix
                }
                
            }
        }
        
        cell.otherOptions.addTarget(self, action: Selector("otherFunctions:"), forControlEvents: .TouchUpInside)
        


        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let playerVC = storyboard!.instantiateViewControllerWithIdentifier("SectionAudioPlayer") as! PlaySoundViewController
        
        let episode = fetchedEpisodes[indexPath.row]
        
        if SectionAudioPlayer.sharedInstance.currentEpisode?.episodeURL != episode.episodeURL {
            SectionAudioPlayer.sharedInstance.setupPlayerWithEpisode(episode)
        }
        
        playerVC.episode = episode
        SectionAudioPlayer.sharedInstance.play()
        
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
            playerVC.modalPresentationStyle = .OverFullScreen
        }
        self.presentViewController(playerVC, animated: true, completion: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // show following followers
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "editProfile" {
            if profileView.isFollowing.titleLabel?.text == "Edit Profile" {return true}
            else {return false}
        } else {
            return super.shouldPerformSegueWithIdentifier(identifier, sender: sender)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //let vc = segue.destinationViewController as! FollowingFollowerVC
        guard let userID = user.objectId else {return}
        if segue.identifier == "showFollowing" || segue.identifier == "showFollowers" {
            
            let actiType = segue.identifier == "showFollowing" ? ActivityType.Following : ActivityType.Followers
            let vc = segue.destinationViewController as! FollowingFollowerVC
            
            ParseActions.fetchActivities(actiType, forUserID: userID, finished: { (objs: [PFObject]) -> Void in
                if actiType == .Following {
                    for following in objs {
                        let id = following["toUser"] as! String
                        vc.userids.append(id)
                        //vc.usernames.append(following["toUsername"] as! String)
                        vc.navigationItem.title = "Following"
                    }
                } else {
                    for follower in objs {
                        let id = follower["fromUser"] as! String
                        vc.userids.append(id)
                        //vc.usernames.append(follower["fromUsername"] as! String)
                        vc.navigationItem.title = "Followers"
                    }
                }
                
                vc.reloadUsers()
            })
        }
    }
    
    @IBAction func unwindEditProfile(segue: UIStoryboardSegue) {
        //debugPrint("hi: \(segue.identifier)")
        if segue.sourceViewController is EditProfileController {
            
            profileView.profileName.text = AppUtils.getMeaningfulString(PFUser.currentUser()?["profileName"]) ?? PFUser.currentUser()?.username
            
            if let link = PFUser.currentUser()?["website"] as? String {
                profileView.userLink.setTitle(profileView.removeScheme(link), forState: .Normal)
            } else {
                profileView.userLink.setTitle(nil, forState: .Normal)
            }
            
            profileView.userIntro.text = PFUser.currentUser()?["introduction"] as? String
        }
    }
    
    @IBAction func followUnfollow(sender: UIButton) {
        let title = sender.titleLabel?.text?.lowercaseString
        guard let id = user.objectId else {return}
        guard let username = user.username else {return}
        if (title == "following") || (title == "follow") {
            ParseActions.followUnfollow(sender, withID: id, andUsername: username)
        }
    }
    
    func otherFunctions(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if profileView.isFollowing.titleLabel?.text == "Edit Profile" {
            let delAct = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
                let alert = UIAlertController(title: "Delete Episode?", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Delete", style: .Destructive) { (action) -> Void in
                    //TODO: delete episode
                    })
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            alertController.addAction(delAct)
            
            let laterAct = UIAlertAction(title: "Edit Title", style: .Default) { (action) in
                
            }
            alertController.addAction(laterAct)
        }
        
        let shareAct = UIAlertAction(title: "Share...", style: .Default) { (action) in
            
        }
        alertController.addAction(shareAct)
        
        let title = profileView.isFollowing.titleLabel?.text?.lowercaseString
        if (title == "following") || (title == "follow") {
            let laterAct = UIAlertAction(title: "Add to Play Later", style: .Default) { (action) in
                
            }
            alertController.addAction(laterAct)
            let listAct = UIAlertAction(title: "Add to playlist", style: .Default) { (action) in
                
            }
            alertController.addAction(listAct)
            
            let reportAct = UIAlertAction(title: "Report", style: .Destructive) { (action) in
                
            }
            alertController.addAction(reportAct)
        }
        
        //TODO: remove
        for action in alertController.actions {
            action.enabled = false
        }
        cancelAction.enabled = true
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
























