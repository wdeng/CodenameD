//
//  CustomHeaderView.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 2/3/16.
//  Copyright © 2016 Wenxiang Deng. All rights reserved.
//

import UIKit

class CustomHeaderView: UIView {
    
    
    @IBOutlet weak var label: UILabel!
    override func layoutSubviews() {
        super.layoutSubviews()
        label.preferredMaxLayoutWidth = label.bounds.width
    }
    
    

}
