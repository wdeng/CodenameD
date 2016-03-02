//
//  TestEpisodeCell.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 3/1/16.
//  Copyright © 2016 Wenxiang Deng. All rights reserved.
//

import UIKit

class TestEpisodeCell: UITableViewCell {

    @IBOutlet weak var timeAndLikes: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //timeAndLikes.text = "bcs"
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    
}
