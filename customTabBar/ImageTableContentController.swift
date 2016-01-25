//
//  TableViewController.swift
//  PitchPerfect
//
//  Created by Wenxiang Deng on 11/26/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import Parse

class ImageTableContentController: UITableViewController {
    //TODO: need to test the marigin and make sure correct image ratio
    let imageMarigin: CGFloat = 16
    var itemIndex = 0
    var images: [UIImage] = []
    let activityIndicator = UIActivityIndicatorView(frame: UIScreen.mainScreen().bounds)
    
    override func awakeFromNib() {
        //print("awake from nib")
        super.awakeFromNib()
    }
    
    override func loadView() {
        //print("loading view")
        super.loadView()
    }
    
    override func viewDidLoad() {
        //print("view did load")
        super.viewDidLoad()
        tableView.contentInset.bottom = 20
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ImageContentCell", forIndexPath: indexPath) as! ImageTableContentCell
        cell.contentImageView.image = images[indexPath.row]
        return cell
    }

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return images[indexPath.row].size.height / images[indexPath.row].size.width * view.frame.width + imageMarigin
    }

}
