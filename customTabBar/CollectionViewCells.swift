//
//  CollectionViewCells.swift
//  DragNDropCollectionView
//
//  Created by Wenxiang Deng on 2/20/16.
//  Copyright © 2016 Wenxiang Deng. All rights reserved.
//

import UIKit

class UIPhotoCell: UICollectionViewCell {
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    override var bounds: CGRect {
        didSet{
            contentView.frame = bounds
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .ScaleAspectFill
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        //selected = true
    }
    
    override var selected: Bool {
        didSet {
            if selected {
                layer.borderColor = UIColor.greenColor().CGColor
                layer.borderWidth = 3
                imageView.alpha = 0.7
                
                //contentView.layer.opacity = 0.7
                // could use custom layout for the selected
                //set image view alpha to be 0.3
                //backgroundColor = UIColor.blueColor()
            } else {
                layer.borderWidth = 0
                imageView.alpha = 1.0
                
                //set image view alpha to be 0
                //backgroundColor = UIColor.brownColor()
            }
        }
    }
}



class UIAudioCell: UICollectionViewCell {
    @IBOutlet weak var textLabel: UILabel!
    
    override var bounds: CGRect {
        didSet{
            contentView.frame = bounds
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10
    }
    
    override var selected: Bool {
        didSet {
            if selected {
                layer.borderColor = UIColor.greenColor().CGColor
                layer.borderWidth = 3
                //backgroundColor = UIColor.blueColor()
            } else {
                layer.borderWidth = 0
                //backgroundColor = UIColor.greenColor()
            }
        }
    }
}
























