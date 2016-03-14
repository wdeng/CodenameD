//
//  InfiniteTableViewController.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 2/29/16.
//  Copyright © 2016 Wenxiang Deng. All rights reserved.
//

import UIKit

enum LoadType {
    case AddOn
    case Reload
}


class InfiniteTableViewController: UITableViewController {
    
    var allItemsLoaded = false
    var loadOffset: CGFloat = 100
    var sizePerPage: Int = 10
    var isLoadingItems = false

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func refresh() {
        refreshControl?.beginRefreshing()
        tableView.tableFooterView?.hidden = false
        
        allItemsLoaded = false
        loadItems(.Reload, size: sizePerPage)
        performSelector("refreshShouldStop", withObject: nil, afterDelay: 10.0)
    }
    
    func refreshShouldStop() {
        if self.refreshControl?.refreshing == true {
            self.refreshControl?.endRefreshing()
        }
    }
    
    
    func loadItems(type: LoadType, size: Int) {
        //PlaceHolder, override in subclass
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height + scrollView.contentInset.bottom
        // this runs when scrolling started !!!!!!!!!!!!!!!!
        
        if (maxOffset-offset < loadOffset) && (!allItemsLoaded) {
            loadItems(.AddOn, size: sizePerPage)
        }
    }
    
    
}







































