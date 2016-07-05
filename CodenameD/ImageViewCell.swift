//
//  ImageViewCell.swift
//  DragNDropCollectionView
//
//  Created by Wenxiang Deng on 2/22/16.
//  Copyright © 2016 Wenxiang Deng. All rights reserved.
//

import UIKit

class ImageViewCell: UICollectionViewCell {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var panGesture = UIPanGestureRecognizer()
    var tapGesture = UITapGestureRecognizer()
    var doubleTap = UITapGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //scrollView.minimumZoomScale = 1.0
        //scrollView.maximumZoomScale = 3.0
        scrollView.delegate = self
        
        // where should the gesture added to, cell or imageview
        
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(ImageViewCell.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        
    }
    
    override var bounds: CGRect {
        didSet{
            contentView.frame = bounds
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}

extension ImageViewCell: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        scrollView.contentInset = contentInsetForCurrentScrollView()
    }
    
    func contentInsetForCurrentScrollView() -> UIEdgeInsets {
        let imageViewSize = imageView.frame.size
        let imageSize = imageView.image!.size
        let scrollViewSize = scrollView.bounds.size
        
        let ratio = imageSize.height/imageSize.width
        let expectedHeight = imageViewSize.width * ratio
        let expectedWidth = imageViewSize.height / ratio
        
        let verticalPadding = expectedHeight > imageViewSize.height ? 0 : max((scrollViewSize.height - imageViewSize.height), expectedHeight - imageViewSize.height)/2.0
        let horizontalPadding = expectedWidth > imageViewSize.width ? 0 : max((scrollViewSize.width - imageViewSize.width), expectedWidth - imageViewSize.width)/2.0
        
        return UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        //scrollView.scrollEnabled = scale > 1
        //scrollView.contentInset = contentInsetForCurrentScrollView(atScale: scale)
    }
    
    
    // handle double tap
    func handleDoubleTap(gesture: UITapGestureRecognizer) {
        
        let touchPoint = gesture.locationInView(self)
        NSObject.cancelPreviousPerformRequestsWithTarget(self) //????????????
        
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            // zoom out
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            // zoom in
            var newZoom: CGFloat = scrollView.zoomScale * 3.0
            
            if newZoom >= scrollView.maximumZoomScale {
                newZoom = scrollView.maximumZoomScale
            }
            
            let w = scrollView.frame.size.width / newZoom
            let h = scrollView.frame.size.height / newZoom
            let x = touchPoint.x - (w / 2.0)
            let y = touchPoint.y - (h / 2.0)
            
            let newRect = CGRect(x: x, y: y, width: w, height: h)
            
            scrollView.zoomToRect(newRect, animated:true)
        }
        
        //photoBrowser.hideControlsAfterDelay()
    }
    
    
}



































