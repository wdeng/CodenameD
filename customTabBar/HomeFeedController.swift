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
    var items:[MyItem] = []
    var feeds: [ChannelFeed] = []
    
    let loadOffset: CGFloat = 200
    var canLoadNewItems = false
    //for infinite scrolling
    @IBOutlet var refreshView : UIView!
    @IBOutlet weak var refreshIndicator: UIActivityIndicatorView!
    @IBOutlet weak var refreshButton: UIButton!
    
    @IBOutlet weak var noInternetLabel: UILabel!
    var pullRefresher = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noInternetLabel.hidden = true
        refreshButton.hidden = true
        tableView.scrollIndicatorInsets.bottom = TabBarSettings.height
        tableView.contentInset.bottom = TabBarSettings.height
        
        //TODO: change to persistence
        //loadSegment(0, size: HomeFeedsSettings.sectionsInPage)
        
        pullRefresher.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        
        self.tableView.addSubview(pullRefresher)
        
        
    }
    
    func refresh() {
        
        tableView.reloadData()
        pullRefresher.endRefreshing()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //pullRefresher.beginRefreshing()
        
        //TODO: put these in Parse with refresh indicator on
        //loadSegment(0, size: HomeFeedsSettings.sectionsInPage)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationItem.title = "Home"
        canLoadNewItems = true
        
        //TODO: When posting, make nav bar right item as indicator
        //activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        //AppUtils.switchOnActivityIndicator(activityIndicator, forView: view, ignoreUser: true)
    }
    
    func getRandomNumberBetween (From: Int , To: Int) -> Int {
        return From + Int(arc4random_uniform(UInt32(To - From + 1)))
    }
    
    class MyItem : CustomStringConvertible {
        let name:String!
        
        init(name:String) {
            self.name = name
        }
        var description: String {
            return name
        }
    }
    
    class DataManager {
        func requestData(offset:Int, size:Int, listener:([MyItem]) -> ()) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                //Sleep the Process
                if offset != 0 {
                    sleep(2)
                }
                //generate items
                var arr:[MyItem] = []
                for i in offset ..< (offset + size) {
                    arr.append(MyItem(name: "Item " + String(i)))
                }
                
                //call listener in main thread
                dispatch_async(dispatch_get_main_queue()) {
                    listener(arr)
                }
            }
        }
    }
    
    func loadSegment(offset:Int, size:Int) {
        canLoadNewItems = false
        self.refreshView.hidden = (offset==0) ? true : false
        let manager = DataManager()
        manager.requestData(offset, size: size,
            listener: {(items:[HomeFeedController.MyItem]) -> () in
                self.items += items
                
                let r = NSRange(location: offset, length: items.count)
                let i = NSIndexSet(indexesInRange: r)
                self.tableView?.insertSections(i, withRowAnimation: .None)
                self.canLoadNewItems = true
                self.refreshView.hidden = true
            }
        )
    }
    
    func loadFeed(start:Int, size:Int) {
        canLoadNewItems = false
        refreshView.hidden = false
        
        HomeFeedFromParse.fetchFollowingPosts(start, size: size) { (newItems) -> Void in
            self.feeds += newItems
            // TODO: is very likely not the exact number
            let r = NSRange(location: start, length: newItems.count)
            let i = NSIndexSet(indexesInRange: r)
            self.tableView?.insertSections(i, withRowAnimation: .None)
        }
        
        
        
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if (maxOffset-offset < loadOffset) && canLoadNewItems {
            //loadSegment(items.count, size: HomeFeedsSettings.sectionsInPage - 1)
            
            loadFeed(feeds.count, size: HomeFeedsSettings.sectionsInPage)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return feeds.count
    }
    
    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return 4
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
            let chCell = tableView.dequeueReusableCellWithIdentifier("nameCell") as! ChannelCell
            
            //let imagename = getRandomNumberBetween(1, To: 10).description + ".png"
            //chCell.photo.image = UIImage(named:imagename)! as UIImage
            //chCell.name.text = items[section].name as String
            //chCell.name.text = "abcd"
            //print(chCell.contentView.subviews)
            
            return chCell
        }
        else {
        
            let epCell = tableView.dequeueReusableCellWithIdentifier("contentCell", forIndexPath: indexPath) as! EpisodeCell
        
        /*
            //Image Files are PFFile type
            imageFiles[indexPath.row].getDataInBackgroundWithBlock { (data, error) -> Void in
                if let downloadedImage = UIImage(data: data!) {
                    myCell.postedImage.image = downloadedImage
                }
            }
        */
        
        
        
        
        
            return epCell
        }
    }
    
    
}









































