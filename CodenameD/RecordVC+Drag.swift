//
//  VC+Drag.swift
//  DragNDropCollectionView
//
//  Created by Wenxiang Deng on 2/20/16.
//  Copyright © 2016 Wenxiang Deng. All rights reserved.
//

import UIKit

extension RecordingViewController: UIGestureRecognizerDelegate {
    
    
    private struct Drag {
        static var placeholderView: UIView!
        static var sourceIdx: NSIndexPath!
        static var sourceCellCenter: CGPoint!
    }
    
    //The reordering rules between different types of cells
    func customIndexPath(fromIdx: NSIndexPath, toIdx: NSIndexPath, forPoint p: CGPoint) -> NSIndexPath {
        if addedItems.data[fromIdx.item].dynamicType == addedItems.data[toIdx.item].dynamicType {
            return toIdx
        }
        guard let toCell = collectionView.cellForItemAtIndexPath(toIdx) else {return toIdx}
        let midY = toCell.frame.midY
        
        if addedItems.data[toIdx.item] is AudioModel {
            if p.y < midY { //pointInCell.y < toCell.bounds.midY {
                if fromIdx.item < toIdx.item {
                    return NSIndexPath(forItem: toIdx.item - 1, inSection: toIdx.section)
                } else {
                    return NSIndexPath(forItem: toIdx.item, inSection: toIdx.section)
                }
            } else {
                if fromIdx.item < toIdx.item {
                    return NSIndexPath(forItem: toIdx.item, inSection: toIdx.section)
                } else {
                    return NSIndexPath(forItem: toIdx.item + 1, inSection: toIdx.section)
                }
            }
        } else if addedItems.data[toIdx.item] is PhotoModel {
            // get the whole line of photo cells
            var minIdxItem = toIdx.item, maxIdxItem = toIdx.item
            
            let checkingBlockBackward = { (inout idxItem: Int) -> Bool in
                if idxItem >= 0 {
                    let x = (self.addedItems.data[idxItem] is PhotoModel)
                    if x {return true}
                }
                
                idxItem+=1
                return false
            }
            while checkingBlockBackward(&minIdxItem) {
                let backwardCell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: minIdxItem, inSection: toIdx.section))
                
                if backwardCell?.frame.midY == midY {
                    minIdxItem-=1
                } else {
                    minIdxItem+=1
                    break
                }
            }
            
