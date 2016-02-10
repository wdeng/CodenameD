//
//  AppSettings.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/14/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit


struct AppSettings {
    static let DEBUG_LOG = true
    static let minDBValue: Float = -80.0
    static let minSoundLevel: Double = 0.08
    static let reallySmallNumber: Double = 0.000001
    static let tabBarHeight: CGFloat = 38.0
    
}

struct RecordSettings {
    static let recordedDurationLimit: (Double, Double) = (1.0, 60.0)
    static let audioButtonColor: UIColor = UIColor.grayColor()
    static let recordedAudioCellCornerRadius: CGFloat = 12.0
    static let recordedAudioCellHeight: CGFloat = 38.0
    static func recordedAudioCellInsetForLabel(audioDur: Int) -> CGFloat {
        var inset: CGFloat = 0
        if audioDur < 10 {inset = 20}
        else if audioDur < 100 {inset = 30}
        else {inset = 40}
        
        return inset
    }
    
    static let addedImageCornerRadius: CGFloat = 5.0
    static let selectedPhotoCellHeight: CGFloat = 80.0
    static let imageDeleteButtonWidth: CGFloat = 30.0
    
    static let defaultImageLimit: CGSize = CGSize(width: 720, height: 2000)
    static let thumbImageSize: CGSize = CGSize(width: 165, height: 165)
    
    //for iphone only, iphone is mono input
    static let numberOfChannels:Int = 1
    
    static let minCellBlankWidth: CGFloat = 100.0
    static let minAudioButtonWidth: CGFloat = 32.0
}

struct PlaySoundSetting {
    static let progressBarHeight: CGFloat = 30.0
    
    static let currentEpisodeKey: String = "CurrentPlayingEpisode"
    static let currentEpisodeTime: String = "CurrentPlayingTime"
    static let currentEpisodePlaySpeed: String = "CurrentPlaybackSpeed"
}

enum PlayingSpeed: Float {
    case x100 = 1.0
    case x125 = 1.25
    case x150 = 1.5
    case x200 = 2.0
}

class NumUtils: NSObject {
    class func abbreviateNum(num: Int?) -> String {
        guard let num = num else {return ""}
        guard let n = Double(String(format: "%.3g", Double(num))) else {return ""}
        let digitNum = floor(log10(n))
        
        if num <= 0 {
            return "0"
        } else if digitNum < 4 {
            return "\(num)"
        } else if digitNum < 6 {
            return String(format: "%.3gk", n/pow(10.0, 3))
        } else if digitNum < 9 {
            return String(format: "%.3gm", n/pow(10.0, 6))
        } else {
            let outputNum = Int(Double(num)/pow(10.0,6))
            return "\(outputNum)m"
        }
    }
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
    
    class func getFitRect(image: UIImage, targetRect: CGRect) -> CGRect {
        let s = image.size
        let ratio = s.height/s.width
        
        // fit the targetSize
        let h = min(targetRect.width * ratio, targetRect.height)
        let w = min(targetRect.height / ratio, targetRect.width)
        let x = (targetRect.width - w) / 2
        let y = (targetRect.height - h) / 2
        
        // in targetRect's bounds
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    class func createFitImageFromSize(image: UIImage, targetSize: CGSize = RecordSettings.defaultImageLimit) -> UIImage {
        
        let s = image.size
        let ratio = s.height/s.width
        
        // fill the targetSize
        let h = min(targetSize.width * ratio, targetSize.height)
        let w = min(targetSize.height / ratio, targetSize.width)
        
        //context to get new image
        UIGraphicsBeginImageContext(CGSizeMake(w, h))  //UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(CGRectMake(0, 0, w, h))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //resize finished
        return newImage
        // crop to center
//        let (orgx, orgy) = (h > targetSize.height) ? (0, (h - targetSize.height)/2) : ((w - targetSize.width)/2, 0)
//        // Correct rect size based on the device screen scale
//        let scaledRect = CGRectMake(orgx * newImage.scale, orgy * newImage.scale, targetSize.width * newImage.scale, targetSize.height * newImage.scale);
//        // New CGImage reference based on the input image (self) and the specified rect
//        let imageRef = CGImageCreateWithImageInRect(newImage.CGImage, scaledRect)
//        // Gets an UIImage from the CGImage
//        if let tmp = imageRef {
//            return UIImage(CGImage: tmp, scale: newImage.scale, orientation: newImage.imageOrientation)
//        }
//        else {
//            return nil
//        }
        
    }
    
