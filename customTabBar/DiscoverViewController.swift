//
//  DiscoverViewController.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/15/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import Parse

class DiscoverViewController: UITableViewController {
    
    
    var usernames = [String]()
    var userids = [String]()
    var isFollowing = [String: Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        allNotFollowed()
    }
    
    
    
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
    
    
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("discoverCell", forIndexPath: indexPath)

        cell.textLabel?.text = usernames[indexPath.row]
        

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
