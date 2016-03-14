//
//  ImageViewTransition.swift
//  DragNDropCollectionView
//
//  Created by Wenxiang Deng on 2/22/16.
//  Copyright © 2016 Wenxiang Deng. All rights reserved.
//

import UIKit

class CustomCollectionView: UICollectionView {
    override func layoutSubviews() {
        super.layoutSubviews()
        //print("will layout subviews: \(self.frame)")
    }
}

enum TransitionType {
    case Present
    case Dismiss
}

class ImageViewerTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let dur: NSTimeInterval
    private let transType: TransitionType
    
    init(duration: NSTimeInterval, transitType: TransitionType) {
        dur = duration
        transType = transitType
    }
    
    // TODO: why? who load this?
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        
        return dur
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        
        if let vc = toVC as? ImageCollectionViewController {
            vc.view.frame = UIScreen.mainScreen().bounds
            let container = transitionContext.containerView()
            container?.addSubview(vc.view)
            
            vc.performPresentAnimation() { finished in
                transitionContext.completeTransition(finished)
            }
        } else if let vc = fromVC as? ImageCollectionViewController {
            vc.performDismissAnimation() { (finished) in
                transitionContext.completeTransition(finished)
                //toVC!.view.layoutIfNeeded()
            }
        }
        
    }
    
    
}














































