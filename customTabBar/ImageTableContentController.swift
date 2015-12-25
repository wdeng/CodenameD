//
//  TableViewController.swift
//  PitchPerfect
//
//  Created by Wenxiang Deng on 11/26/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit

class ImageTableContentController: UITableViewController {
    //TODO: need to test the marigin and make sure correct image ratio
    let imageMarigin = 16
    var itemIndex = 0
    var imageNames: [String] = []
    var images = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset.bottom = 20
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return images.count
        }
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ImageContentCell", forIndexPath: indexPath) as! ImageTableContentCell
        cell.contentImageView.image = images[indexPath.row] //UIImage(named: imageNames[indexPath.row])
        return cell
    }

    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let contentImage = images[indexPath.row]
        return contentImage.size.height / contentImage.size.width * view.frame.width + CGFloat(imageMarigin)
    }

}
