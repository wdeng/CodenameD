//
//  UICollectionViewLeftAlignedLayout.swift
//  DragNDropCollectionView
//
//  Created by Wenxiang Deng on 2/20/16.
//  Copyright © 2016 Wenxiang Deng. All rights reserved.
//

import UIKit

protocol LeftAlignedLayoutDelegate {
    // Method to ask the delegate for the height of the image
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    // Method to ask the delegate for the height of the annotation text
    func collectionView(collectionView: UICollectionView, shouldTakeAllRowAtIndexPath indexPath: NSIndexPath) -> Bool

}

extension UICollectionViewLayoutAttributes {
    func leftAlignFrameWithSectionInset(sectionInset: UIEdgeInsets) {
        //self.frame.origin.x = sectionInset.left
        var frame = self.frame
        frame.origin.x = sectionInset.left
        self.frame = frame
    }
}

class LeftAlignedLayout: UICollectionViewLayout {
    let maxSpacing = RecordCollectionSettings.itemMinSpacing
    var delegate: LeftAlignedLayoutDelegate!
    
    private var cache = [UICollectionViewLayoutAttributes]()
    
    private var contentHeight: CGFloat = 0.0
    private var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return CGRectGetWidth(collectionView!.bounds) - (insets.left + insets.right)
    }
    
    override func prepareLayout() {
        //if cache.isEmpty {
        // check if it works in insert scene, may need optimizations, check Pinterest from Ray wench
        //TODO: doesn't support screen rotate
        //layout.invalidateLayout()  //  Snapshotting a view that has not been rendered results in an empty snapshot. Ensure your view has been rendered at least once before snapshotting or snapshot after screen updates.
        cache = []
        var xOffset: CGFloat = 0, yOffset: CGFloat = 0
        var rowHeight: CGFloat = 0
        var prevShouldAllRow = false
        
        for item in 0 ..< collectionView!.numberOfItemsInSection(0) {
            let indexPath = NSIndexPath(forItem: item, inSection: 0)
            
            let size = delegate.collectionView(collectionView!, layout: self, sizeForItemAtIndexPath: indexPath)
            
            let currentShouldAllRow = delegate.collectionView(collectionView!, shouldTakeAllRowAtIndexPath: indexPath)
            if (xOffset + size.width > contentWidth) || (currentShouldAllRow) || (prevShouldAllRow) {
                xOffset = 0
                yOffset += rowHeight
                rowHeight = 0
                
                prevShouldAllRow = currentShouldAllRow
            }
            
            let frame = CGRect(x: xOffset, y: yOffset, width: size.width, height: size.height)
            let insetFrame = CGRectInset(frame, maxSpacing, maxSpacing)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            rowHeight = max(rowHeight, size.height)
            xOffset += size.width
        }
        
        contentHeight = yOffset + rowHeight
        //}
    }
    
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if CGRectIntersectsRect(attributes.frame, rect ) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    func predictedNextIndexPath(forPoint p: CGPoint) -> NSIndexPath? {
        let line = CGRect(x: 0, y: p.y, width: collectionView!.bounds.width, height: 0)
        var maxIdx = -1
        for i in 0 ..< cache.count {
            if CGRectIntersectsRect(cache[i].frame, line) {
                maxIdx = i
            }
        }
        
        if maxIdx == -1 {
            return nil
        }
        
        if !delegate.collectionView(collectionView!, shouldTakeAllRowAtIndexPath: NSIndexPath(forItem: maxIdx, inSection: 0)) {
            
            var rect = cache[maxIdx].frame
            rect.origin.x += (rect.size.width + maxSpacing)
            
            if (rect.maxX < collectionView!.bounds.maxX) && (p.x > rect.minX) {
                return NSIndexPath(forItem: maxIdx+1, inSection: 0)
            }
        }
        return nil
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = super.layoutAttributesForItemAtIndexPath(indexPath)
        if (attr == nil) {
            return cache[indexPath.row]
        } else {
            return attr
        }
        
    }
}

























