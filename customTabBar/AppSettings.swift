//
//  AppSettings.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/14/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit

struct TabBarSettings {
    static let appStartControllerIndex: Int = 0
    static let height: CGFloat = 44.0
    static var tabsWidth: CGFloat = 50.0
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
}

struct generalSettings {
    static let compressQuality: CGFloat = 0.5
}


class AppUtils: NSObject {
    class func switchOnActivityIndicator(activityIndicator: UIActivityIndicatorView, forView view: UIView, ignoreUser: Bool) {
        //activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.center = view.center
        activityIndicator.backgroundColor = UIColor(white: 0.2, alpha: 0.2)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        if ignoreUser {
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        }
    }
    
    class func displayAlert(title: String, message: String, onViewController vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            vc.dismissViewControllerAnimated(true, completion: nil)} ) )
        vc.presentViewController(alert, animated: true, completion: nil)
        
    }
}