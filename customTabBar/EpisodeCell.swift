//
//  EpisodeCell.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/8/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {

    @IBOutlet weak var episodeThumb: UIImageView!
    
    @IBOutlet weak var playLater: UIButton!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var otherOptions: UIButton!
    
    //@IBOutlet weak var likesNumber: UILabel!
    @IBOutlet weak var durationAndLikes: UILabel!
    @IBOutlet weak var title: UITextView!
    @IBOutlet weak var uploadTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        title.textContainer.lineBreakMode = .ByTruncatingTail
        title.textContainer.maximumNumberOfLines = 2
        episodeThumb.contentMode = .ScaleAspectFill
        episodeThumb.clipsToBounds = true
        
        playLater.imageView?.contentMode = .ScaleAspectFit
        playLater.hidden = true
        save.imageView?.contentMode = .ScaleAspectFit
        save.hidden = true
        
        otherOptions.imageView?.contentMode = .ScaleAspectFit
        
        self.separatorInset = UIEdgeInsets(top: 0, left: bounds.width, bottom: 0, right: 0)
        
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
