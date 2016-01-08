//
//  DiscoverViewController.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/15/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import Parse

class DiscoverViewController: UITableViewController, UISearchResultsUpdating {
    
    var searchedData = ["One","Two","Three","Twenty-One"]
    var filteredTableData = [String]()
    var searchingString: String! = ""
    
    var usernames = [String]()
    var userids = [String]()
    var isFollowing = [String: Bool]()
    let searchBar = UISearchBar()
    var searchController: UISearchController!
    weak var tmpViewToStoreNav: UIView?
    var tmpItem: [UIBarButtonItem]?
    
    //var leftBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allNotFollowed()
        
        
        // TODO: custom search controller with segment controls
        searchController = {
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.hidesNavigationBarDuringPresentation = false
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.placeholder = "Search"
            controller.searchBar.sizeToFit()
            
            return controller}()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tmpViewToStoreNav = tabBarController?.navigationItem.titleView
        tmpItem = tabBarController?.navigationItem.rightBarButtonItems
        
        tabBarController?.navigationItem.titleView = searchController.searchBar
        tabBarController?.navigationItem.rightBarButtonItems = []
        
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // set it back
        tabBarController?.navigationItem.titleView = tmpViewToStoreNav
        if tmpItem?.count > 0 {
            tabBarController?.navigationItem.rightBarButtonItems?.insert(tmpItem![0], atIndex: 0)
        }
        //if tabBarController?.navigationItem.rightBarButtonItems?.count > 0 {/*don't insert current*/}
        tmpItem = nil
    }
    
    func fetchSearchData() {
        //Parse
        //searchedData.removeAll()  //TODO: put to search bar did become first responder
        guard let query = PFUser.query() else {return}
        query.whereKey("username", containsString: searchingString)
        query.limit = 100
        query.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
            if error != nil {
                print("couldn't search")
                return
            }
            
            guard let users = objects else {return}
            for object in users {
                guard let u = object as? PFUser else {return}
                if u.objectId! == PFUser.currentUser()?.objectId {continue}
                self.searchedData.append(u.username!)
            }
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredTableData.removeAll()
        //TODO: remove all, use Parse
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        
        let array = (searchedData as NSArray).filteredArrayUsingPredicate(searchPredicate)
        filteredTableData = array as! [String]
        
        tableView.reloadData()
    }
    
    
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if searchController.active {
            return self.filteredTableData.count
        } else {
            return usernames.count
        }
        
        
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("discoverCell", forIndexPath: indexPath)
        
        if searchController.active {
            cell.textLabel?.text = filteredTableData[indexPath.row]
        } else {
            cell.textLabel?.text = usernames[indexPath.row]
        }
        

        return cell
    }
    
    
    // MARK: following users
    func allNotFollowed() {
        var errorMessage = "Please try again later"
        guard let queryA = PFUser.query() else {return}
        let queryB = PFQuery(className: "Activities")
        
        queryB.whereKey("fromUser", equalTo: PFUser.currentUser()!.objectId!)
        queryB.whereKey("type", equalTo: "following")
        queryA.whereKey("objectId", doesNotMatchKey: "toUser", inQuery: queryB)
        
        queryA.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
            if error != nil {
                if let errorString = error!.userInfo["error"] as? String {
                    errorMessage = errorString
                }
                AppUtils.displayAlert("Fetching Users Failed", message: errorMessage, onViewController: self)
                return
            }
            
            guard let users = objects else {return}
            
            for object in users {
                guard let u = object as? PFUser else {return}
                if u.objectId! == PFUser.currentUser()?.objectId {continue}
                self.userids.append(u.objectId!)
                self.usernames.append(u.username!)
                self.isFollowing[u.objectId!] = false
            }
            self.tableView.reloadData()
        }
        
    }
    
    func followUser(aUser: PFUser) {
        let activities = PFObject(className:"Activities")
        
        guard let currentUser = PFUser.currentUser() else {return}
        
        let follow : String = "following"
        
        activities.setObject(currentUser, forKey: "fromUser")
        activities.setObject(aUser, forKey: "toUser") // user is a another PFUser in my app
        
        activities.setObject(follow, forKey: "type")
        
        activities.saveEventually()
    }
    
    
    var followingUserList = [PFUser]()
    func loadFollowingUsers() {
        followingUserList.removeAll()
        //followingUserList.removeAllObjects()
        
        let findUserObjectId = PFQuery(className: "Activities")
        findUserObjectId.whereKey("fromUser", equalTo: PFUser.currentUser()!.objectId!)
        findUserObjectId.whereKey("type", equalTo: "following")
        
        
        findUserObjectId.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if let users = objects  {
                // The find succeeded.
                print("succesfully loaded the fromUser  in Activity class")
                // Do something with the found objects
                for user in users {
                    
                    guard let user = user["toUser"] as? PFUser else {return}
                    
                    guard let queryUsers = PFUser.query() else {return}
                    queryUsers.getObjectInBackgroundWithId(user.objectId!, block: { (userGet ,error) -> Void in
                        
                        if let result = userGet as? PFUser {
                            self.followingUserList.append(result)
                            self.tableView.reloadData()
                        }
                    })
                    
                    
                } } else {
                // Log details of the failure
                print("error loadind user ")
                print(error)
            }
        }
    }
    
    // MARK: - show user profile
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showUserProfile" {
            guard let i = tableView.indexPathForCell(sender as! UITableViewCell)?.row else {return}
            
            ProfileViewController.Options.followText = "Follow"
            ProfileViewController.Options.hideFollowing = false
            ProfileViewController.Options.username = usernames[i]
            ProfileViewController.Options.userId = userids[i]
            ProfileViewController.Options.profileName = "Profile Name"
            
            
            
            
            //vc.tableView.reloadData()
        }
    }
    
    
    
}



































