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
    
    var usernames = [String]()
    var userids = [String]()
    var isFollowing = [String: Bool]()
    
    //before prepare for segue
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("followCell", forIndexPath: indexPath) as! FollowCell
        
        cell.username.text = usernames[indexPath.row]
        let followedObjectID = userids[indexPath.row]
        
        cell.isFollowing.tag = indexPath.row
        cell.isFollowing.addTarget(self, action: "followUnfollow:", forControlEvents: .TouchUpInside)
        if isFollowing[followedObjectID] == true {
            cell.isFollowing.setTitle("Following", forState: .Normal)
        } else {
            cell.isFollowing.setTitle("Follow", forState: .Normal)
        }

        return cell
    }
    
    func followUnfollow(b: UIButton) {
        let id = userids[b.tag]
        let username = usernames[b.tag]
        if isFollowing[id] == true {
            isFollowing[id] = false
        } else {
            isFollowing[id] = true
        }
        ParseActions.followUnfollow(b, withID: id, andUsername: username)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
