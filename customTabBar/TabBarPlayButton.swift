//
//  TabBarPlayButton.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/11/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit

class TabBarPlayButton: UIButton {
    
    //self!.progressIndicatorView.progress = CGFloat(receivedSize)/CGFloat(expectedSize)
    
    let circlePathLayer = CAShapeLayer()
    let circleRadius: CGFloat = TabBarSettings.playButtonWidth / 2 - 2.0
    
    var progress: CGFloat {
        get {
            return circlePathLayer.strokeEnd
        }
        set {
            if (newValue > 1) {
                circlePathLayer.strokeEnd = 1
            } else if (newValue < 0) {
                circlePathLayer.strokeEnd = 0
            } else {
                circlePathLayer.strokeEnd = newValue
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        circlePathLayer.frame = bounds
        circlePathLayer.lineWidth = 2
        circlePathLayer.fillColor = UIColor.clearColor().CGColor
        circlePathLayer.strokeColor = UIColor.whiteColor().CGColor
        layer.addSublayer(circlePathLayer)
    }
    
    func circlePath() -> UIBezierPath {
        let bezierPath = UIBezierPath(arcCenter:CGPointMake(bounds.midX,bounds.midY), radius:circleRadius, startAngle: CGFloat(M_PI_2) * 3.0, endAngle:CGFloat(M_PI_2) * 3.0 + CGFloat(M_PI) * 2.0, clockwise: true)
        return bezierPath
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        circlePathLayer.frame = bounds
        circlePathLayer.path = circlePath().CGPath
    }
    
    

}
