//
//  AppUtils.swift
//  DragNDropCollectionView
//
//  Created by Wenxiang Deng on 2/23/16.
//  Copyright © 2016 Wenxiang Deng. All rights reserved.
//

import UIKit

class RecordingModel: NSObject {
    var data = [AnyObject]()
    var audioDurations = [Double]()
}

class ImageUtils: NSObject {
    
    class func getFillSize(image: UIImage, targetSize: CGSize) -> CGSize {
        let s = image.size
        let ratio = s.height/s.width
        
        // fill the targetSize
        let h = max(targetSize.width * ratio, targetSize.height)
        let w = max(targetSize.height / ratio, targetSize.width)
        
        return CGSize(width: w, height: h)
    }
    
    class func getFillRect(image: UIImage, targetRect: CGRect) -> CGRect {
        let size = ImageUtils.getFillSize(image, targetSize: targetRect.size)
        let x = (targetRect.width - size.width) / 2 - targetRect.origin.x
        let y = (targetRect.height - size.height) / 2 - targetRect.origin.y
        let origin = CGPoint(x: x, y: y)
        
        return CGRect(origin: origin, size: size)
        
    }
    
    class func getFitRect(image: UIImage, targetRect: CGRect) -> CGRect {
        let s = image.size
        let ratio = s.height/s.width
        
        // fit the targetSize
        let h = min(targetRect.width * ratio, targetRect.height)
        let w = min(targetRect.height / ratio, targetRect.width)
        let x = (targetRect.width - w) / 2 + targetRect.origin.x
        let y = (targetRect.height - h) / 2 + targetRect.origin.y
        
        // in targetRect's bounds
        return CGRect(x: x, y: y, width: w, height: h)
    }
}

class ButtonUtils: NSObject {
    class func addShadow(btn: UIView) {
        btn.layer.shadowOffset = CGSize(width: 0, height: 0)
        btn.layer.shadowRadius = 5.0
        btn.layer.shadowOpacity = 0.7
        btn.layer.shadowColor = UIColor.blackColor().CGColor
    }
    
}

extension Array {
    
    func photoBool() -> [Bool] {
        var bool: [Bool] = []
        for i in self {
            bool.append(i is PhotoModel)
        }
        
        return bool
    }
    
    // the number Index of the photomodels in model array
    func photoIdxList() -> [Int] {
        var list = [Int]()
        
        for i in 0 ..< self.count {
            if self[i] is PhotoModel {
                list.append(i)
            }
        }
        
        return list
    }
    
}