            let checkingBlockForward = { (inout idxItem: Int) -> Bool in
                if idxItem < self.addedItems.data.count {
                    let x = (self.addedItems.data[idxItem] is PhotoModel)
                    if x {return true}
                }
                
                idxItem-=1
                return false
            }
            while checkingBlockForward(&maxIdxItem) {
                let forwardCell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: maxIdxItem, inSection: toIdx.section))
                
                if forwardCell?.frame.midY == midY {
                    maxIdxItem+=1
                } else {
                    maxIdxItem-=1
                    break
                }
            }
            
            if p.y < midY {
                if fromIdx.item < toIdx.item {
                    return NSIndexPath(forItem: minIdxItem-1, inSection: toIdx.section)
                } else {
                    return NSIndexPath(forItem: minIdxItem, inSection: toIdx.section)
                }
            } else {
                if fromIdx.item < toIdx.item {
                    return NSIndexPath(forItem: maxIdxItem, inSection: toIdx.section)
                } else {
                    return NSIndexPath(forItem: maxIdxItem+1, inSection: toIdx.section)
                }
            }
        }
        
        return toIdx
    }
    
    func updateItemLocation(p: CGPoint) {
        var idx = collectionView.indexPathForItemAtPoint(p)
        
        // if there is empty slot of the photo cell, then get the new index path
        if (idx == nil) && (collectionView.cellForItemAtIndexPath(Drag.sourceIdx) is UIPhotoCell) {
            let layout = collectionView.collectionViewLayout as? LeftAlignedLayout
            if let idxPath = layout?.predictedNextIndexPath(forPoint: p) {
                if Drag.sourceIdx.item < (idxPath.item) {
                    idx = NSIndexPath(forItem: idxPath.item-1, inSection: idxPath.section)
                } else {
                    idx = idxPath
                }
            }
        }
        
        if var idx = idx {
            idx = customIndexPath(Drag.sourceIdx, toIdx: idx, forPoint: p)
            if (idx != Drag.sourceIdx) {
                addedItems.data.moveItemAtIndex(Drag.sourceIdx.item, toIndex: idx.item)
                collectionView.moveItemAtIndexPath(Drag.sourceIdx, toIndexPath: idx)
                //print(collectionView.cellForItemAtIndexPath(idx))
                Drag.sourceIdx = idx
                
                if let cell = collectionView.cellForItemAtIndexPath(idx) {
                    Drag.sourceCellCenter = cell.center
                    cell.hidden = true
                }
            }
        }
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.locationInView(collectionView)
        let indexPath = collectionView.indexPathForItemAtPoint(point)
        
        return (indexPath != nil)
    }
    
    func handleLongPress(gesture: UILongPressGestureRecognizer) {
        let point = gesture.locationInView(view) // this is in the content view domain, edge insets doesn't count
        let indexPath = collectionView.indexPathForItemAtPoint(collectionView.convertPoint(point, fromView: view))
        
        
        switch gesture.state {
        case .Began:
            if let indexPath = indexPath {
                guard let cell = collectionView.cellForItemAtIndexPath(indexPath) else {return}
                Drag.sourceIdx = indexPath
                Drag.sourceCellCenter = cell.center
                Drag.placeholderView = RecordingViewController.placeholderFromView(cell)
                Drag.placeholderView.center = view.convertPoint(Drag.sourceCellCenter, fromView: collectionView)
                view.addSubview(Drag.placeholderView)
                cell.hidden = true
                
                UIView.animateWithDuration(0.2, animations: {
                    Drag.placeholderView.center = point
                    Drag.placeholderView.transform = CGAffineTransformMakeScale(1.2, 1.2)
                    Drag.placeholderView.alpha = 0.8
                    }, completion: { (_) in
                        //cell.hidden = true
                })
            }
        case .Changed:
            if (Drag.sourceIdx == nil) || (Drag.placeholderView == nil) {return}
            Drag.placeholderView.center = point
            
            updateItemLocation(collectionView.convertPoint(point, fromView: view))
            
            let toBottom = (view.bounds.maxY - point.y), toTop = (point.y - view.bounds.minY)
            if toBottom < toTop {setupTimer(toBottom, scrollDown: true)}
            else {setupTimer(toTop, scrollDown: false)}
                
        default:
            if (Drag.sourceIdx == nil) || (Drag.placeholderView == nil) {return}
            let cell = collectionView.cellForItemAtIndexPath(Drag.sourceIdx)
                
            UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut,  animations: {
                Drag.placeholderView.center = self.view.convertPoint(Drag.sourceCellCenter, fromView: self.collectionView)
                Drag.placeholderView.transform = CGAffineTransformIdentity
                Drag.placeholderView.alpha = 1.0
                }, completion: { (_) in
                    cell?.hidden = false
                    Drag.sourceIdx = nil
                    Drag.placeholderView.removeFromSuperview()
                    Drag.placeholderView = nil
            })
            updateTime?.invalidate()
        }
    }
    
    class func placeholderFromView(view: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        
        let snapshotView : UIView = UIImageView(image: image)
        snapshotView.layer.masksToBounds = false
        snapshotView.layer.shadowOffset = CGSizeMake(1.0, 5.0)
        snapshotView.layer.shadowRadius = 5.0
        snapshotView.layer.shadowOpacity = 0.4
        return snapshotView
    }
    
    // MARK: scroll at bottom
    func setupTimer(dist: CGFloat, scrollDown: Bool) {
        if dist < 100 {
            if updateTime?.valid != true {
                updateTime = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(RecordingViewController.scrollTableView(_:)), userInfo: ["scrollDown": scrollDown], repeats: true)
            }
        } else {
            updateTime?.invalidate()
        }
    }
    
    func scrollTableView(timer: NSTimer) {
        let t = timer.userInfo?["scrollDown"] as? Bool
        let offset = collectionView.contentOffset.y
        if t == true {
            let maxOffset = collectionView.contentSize.height - collectionView.frame.size.height + collectionView.contentInset.bottom
            if maxOffset - offset < 5 {
                updateTime?.invalidate()
            } else {
                collectionView.contentOffset.y += 4
                //updateItemLocation(Drag.placeholderView.center) // if crash cannot resolve, delete these
            }
        } else {
            let minOffset = -collectionView.contentInset.top
            if offset - minOffset < 5 {
                updateTime?.invalidate()
            } else {
                collectionView.contentOffset.y -= 4
                //updateItemLocation(Drag.placeholderView.center)
            }
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if (Drag.sourceIdx != nil) && (indexPath == Drag.sourceIdx) {
            cell.hidden = true
        } else if cell.hidden {
            cell.hidden = false
        }
        
        if indexPath == audioPlayerCurrentIdxPath {
            if let c = cell as? UIAudioCell {
                c.audioProgressLayer.hidden = false
                if audioPlayer?.playing == true {
                    resumeAnimation(inPlayer: audioPlayer!, forShapeLayer: c.audioProgressLayer, withTargetRect: c.bounds)
                    //print("will resume \(c.audioProgressLayer.hidden), \(c.audioProgressLayer), \(c.audioProgressLayer.bounds)")
                }
            }
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath == audioPlayerCurrentIdxPath {
            if let c = cell as? UIAudioCell {
                if audioPlayer?.playing == true {
                    pauseAnimation(inPlayer: audioPlayer!, forShapeLayer: c.audioProgressLayer, withTargetRect: c.bounds)
                }
                c.audioProgressLayer.hidden = true
            }
            
        }
    }
    
}






