    class func createCropImageFromSize(image: UIImage?, targetSize: CGSize = RecordSettings.thumbImageSize) -> UIImage? {
        guard let image = image else {return nil}
        let s = image.size
        let ratio = s.height/s.width
        
        // fill the targetSize
        let h = max(targetSize.width * ratio, targetSize.height)
        let w = max(targetSize.height / ratio, targetSize.width)
        let (orgx, orgy) = (h > targetSize.height) ? (0, -(h - targetSize.height)/2) : (-(w - targetSize.width)/2, 0)
        //context to get new image
        UIGraphicsBeginImageContext(CGSizeMake(targetSize.width, targetSize.height))  //UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(CGRectMake(orgx, orgy, w, h))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //resize finished

        return newImage
    }
    
}



struct TabBarSettings {
    static let appStartControllerIndex: Int = 0
    static let height: CGFloat = 44.0
    static var tabWidth: CGFloat {
        get {
            return UIScreen.mainScreen().bounds.width > 400 ? 60.0 : 50.0 // TODO: check the best value
        }
    }
    static var playButtonWidth: CGFloat = 30.0
    static let tabsSelectedBackgroundColor: UIColor = UIColor.whiteColor()
    static let tabsNormalBackgroundColor: UIColor = UIColor.darkGrayColor()
    
    static let tabsNormalColor: UIColor = UIColor.whiteColor()
    static let tabsSelectedColor: UIColor = UIColor.darkGrayColor()
    static let tabsColorStyle: UIImageRenderingMode = .AlwaysTemplate
    static let audioTitleColor: UIColor = UIColor.whiteColor()
    static let audioTitleFont: UIFont = UIFont.systemFontOfSize(11.0)
    static let audioTitleLines: Int = 2 // TODO: how many lines we need
    static let audioButtonBackgroundColor: UIColor = UIColor.grayColor()
    
    // TODO: what is this????
    static func audioTitleFrame(viewBound: CGRect, tabNum: Int) -> CGRect {
        let tabsWidth = CGFloat(tabNum) * tabWidth
        var frame = viewBound
        frame.origin.x = tabsWidth
        frame.size.width = viewBound.width - tabsWidth
        
        return frame
    }
}

struct HomeFeedsSettings {
    static let sectionsInPage: Int = 6
    static let itemsInSection: Int = 3
}

struct GeneralSettings {
    static let compressQuality: CGFloat = 0.5
    static var adsAvailable: Bool = false
}


class AppUtils: NSObject {
    class func durationToClockTime(duration: Double?) ->String? {
        guard let duration = duration else { return nil}
        if duration < 3600 {
            return String(format: "%d:%02d", Int(duration) / 60, Int(duration) % 60)
        }
        else {
            return String(format: "%d:%02d:%02d", Int(duration) / 3600, (Int(duration) % 3600) / 60, (Int(duration) % 3600) % 60)
        }
        
    }
    
    class func switchOnActivityIndicator(activityIndicator: UIActivityIndicatorView, forView view: UIView, ignoreUser: Bool) {
        //activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.center = view.center
        activityIndicator.backgroundColor = UIColor(white: 0.2, alpha: 0.3)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .White
        if let tableView = view as? UITableView {
            tableView.backgroundView = activityIndicator
        } else{
            view.addSubview(activityIndicator)
        }
        activityIndicator.startAnimating()
        if ignoreUser {
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        }
    }
    
    class func displayAlert(title: String, message: String, onViewController vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
            //vc.dismissViewControllerAnimated(true, completion: nil)
            })
        vc.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
}
