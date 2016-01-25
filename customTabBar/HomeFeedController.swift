//
//  HomeFeedController.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/8/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import Parse

class HomeFeedController: UITableViewController {
    var feeds: [ChannelFeed] = []
    var allItemsLoaded = false
    let loadOffset: CGFloat = 100
    var isLoadingItems = false
    
    //for infinite scrolling
    @IBOutlet var refreshView : UIView!
    @IBOutlet weak var refreshIndicator: UIActivityIndicatorView!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var noInternetLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noInternetLabel.hidden = true
        refreshButton.hidden = true
        
        tableView.scrollIndicatorInsets.bottom = TabBarSettings.height
        tableView.contentInset.bottom = TabBarSettings.height
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        
        //self.tableView.addSubview(pullRefresher)
        
        
    }
    
    func refresh(refresher: UIRefreshControl) {
        if !refresher.refreshing {
            refresher.beginRefreshing()
        }
        
        allItemsLoaded = false
        loadFeed(.Reload, size: HomeFeedsSettings.sectionsInPage)
        performSelector("refreshShouldStop:", withObject: refresher, afterDelay: 5.0)
    }
    
    func refreshShouldStop(refresher: UIRefreshControl) {
        if refresher.refreshing { /// Refreshing failed
            refresher.endRefreshing()
            tableView.tableHeaderView = refreshView
            
            // add refresh view with cannot connect to top of view
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationItem.title = "Home"
        
        //TODO: When posting, make nav bar right item as indicator
        //activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        //AppUtils.switchOnActivityIndicator(activityIndicator, forView: view, ignoreUser: true)
    }
    
//    func requestData(offset:Int, size:Int, listener:([MyItem]) -> ()) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//            dispatch_async(dispatch_get_main_queue()) {喵} } }
    
    //
    func loadFeed(type: LoadType, size:Int) {
        if isLoadingItems || allItemsLoaded {
            return
        }
        isLoadingItems = true
        
        var start: Int!
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
                self.allItemsLoaded = true
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
            
            self.isLoadingItems = false
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        //TODO: will crash after pull request, because feeds has been set to []
        let offset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height + scrollView.contentInset.bottom
        // this runs when scrolling started !!!!!!!!!!!!!!!!
        
        if (maxOffset-offset < loadOffset) && (!allItemsLoaded) {
            loadFeed(.AddOn, size: HomeFeedsSettings.sectionsInPage)
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
            return 40
        } else {
            return 85
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let chCell = tableView.dequeueReusableCellWithIdentifier("nameCell", forIndexPath: indexPath) as! ChannelCell
            
            chCell.name.text = feeds[indexPath.section].username
            feeds[indexPath.section].userThumb?.getDataInBackgroundWithBlock { (data, error) -> Void in
                guard let data = data else {return}
                if let thumb = UIImage(data: data) {
                    chCell.photo.image = thumb
                }
            }
            return chCell
        }
        else {
            let epCell = tableView.dequeueReusableCellWithIdentifier("contentCell", forIndexPath: indexPath) as! EpisodeCell
        
            //Image Files are PFFile type
            let episode = feeds[indexPath.section].episodes[indexPath.row-1]
            episode.thumb?.getDataInBackgroundWithBlock { (data, error) -> Void in
                guard let data = data else {return}
                if let thumb = UIImage(data: data) {
                    epCell.episodeThumb.image = thumb
                }
            }
            
            epCell.title.text = episode.episodeTitle
            epCell.duration.text = AppUtils.durationToClockTime(episode.sectionDurations.reduce(0, combine: +))
            
            return epCell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let idx = tableView.indexPathForCell(sender as! UITableViewCell) else {return}
        if segue.identifier == "showUserProfile" {
            
            //TODO: how to and when to put userinfo in the feed?????
            
            ProfileViewController.Options.followText = "Following"
            ProfileViewController.Options.hideFollowing = false
            ProfileViewController.Options.username = feeds[idx.section].username
            ProfileViewController.Options.userId = feeds[idx.section].userId
            ProfileViewController.Options.profileName = "Profile Name"
            
            //vc.tableView.reloadData()
        } else if segue.identifier == "openPlayer" {
            let playVC = segue.destinationViewController as! PlaySoundViewController
            let episode = feeds[idx.section].episodes[idx.row - 1] ///// first row is user cell
            if SectionAudioPlayer.sharedInstance.currentEpisode?.episodeURL != episode.episodeURL {
                SectionAudioPlayer.sharedInstance.setupPlayerWithEpisode(episode)
            }
            playVC.episode = episode
            SectionAudioPlayer.sharedInstance.play()
            
            //TODO: set title should be in  sectionaudio player   nsnotification
            //(tabBarController as? CustomTabBarController)?.audioTitleButton.setTitle(episode.episodeTitle, forState: .Normal)
        }
    }
    
}









































