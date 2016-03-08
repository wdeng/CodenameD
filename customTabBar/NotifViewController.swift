//
//  NotifViewController.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/23/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit

class NotifViewController: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 60))
        label.text = "Notifications Current Not Available"
        label.textColor = UIColor.grayColor()
        label.font = UIFont.systemFontOfSize(21.0, weight: UIFontWeightMedium)
        label.numberOfLines = 2
        label.textAlignment = .Center
        label.center = CGPoint(x: view.center.x, y: view.center.y - 74)
        
        view.addSubview(label)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //sizeHeaderToFit()
        //print("viewwilllayout")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationItem.title = "Notifications"
        
        
        
        //print(tmpLabel.sizeThatFits(CGSize(width: view.bounds.width, height: CGFloat.max)))
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */
}
