//
//  NotifViewController.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/23/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit

class NotifViewController: UITableViewController {
    var headerHeight: CGFloat = 0
    
    
    @IBOutlet weak var tmpLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //sizeHeaderToFit()
        //print("viewwilllayout")
        
    }
    
    func sizeHeaderToFit() {
        let headerView = tableView.tableHeaderView!
        
        //headerView.setNeedsLayout()
        //headerView.layoutIfNeeded()
        
        let height = headerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        print(height)
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        
        tableView.tableHeaderView = headerView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.navigationItem.title = "Notifications"
        print(tmpLabel.sizeThatFits(CGSize(width: view.bounds.width, height: CGFloat.max)))
        print(tmpLabel.frame.height)
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
