//
//  HomeFeedController.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/8/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import Foundation
import Parse

class HomeFeedController: UITableViewController {
    // TODO : wrap to a Infinite scroll format
    //let PageSize = 20
    var items:[MyItem] = []
    var isLoading = false
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
        loadSegment(0, size: HomeFeedsSettings.sectionsInPage)
        
        pullRefresher.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        pullRefresher.beginRefreshing()
        self.tableView.addSubview(pullRefresher)
        
    }
    
    func refresh() {
        
        tableView.reloadData()
        pullRefresher.endRefreshing()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //TODO: put these in Parse with refresh indicator on
        loadSegment(0, size: HomeFeedsSettings.sectionsInPage)
        refresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationItem.title = "Home"
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
                for i in offset ... (offset + size) {
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
        if (!self.isLoading) {
            self.isLoading = true
            self.refreshView.hidden = (offset==0) ? true : false
            let manager = DataManager()
            manager.requestData(offset, size: size,
                listener: {(items:[HomeFeedController.MyItem]) -> () in
                    
                    for item in items {
                        //print(self.items.count)
                        self.items.append(item)
                        //self.tableView?.insertRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                        
                        self.tableView?.insertSections(NSIndexSet(index: self.items.count-1), withRowAnimation: .None)
                    }
                    self.isLoading = false
                    self.refreshView.hidden = true
                }
            )
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if (maxOffset - offset) <= 50 {
            loadSegment(items.count, size: HomeFeedsSettings.sectionsInPage - 1)
        }
    }
    
    // #pragma mark - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return items.count
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let chCell = tableView.dequeueReusableCellWithIdentifier("nameCell") as! ChannelCell
        // TODO: change to UIView not Cell to avoid "no index path for table cell"

        //let imagename = getRandomNumberBetween(1, To: 10).description + ".png"
        //chCell.photo.image = UIImage(named:imagename)! as UIImage
        //chCell.name.text = items[section].name as String
        //chCell.name.text = "abcd"
        //print(chCell.contentView.subviews)
        return chCell
    }

    
    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85;
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let epCell = tableView.dequeueReusableCellWithIdentifier("contentCell", forIndexPath: indexPath) as! EpisodeCell

        //Configure the cell...
        //print(epCell.episodeThumb.contentMode.rawValue)
        
        
        
        
        
        
        return epCell
    }
    
    
    
    
    
    
    
}









































