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
        
        cell.textLabel?.text = (item["profileName"] as? String) ?? (item["username"] as! String)
        cell.detailTextLabel?.text = "@" + (item["username"] as! String)
        
        if let text = item["intro"] as? String {
            if cell.detailTextLabel?.text != nil {
                cell.detailTextLabel!.text! += (" ● " + text)
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let vc = storyboard!.instantiateViewControllerWithIdentifier("UserProfileTVCIdentifier") as! ProfileViewController
        vc.options = [
            UserProfileKeys.UserID : searchedUsers[indexPath.row].objectId!,
            UserProfileKeys.Username : searchedUsers[indexPath.row]["username"] as! String,
            UserProfileKeys.Intro : searchedUsers[indexPath.row]["intro"] as? String,
            UserProfileKeys.Weblink : searchedUsers[indexPath.row]["weblink"] as? String
        ]
        delegate?.shouldPushViewController?(vc)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //Mark: scroll view delegate
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        delegate?.searchBarShouldResignFirstResponder?()
    }
}
