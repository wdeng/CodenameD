//
//  CellGestureHandler.swift
//  DragNDropCollectionView
//
//  Created by Wenxiang Deng on 2/24/16.
//  Copyright © 2016 Wenxiang Deng. All rights reserved.
//

import UIKit


extension ImageCollectionViewController: UIGestureRecognizerDelegate {
    //TODO: when touch begins, hide the button
    
    private struct Pan {
        static var prevPoint: CGPoint!
        static var originPoint: CGPoint!
    }
    
    // Pan gesture
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let g = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = g.velocityInView(g.view)
            let shouldBegin = fabs(velocity.y) > 2*fabs(velocity.x)
            return shouldBegin
        } else {
            return false
        }
    }
    
    func handlePan(gesture: UIPanGestureRecognizer) {
        //TODO: integrate with UIViewControllerAnimatedTransitioning
        
        if UIApplication.sharedApplication().statusBarOrientation.isLandscape {
            self.dismissViewControllerAnimated(true, completion: nil)  // because parent view is not vertical
            return
        }
        
        switch gesture.state {
        case .Began:
            if let cell = currentCell {
                let currentIdxPath = collectionView.indexPathForCell(cell)!
                currentParentIndexPath = NSIndexPath(forItem: model.data.photoIdxList()[currentIdxPath.item], inSection: 0)
                let topView = view
                //view.layer.removeAllAnimations()
                
                placeHoldViewForAnimation = ImageCollectionViewController.placeHolderImageView(forImageView: cell.imageView, presentingView: topView)
                placeHoldViewForAnimation.layer.masksToBounds = false
                topView.addSubview(placeHoldViewForAnimation)
                Pan.originPoint = placeHoldViewForAnimation.frame.origin
                
                cell.hidden = true
                delegate?.imageViewerWillDisappear?(atIndexPath: currentParentIndexPath)
                
                UIView.animateWithDuration(0.35,
                    delay: 0,
                    options: [.BeginFromCurrentState, .CurveEaseInOut],
                    animations: {
                        self.collectionView.alpha = 0.0
                        self.placeHoldViewForAnimation.layer.shadowOffset = CGSizeMake(3.0, 8.0)
                        self.placeHoldViewForAnimation.layer.shadowRadius = 10.0
                        self.placeHoldViewForAnimation.layer.shadowOpacity = 0.8
                    }) {_ in}
            }
            
        case .Changed:
            if placeHoldViewForAnimation == nil { return }
            let point = gesture.translationInView(placeHoldViewForAnimation.superview)
            placeHoldViewForAnimation.frame.origin.x = Pan.originPoint.x + point.x
            placeHoldViewForAnimation.frame.origin.y = Pan.originPoint.y + point.y
        case .Ended:
            if placeHoldViewForAnimation == nil { return }
            let velocity = gesture.velocityInView(gesture.view)
            let pointY = gesture.translationInView(placeHoldViewForAnimation.superview).y
            
            if ((velocity.y < 0) != (pointY < 0)) || (abs(pointY) < 20.0) {
                UIView.animateWithDuration(0.25,
                    delay: 0, options: [.BeginFromCurrentState, .CurveEaseInOut],
                    animations: {
                        self.collectionView.alpha = 1.0
                        self.placeHoldViewForAnimation.frame.origin = Pan.originPoint
                        self.placeHoldViewForAnimation.layer.shadowOpacity = 0.0
                    }) { (completed) in
                        self.delegate?.imageViewerDidAppear?(atIndexPath: self.currentParentIndexPath)
                        self.placeHoldViewForAnimation.removeFromSuperview()
                        self.placeHoldViewForAnimation = nil
                        self.currentCell?.hidden = false
                }
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        default:    // failed or canceled
            debugPrint("failed")
            if orientationBeforeDismiss == .Unknown {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    // single tap gesture
    func handleSingleTap(gesture: UITapGestureRecognizer) {
        NSObject.cancelPreviousPerformRequestsWithTarget(self) //????????????
        self.dismissViewControllerAnimated(true) {}
    }
}
























