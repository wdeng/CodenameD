//
//  HomeFeedController.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/8/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import Parse


//TODO: change to Infinite tvc
class HomeFeedController: InfiniteTableViewController {
    var feeds: [ChannelFeed] = []
    
    //for infinite scrolling
    @IBOutlet var refreshView : UIView!
    @IBOutlet weak var refreshIndicator: UIActivityIndicatorView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var noInternetLabel: UILabel!
    
    var homeFeedFilePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        return url.URLByAppendingPathComponent("homeFeedFilePath").path!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = refreshView
        
        noInternetLabel.hidden = true
        refreshButton.hidden = true
        
        tableView.scrollIndicatorInsets.bottom = TabBarSettings.height
        tableView.contentInset.bottom = TabBarSettings.height
        
        tableView.registerNib(UINib(nibName: "EpisodeCell", bundle: nil), forCellReuseIdentifier: "episodeCell")
        
        //feeds = NSKeyedUnarchiver.unarchiveObjectWithFile(homeFeedFilePath) as? [ChannelFeed] ?? [homeFeedFilePath]()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationItem.title = "Home"
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func loadItems(type: LoadType, size:Int) {
        if isLoadingItems {
            return
        }
        isLoadingItems = true
        
        var start = 0
        if type == .Reload {
            start = 0
        }
        else {
            self.tableView.tableFooterView = refreshView
            start = feeds.count
        }
        
        HomeFeedFromParse.fetchFollowingPosts(start, size: size) { (newItems) -> Void in
            self.refreshControl?.endRefreshing()
            self.tableView.tableFooterView = nil
            if newItems.count == 0 {
                if self.feeds.count == 0 {
                    self.tableView.reloadData()
                    //TODO: Show place holder View, background view
                }
            } else {
                let range = NSRange(location: start, length: newItems.count)
                let indexRange = NSIndexSet(indexesInRange: range)
                if start == 0 {
                    self.feeds = newItems
                    //self.tableView.reloadSections(indexRange, withRowAnimation: .Automatic)
                    self.tableView.reloadData()
                    // If there is background view, set to nil
                } else {
                    
                    self.feeds += newItems
                    self.tableView.insertSections(indexRange, withRowAnimation: .None)
                }
                
            }
            
            if newItems.count < size {
                self.allItemsLoaded = true
            }
            self.isLoadingItems = false
            
            //NSKeyedArchiver.archiveRootObject(self.feeds, toFile: homeFeedFilePath)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return feeds.count
    }
    
    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return feeds[section].episodes.count+1
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 50
        } else {
            return 100
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let chCell = tableView.dequeueReusableCellWithIdentifier("nameCell", forIndexPath: indexPath) as! ChannelCell
            let profileName = AppUtils.getMeaningfulString(feeds[indexPath.section].user?["profileName"]) ?? feeds[indexPath.section].user?.username
            chCell.name.text = profileName
            
            return chCell
        }
        else {
            let epCell = tableView.dequeueReusableCellWithIdentifier("episodeCell", forIndexPath: indexPath) as! EpisodeCell
        
            //Image Files are PFFile type
            let episode = feeds[indexPath.section].episodes[indexPath.row-1]
            episode.thumb?.getDataInBackgroundWithBlock { (data, error) -> Void in
                guard let data = data else {return}
                if let thumb = UIImage(data: data) {
                    epCell.episodeThumb.image = thumb
                }
            }
            
            epCell.uploadTime.text = AppUtils.dateToUploadTime(episode.uploadDate)
            
            epCell.title.text = episode.episodeTitle
            let dur = AppUtils.durationToClockTime(episode.sectionDurations.reduce(0, combine: +))
            epCell.durationAndLikes.text = dur
            
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
                        epCell.durationAndLikes.text = dur + " • \(count) like" + appendix
                    }
                }
            }
            
            
            epCell.otherOptions.addTarget(self, action: Selector("otherFunctions:"), forControlEvents: .TouchUpInside)

            return epCell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != 0 {
            self.performSegueWithIdentifier("openPlayer", sender: indexPath)
        } else {
            self.performSegueWithIdentifier("showUserProfile", sender: indexPath)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let idx = sender else {return}
        if segue.identifier == "showUserProfile" {
            let profileVC = segue.destinationViewController as! ProfileViewController
            profileVC.user = feeds[idx.section].user ?? PFUser()
            
        } else if segue.identifier == "openPlayer" {
            let playVC = segue.destinationViewController as! PlaySoundViewController
            let episode = feeds[idx.section].episodes[idx.row - 1] ///// first row is user cell
            
            if SectionAudioPlayer.sharedInstance.currentEpisode?.episodeURL != episode.episodeURL {
                SectionAudioPlayer.sharedInstance.setupPlayerWithEpisode(episode)
            }
            playVC.episode = episode
            SectionAudioPlayer.sharedInstance.play()
            
        }
    }
    
    
    func otherFunctions(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let shareAct = UIAlertAction(title: "Share...", style: .Default) { (action) in
            
        }
        alertController.addAction(shareAct)
        
        let laterAct = UIAlertAction(title: "Add to Play Later", style: .Default) { (action) in
            
        }
        alertController.addAction(laterAct)
        laterAct.enabled = false
        let listAct = UIAlertAction(title: "Add to playlist", style: .Default) { (action) in
            
        }
        alertController.addAction(listAct)
        
        let reportAct = UIAlertAction(title: "Report", style: .Destructive) { (action) in
            
        }
        alertController.addAction(reportAct)
        
        //TODO: remove
        for action in alertController.actions {
            action.enabled = false
        }
        cancelAction.enabled = true

        self.presentViewController(alertController, animated: true, completion: nil)
    }
}









































