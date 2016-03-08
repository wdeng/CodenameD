//
//  FollowingFollowerVC.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/13/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import Parse

class FollowingFollowerVC: UITableViewController {
    
    var userids = [String]()
    var users = [PFUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 60
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    func reloadUsers() {
        guard let query = PFUser.query() else {return}
        query.whereKey("objectId", containedIn: userids)
        
        query.limit = 100
        query.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
            if let us = objects as? [PFUser] {
                self.users = us
            }
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("followCell", forIndexPath: indexPath) as! FollowCell
        
        let item = users[indexPath.row]
        
        cell.textLabel?.text = (item["profileName"] as? String) ?? (item["username"] as! String)
        cell.detailTextLabel?.text = "@" + (item["username"] as! String)
        
        if let text = item["introduction"] as? String {
            if cell.detailTextLabel?.text != nil {
                cell.detailTextLabel!.text! += (" • " + text)
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showUserProfile", sender: indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let idx = sender else {return}
        if segue.identifier == "showUserProfile" {
            let profileVC = segue.destinationViewController as! ProfileViewController
            profileVC.user = users[idx.row]
            
        }
    }
}

































