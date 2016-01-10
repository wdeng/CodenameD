//
//  SelectedPhotoCell.swift
//  PitchPerfect
//
//  Created by Wenxiang Deng on 12/3/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit

class SelectedPhotoCell: UITableViewCell {
    
    var imageFullView: UIView!
    @IBOutlet var photoButtons: [UIButton]!
    
    var deleteButtons = [UIButton]()
    
    private weak var currentPhotoButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        for i in 0 ..< photoButtons.count {
            let photoButton = photoButtons[i]
            photoButton.setTitle(nil, forState: .Normal)
            photoButton.layer.cornerRadius = RecordSettings.addedImageCornerRadius
            
            //photoButton.layer.borderWidth = 0.5
            //photoButton.layer.borderColor = UIColor.lightGrayColor().CGColor
            
        }
    }
    
    func getTopView(view: UIView) -> UIView {
        var v = view
        while let t = v.superview {
            v = t
        }
        return v
    }
    // TODO: need to change to better animation
    @IBAction func showPhoto(sender: UIButton) {
        //sender.gestureRecognizers
        let imageView = UIImageView(image: sender.imageView?.image)
        // before zooming in
        let topView = getTopView(self) // view for record scene
        //fullView.frame = topView.convertRect(sender.bounds, fromView: sender)
        imageView.frame = topView.convertRect(sender.frame, fromView: sender.superview) /// get frame in the tableview
        imageView.contentMode = .ScaleAspectFill
        
        imageFullView = UIView(frame: topView.bounds)
        imageFullView.backgroundColor = UIColor.clearColor()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
        
        topView.addSubview(imageFullView)
        imageFullView.addSubview(imageView)
        
        // add delete button to full view
//        let button = UIButton(frame: CGRect(x: 0, y: 0, width: RecordSettings.imageDeleteButtonWidth, height: RecordSettings.imageDeleteButtonWidth))
//        button.setTitle("Del", forState: .Normal)
//        button.translatesAutoresizingMaskIntoConstraints = true
//        imageFullView.addSubview(button)
//        
//        button.frame.origin = CGPointMake(imageFullView.bounds.maxX - button.frame.width - 20, imageFullView.bounds.maxY - button.frame.height - 20)
//        button.autoresizingMask = [.FlexibleLeftMargin, .None, .None, .FlexibleBottomMargin]
//        //[.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
//        deleteButtons.append(button)
        
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            () -> Void in
            self.imageFullView.backgroundColor = UIColor.blackColor()
            imageView.frame = ImageUtils.getFitRect(imageView.image!, targetRect: topView.bounds)
            imageView.layer.cornerRadius = 0
            }
            , completion: nil)
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: "hidePhoto")
        
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        imageFullView.addGestureRecognizer(singleTap)
        imageFullView.userInteractionEnabled = true
        
        currentPhotoButton = sender
        currentPhotoButton.hidden = true
    }
    
    func hidePhoto() {
        if imageFullView == nil {return}
        
        let topView = getTopView(self) // view for record scene
        let f = topView.convertRect(currentPhotoButton.frame, fromView: currentPhotoButton.superview)
        
        let imageView = imageFullView.subviews[0]
        
        let destroyView = {
            (complete: Bool) -> Void in
            self.currentPhotoButton.hidden = false
            self.imageFullView.removeFromSuperview()
            self.imageFullView = nil
        }
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            () -> Void in
            self.imageFullView.backgroundColor = UIColor.clearColor()
            imageView.frame = f
            }
            , completion: destroyView)
    }
    
    
    
}
