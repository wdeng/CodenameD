//
//  CustomTabBar.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/7/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit

class CustomTabBar: UIView {

    // TODO: put buttons to here
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //print(self.superview)
        //print(self.subviews.last)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //print(self.frame)
        //print(self.subviews)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = TabBarSettings.height
        return sizeThatFits
    }
}
