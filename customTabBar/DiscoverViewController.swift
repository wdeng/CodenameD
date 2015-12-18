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
    var tmpViewToStoreNav: UIView?
    
    //var leftBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        allNotFollowed()
        
        tmpViewToStoreNav = tabBarController?.navigationItem.titleView
        
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
        tabBarController?.navigationItem.titleView = searchController.searchBar
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        // set it back
        tabBarController?.navigationItem.titleView = tmpViewToStoreNav
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    
    
    // MARK: following users
    func allNotFollowed() {
        var errorMessage = "Please try again later"
        guard let queryA = PFUser.query() else {return}
        let queryB = PFQuery(className: "activity")
        
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
        let activity = PFObject(className:"activity")
        
        guard let currentUser = PFUser.currentUser() else {return}
        
        let follow : String = "following"
        
        activity.setObject(currentUser, forKey: "fromUser")
        activity.setObject(aUser, forKey: "toUser") // user is a another PFUser in my app
        
        activity.setObject(follow, forKey: "type")
        
        activity.saveEventually()
    }
    
    
    var followingUserList = [PFUser]()
    func loadFollowingUsers() {
        followingUserList.removeAll()
        //followingUserList.removeAllObjects()
        
        let findUserObjectId =       PFQuery(className: "activity")
        findUserObjectId.whereKey("fromUser", equalTo: PFUser.currentUser()!)
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
    
    /*
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    }
    */
    
    
    
    
}
