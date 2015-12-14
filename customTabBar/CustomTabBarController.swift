//
//  CustomTabBarController.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/7/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    var tabs: [UIButton] = [UIButton]() {
        didSet {
            tabsShouldReset = true
        }
    }
    var tabsShouldReset = false
    var currentTab: UIButton!{
        didSet {
            if oldValue != nil {
                oldValue.selected = false
                oldValue.backgroundColor = tabBarTabsNormalBackgroundColor
                oldValue.tintColor = tabBarTabsNormalColor
            }
            currentTab.selected = true
            currentTab.backgroundColor = tabBarTabsSelectedBackgroundColor
            currentTab.tintColor = tabBarTabsSelectedColor
        }
    }
    var customTabBar: UIView!
    let playPauseButton = UIButton()
    let audioTitleButton = UIButton()
    
    //player delegate
    func sectionPlayerDidChangeRate(rate: Float) {
        if rate == 0 {
            //TODO: change play button status
            let im = UIImage(named: "play")?.imageWithRenderingMode(tabBarTabsColorStyle)
            playPauseButton.setImage(im, forState: .Normal)
        } else if rate == 1 {
            let im = UIImage(named: "pause")?.imageWithRenderingMode(tabBarTabsColorStyle)
            playPauseButton.setImage(im, forState: .Normal)
        }
    }
    
    
    //TODO: put in app settings
    let appStartControllerIndex: Int = 0
    let tabBarHeight: CGFloat = 38.0
    var tabBarTabsWidth: CGFloat = 50.0
    var playButtonWidth: CGFloat = 30.0
    let tabBarTabsSelectedBackgroundColor: UIColor = UIColor.whiteColor()
    let tabBarTabsNormalBackgroundColor: UIColor = UIColor.darkGrayColor()
    
    let tabBarTabsNormalColor: UIColor = UIColor.whiteColor()
    let tabBarTabsSelectedColor: UIColor = UIColor.darkGrayColor()
    let tabBarTabsColorStyle: UIImageRenderingMode = .AlwaysTemplate
    let audioTitleColor: UIColor = UIColor.whiteColor()
    let audioTitleFont: UIFont = UIFont.systemFontOfSize(11.0)
    let audioTitleLines: Int = 2
    let audioButtonBackgroundColor: UIColor = UIColor.grayColor()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //replace tab bar with new tab bars
        let rect = tabBar.frame
        tabBar.removeFromSuperview()
        customTabBar = UIView(frame: rect)
        customTabBar.backgroundColor = tabBarTabsNormalBackgroundColor
        view.addSubview(customTabBar)
        
        addButtons(customTabBar)
        currentTab = tabs[appStartControllerIndex]
        
        //TODO: probably change location
        addPlayerViewToTabBar()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let customTabFrame = CGRect(x: 0, y: view.bounds.height - tabBarHeight, width: view.bounds.width, height: tabBarHeight)
        customTabBar.frame = customTabFrame
    }
    
    var buttonNames = ["home 1","539","bell","901"]
    func addButtons(barView: UIView) {
        if let vcs = viewControllers {
            for i in 0 ..< vcs.count {
                let button = UIButton()
                
                //tabBarTabsWidth = barView.frame.size.width / CGFloat(vcs.count)
                
                let x = CGFloat(i) * tabBarTabsWidth
                
                // TODO: change to autolayout in code
                button.frame = CGRect(x: x, y: 0, width: tabBarTabsWidth, height: barView.bounds.height)
                
                let normalImage = UIImage(named: buttonNames[i])?.imageWithRenderingMode(tabBarTabsColorStyle)
                button.setImage(normalImage, forState: .Normal)
                button.tintColor = UIColor.whiteColor()
                
                let selectedImage = UIImage(named: buttonNames[i])?.imageWithRenderingMode(tabBarTabsColorStyle)
                button.setImage(selectedImage, forState: .Selected)
                button.imageView?.contentMode = .ScaleAspectFit
                button.adjustsImageWhenHighlighted = false
                
                tabs.append(button)
                barView.addSubview(button)
                button.tag = i
                button.addTarget(self, action: "selectTab:", forControlEvents: .TouchUpInside)
            }
        }
        tabsShouldReset = false
    }
        
    func selectTab(button: UIButton) {
        self.currentTab = button
        self.selectedIndex = button.tag
    }
    
    //TODO: need add this when start working on real audio
    func layoutButtons(buttonNumber bn: Int, buttonSize: CGFloat) { // input should be
        // buttons frame won't be set, but call this when needed
        
        if playPauseButton.hidden {
            
        }
    }
    
    func addPlayerViewToTabBar() {
        //TODO: title should be fixed width not determine by tabs width, have a min width and a max width
        let tabsWidth = CGFloat(tabs.count) * tabBarTabsWidth
        
        let w = customTabBar.bounds.width - tabsWidth
        audioTitleButton.frame = CGRect(x: tabsWidth, y: 0, width: w, height: customTabBar.bounds.height)
        
        audioTitleButton.setTitle("Sony Xperia Z5 Premium: A 4K SmartPhone! #4k #sony", forState: .Normal)
        audioTitleButton.setTitleColor(audioTitleColor.colorWithAlphaComponent(0.2), forState: .Highlighted)
        audioTitleButton.setTitleColor(audioTitleColor, forState: .Normal)
        audioTitleButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        audioTitleButton.titleLabel?.numberOfLines = audioTitleLines
        audioTitleButton.titleLabel?.font = audioTitleFont
        audioTitleButton.backgroundColor = audioButtonBackgroundColor
        audioTitleButton.titleEdgeInsets.left = 2
        audioTitleButton.titleEdgeInsets.right = playButtonWidth
        audioTitleButton.addTarget(self, action: "openPlayer", forControlEvents: .TouchUpInside)
        customTabBar.addSubview(audioTitleButton)
        
        playPauseButton.frame = CGRect(x: customTabBar.bounds.width - playButtonWidth, y: 0, width: playButtonWidth, height: customTabBar.bounds.height)
        playPauseButton.tintColor = UIColor.whiteColor()
        playPauseButton.imageView?.contentMode = .ScaleAspectFit
        //TODO: add animations if we want progress indicator around playButton
        playPauseButton.addTarget(self, action: "playPauseAudio", forControlEvents: .TouchUpInside)
        customTabBar.addSubview(playPauseButton)
        //TODO: custom tab bar (4 tabs) need refresh
    }
    
    
    //TODO: make sure if audio was interrepted, can correctly display
    func playPauseAudio() {
        print("play button tapped")
        return
    }
    
    func openPlayer() {
        print("should instantiate player controller")
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}
