//
//  EpisodeCell.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/8/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {

    
    @IBOutlet weak var playLater: UIButton!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var otherOptions: UIButton!
    
    @IBOutlet weak var likesNumber: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var uploadTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
