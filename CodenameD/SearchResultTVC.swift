//
//  SearchResultTVC.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 2/14/16.
//  Copyright © 2016 Wenxiang Deng. All rights reserved.
//

import UIKit
import Parse

@objc protocol SearchResultsDelegate {
    optional func shouldPushViewController(vc: UIViewController)
    optional func searchBarShouldResignFirstResponder()
}

class SearchResultTVC: UITableViewController {
    
    var searchedUsers: [PFUser] = []
    var delegate: SearchResultsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 60
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //tableView.reloadData()
    }
    
    //Mark: table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("search result: \(searchedItems)")
        return searchedUsers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchResultCell", forIndexPath: indexPath)
        //let cell = tableView.dequeueReusableCellWithIdentifier("searchResultCell")!
        let item = searchedUsers[indexPath.row]
        
        cell.textLabel?.text = AppUtils.getMeaningfulString(item["profileName"]) ?? (item["username"] as! String)
        cell.detailTextLabel?.text = "@" + (item["username"] as! String)
        
        if let text = AppUtils.getMeaningfulString(item["introduction"]) {
            cell.detailTextLabel?.text? += (" • " + text)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let vc = storyboard!.instantiateViewControllerWithIdentifier("UserProfileTVCIdentifier") as! ProfileViewController
        
        vc.user = searchedUsers[indexPath.row]
        delegate?.shouldPushViewController?(vc)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //Mark: scroll view delegate
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        delegate?.searchBarShouldResignFirstResponder?()
    }
}
