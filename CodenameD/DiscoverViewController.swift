//
//  DiscoverViewController.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/15/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import Parse

class DiscoverViewController: InfiniteTableViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate, SearchResultsDelegate {
    
    var fetchedUsers = [PFUser]()
    var userNumberToSkip = 0
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: custom search controller with segment controls
        searchController = {
            let searchResultsController = storyboard!.instantiateViewControllerWithIdentifier("SearchResultTVCIdentifier") as! SearchResultTVC
            let controller = UISearchController(searchResultsController: searchResultsController)
            searchResultsController.delegate = self
            
            controller.searchResultsUpdater = self
            controller.delegate = self;
            controller.searchResultsUpdater = self
            controller.searchBar.delegate = self
            
            controller.searchBar.autocorrectionType = .No
            controller.searchBar.autocapitalizationType = .None
            controller.searchBar.spellCheckingType = .No
            //controller.searchBar.searchBarStyle = .Minimal
            
            controller.hidesNavigationBarDuringPresentation = false
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.placeholder = "Search Username"
            //controller.searchBar.sizeToFit()
            
            return controller}()
        
        self.definesPresentationContext = true    //// WHY??
        
        navigationItem.titleView = searchController.searchBar
        
        tableView.rowHeight = 60
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: following users
    override func loadItems(type: LoadType, size: Int) {
        if isLoadingItems {
            return
        }
        
        var start = 0
        if type == .Reload {
            start = 0
        } else if type == .AddOn {
            start = userNumberToSkip
        }
        usersNotFollowing(start, size: size)
    }
    
    func usersNotFollowing(skip: Int, size: Int) {
        
        isLoadingItems = true
        var errorMessage = "Please try again later"
        
        guard let queryA = PFUser.query() else {return}
        let queryB = PFQuery(className: "Activities")
        queryB.whereKey("fromUser", equalTo: PFUser.currentUser()!.objectId!)
        queryB.whereKey("type", equalTo: "following")
        queryA.whereKey("objectId", doesNotMatchKey: "toUser", inQuery: queryB)
        
        queryA.orderByDescending("postUpdatedAt")
        queryA.limit = size
        queryA.skip = skip
        queryA.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
            self.refreshControl?.endRefreshing()
            self.isLoadingItems = false
            
            if error != nil {
                if let errorString = error!.userInfo["error"] as? String {
                    errorMessage = errorString
                }
                AppUtils.displayAlert("Fetching Users Failed", message: errorMessage, onViewController: self)
                return
            }
            
            guard let users = objects else {return}
            
            if skip <= 0 {
                self.fetchedUsers.removeAll()
                self.userNumberToSkip = 0  // we need this para because current user is skipped, maybe remove in future
            }
            let numOfUsersBeforeInsertion = self.fetchedUsers.count
            
            for object in users {
                guard let u = object as? PFUser else {continue}
                if (u.objectId! == PFUser.currentUser()?.objectId) || (u.username == nil) {continue}
                self.fetchedUsers.append(u)
            }
            self.userNumberToSkip += users.count
            
            if skip <= 0 {
                self.tableView.reloadData()
            } else {
                
                var idxPath = [NSIndexPath]()
                for i in numOfUsersBeforeInsertion ..< self.fetchedUsers.count {
                    idxPath.append(NSIndexPath(forRow: i, inSection: 0))
                }
                self.tableView.insertRowsAtIndexPaths(idxPath, withRowAnimation: .None)
            }
            
            if (users.count < size) || (self.fetchedUsers.count > 100) {
                self.allItemsLoaded = true
            }
        }
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedUsers.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("discoverCell", forIndexPath: indexPath)
        
        let item = fetchedUsers[indexPath.row]
        
        cell.textLabel?.text = AppUtils.getMeaningfulString(item["profileName"]) ?? (item["username"] as! String)
        cell.detailTextLabel?.text = "@" + (item["username"] as! String)
        
        if let text = AppUtils.getMeaningfulString(item["introduction"]) {
            cell.detailTextLabel?.text? += (" • " + text)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = storyboard!.instantiateViewControllerWithIdentifier("UserProfileTVCIdentifier") as! ProfileViewController
        
        vc.user = fetchedUsers[indexPath.row]
        
        shouldPushViewController(vc)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    
    
    
    
}



































