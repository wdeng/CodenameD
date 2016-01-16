//
//  CustomTabBarController.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/7/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import Parse

//TODO: add snapkit to custom tab bar for auto layout http://snapkit.io/
class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    var tabs: [UIButton] = [UIButton]()
    var currentTab: UIButton!{
        didSet {
            if oldValue != nil {
                oldValue.selected = false
                oldValue.backgroundColor = TabBarSettings.tabsNormalBackgroundColor
                oldValue.tintColor = TabBarSettings.tabsNormalColor
            }
            currentTab.selected = true
            currentTab.backgroundColor = TabBarSettings.tabsSelectedBackgroundColor
            currentTab.tintColor = TabBarSettings.tabsSelectedColor
        }
    }
    var customTabBar: CustomTabBar!
    let playPauseButton = TabBarPlayButton()
    let audioTitleButton = UIButton()
    
    //player delegate
    func sectionPlayerDidChangeRate(rate: Float) {
        if rate == 0 {
            //TODO: change play button status
            let im = UIImage(named: "play")?.imageWithRenderingMode(TabBarSettings.tabsColorStyle)
            playPauseButton.setImage(im, forState: .Normal)
        } else if rate == 1 {
            let im = UIImage(named: "pause")?.imageWithRenderingMode(TabBarSettings.tabsColorStyle)
            playPauseButton.setImage(im, forState: .Normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //replace tab bar with new tab bars
        var rect = tabBar.frame
        rect.size.height = TabBarSettings.height
        tabBar.removeFromSuperview()
        customTabBar = CustomTabBar(frame: rect)
        customTabBar.backgroundColor = TabBarSettings.tabsNormalBackgroundColor
        view.addSubview(customTabBar)
        //let vc = ProfileViewController()
        //self.addChildViewController(vc)
        
        addButtons(customTabBar)
        currentTab = tabs[TabBarSettings.appStartControllerIndex]
        addPlayerViewToTabBar()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let customTabFrame = CGRect(x: 0, y: view.bounds.height - TabBarSettings.height, width: view.bounds.width, height: TabBarSettings.height)
        customTabBar.frame = customTabFrame
    }
    
    var buttonNames = ["home 1","539","bell","901"]
    func addButtons(barView: UIView) {
        if let vcs = viewControllers {
            for i in 0 ..< vcs.count {
                let button = UIButton()
                
                let x = CGFloat(i) * TabBarSettings.tabWidth
                button.frame = CGRect(x: x, y: 0, width: TabBarSettings.tabWidth, height: barView.bounds.height)
                button.autoresizingMask = [.FlexibleLeftMargin, .FlexibleRightMargin, .None, .None]
                
                let normalImage = UIImage(named: buttonNames[i])?.imageWithRenderingMode(TabBarSettings.tabsColorStyle)
                button.setImage(normalImage, forState: .Normal)
                button.tintColor = UIColor.whiteColor()
                
                let selectedImage = UIImage(named: buttonNames[i])?.imageWithRenderingMode(TabBarSettings.tabsColorStyle)
                button.setImage(selectedImage, forState: .Selected)
                button.imageView?.contentMode = .ScaleAspectFit
                button.adjustsImageWhenHighlighted = false
                
                tabs.append(button)
                barView.addSubview(button)
                button.tag = i
                button.addTarget(self, action: "selectTab:", forControlEvents: .TouchUpInside)
            }
        }
    }
        
    func selectTab(button: UIButton) {
        self.currentTab = button
        // TODO: should put these in a subclass if necessary
        if selectedIndex == button.tag {
            if let vc = viewControllers![selectedIndex] as? UITableViewController {
                if (vc.tableView.numberOfSections < 1) || (vc.tableView.numberOfRowsInSection(0)) < 1 { return }
                let i = NSIndexPath(forRow: 0, inSection: 0)
                vc.tableView.scrollToRowAtIndexPath(i, atScrollPosition: .Top, animated: true)
            }
        } else if let _ = viewControllers![button.tag] as? ProfileViewController {
            ProfileViewController.Options.followText = "Follow"
            ProfileViewController.Options.hideFollowing = true
            ProfileViewController.Options.username = PFUser.currentUser()?.username
            ProfileViewController.Options.userId = PFUser.currentUser()?.objectId
            ProfileViewController.Options.profileName = "Profile Name"
        }
        
        selectedIndex = button.tag
    }
    
    //TODO: need add this when start working on real audio
    func layoutButtons(buttonNumber bn: Int, buttonSize: CGFloat) { // input should be
        // TODO: change to autolayout in code
        
        for i in 0 ..< tabs.count {
            let x = CGFloat(i) * TabBarSettings.tabWidth
            tabs[i].frame = CGRect(x: x, y: 0, width: TabBarSettings.tabWidth, height: customTabBar.bounds.height)
        }
        
        if playPauseButton.hidden {
            
        }
    }
    
    func addPlayerViewToTabBar() {
        //TODO: title should be fixed width not determine by tabs width, have a min width and a max width
        //let tabsWidth = CGFloat(tabs.count) * TabBarSettings.tabWidth
        
        //let w = customTabBar.bounds.width - tabsWidth
        audioTitleButton.frame = TabBarSettings.audioTitleFrame(customTabBar.bounds, tabNum: tabs.count) //CGRect(x: tabsWidth, y: 0, width: w, height: customTabBar.bounds.height)
        audioTitleButton.setTitle("Sony Xperia Z5 Premium: A 4K SmartPhone! #4k #sony", forState: .Normal)
        audioTitleButton.setTitleColor(TabBarSettings.audioTitleColor.colorWithAlphaComponent(0.2), forState: .Highlighted)
        audioTitleButton.setTitleColor(TabBarSettings.audioTitleColor, forState: .Normal)
        audioTitleButton.titleLabel?.lineBreakMode = .ByTruncatingTail
        audioTitleButton.titleLabel?.numberOfLines = TabBarSettings.audioTitleLines
        audioTitleButton.titleLabel?.font = TabBarSettings.audioTitleFont
        audioTitleButton.backgroundColor = TabBarSettings.audioButtonBackgroundColor
        audioTitleButton.titleEdgeInsets.left = 2
        audioTitleButton.titleEdgeInsets.right = TabBarSettings.playButtonWidth
        audioTitleButton.addTarget(self, action: "openPlayer", forControlEvents: .TouchUpInside)
        customTabBar.addSubview(audioTitleButton)
        
        playPauseButton.frame = CGRect(x: customTabBar.bounds.width - TabBarSettings.playButtonWidth, y: 0, width: TabBarSettings.playButtonWidth, height: customTabBar.bounds.height)
        playPauseButton.tintColor = UIColor.whiteColor()
        playPauseButton.imageView?.contentMode = .ScaleAspectFit
        playPauseButton.addTarget(self, action: "playPauseAudio", forControlEvents: .TouchUpInside)
        
        ////////////////////////////////////////////////////////
        ///////////////     THIS IS TEMPORARY     !!!!!!!!!!!!!!
        ////////////////////////////////////////////////////////
        sectionPlayerDidChangeRate(1)
        playPauseButton.progress = 0.85
        
        
        
        customTabBar.addSubview(playPauseButton)
        //TODO: custom tab bar (4 tabs) need refresh
    }
    
    
    //TODO: make sure if audio was interrepted, can correctly display
    func playPauseAudio() {
        SectionPlayer.sharedInstance.playPauseToggle()
    }
    
    func openPlayer() {
        let playerVC = storyboard!.instantiateViewControllerWithIdentifier("SectionPlayer") as! PlaySoundViewController
        
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
            playerVC.modalPresentationStyle = .OverFullScreen
        }
        self.presentViewController(playerVC, animated: true, completion: nil)
    }
    
    
    
    
    //TODO: add delegate for profile delegate
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        print("tab changed \(self.selectedIndex)")
    }
    
    
    
    
    
    
    func viewDidLoad2() {
        let newView = UIView()
        newView.backgroundColor = UIColor.redColor()
        newView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newView)
        let views = ["view": view, "newView": newView]
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[view]-(<=0)-[newView(100)]", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views)
        view.addConstraints(horizontalConstraints)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[view]-(<=0)-[newView(100)]", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: views)
        view.addConstraints(verticalConstraints)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}















