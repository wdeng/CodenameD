//
//  FollowCell.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/13/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit

class FollowCell: UITableViewCell {

    
    override func awakeFromNib() {
        super.awakeFromNib()
        //isFollowing.backgroundColor = UIColor.grayColor()
        //isFollowing.layer.cornerRadius = 5
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //self.bringSubviewToFront(isFollowing)
        if textLabel != nil {
            self.sendSubviewToBack(textLabel!)
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
