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
    let PageSize = 20
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
        tableView.contentInset.bottom = 38
        loadSegment(0, size: 20)
        
        //pullRefresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        pullRefresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(pullRefresher)
        
        //refresh()
    }
    
    func refresh() {
        
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
                
                print(arr)
                
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
                        let row = self.items.count
                        let indexPath = NSIndexPath(forRow:row,inSection:0)
                        self.items.append(item)
                        self.tableView?.insertRowsAtIndexPaths([indexPath], withRowAnimation: .None) //insertSections should be this
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
        if (maxOffset - offset) <= 40 {
            loadSegment(items.count, size: PageSize-1)
        }
    }
    
    // #pragma mark - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let chCell = tableView.dequeueReusableCellWithIdentifier("nameCell") as! ChannelCell
        
        //let imagename = getRandomNumberBetween(1, To: 10).description + ".png"
        //chCell.photo.image = UIImage(named:imagename)! as UIImage
        //chCell.name.text = items[section].name as String
        
        return chCell
    }

    
    override func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return items.count
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









































