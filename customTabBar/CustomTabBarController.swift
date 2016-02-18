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
class CustomTabBarController: UITabBarController {
    
    @IBOutlet weak var recordButton: UIBarButtonItem!
    
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
    let audioPlayer = SectionAudioPlayer.sharedInstance
    
    //player delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        //replace tab bar with new tab bars
        var rect = tabBar.frame
        rect.size.height = TabBarSettings.height
        tabBar.removeFromSuperview()
        customTabBar = CustomTabBar(frame: rect)
        customTabBar.backgroundColor = TabBarSettings.tabsNormalBackgroundColor
        view.addSubview(customTabBar)
        
        addTabs(customTabBar)
        currentTab = tabs[TabBarSettings.appStartControllerIndex]
        addPlayerViewToTabBar()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sectionPlayerDidChangeRate:", name: "AudioPlayerRateChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sectionPlayerDidChangeTime:", name: "AudioPlayerTimeChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sectionPlayerDidSetEpisode:", name: "AudioPlayerEpisodeDidSet", object: nil)
        
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let customTabFrame = CGRect(x: 0, y: view.bounds.height - TabBarSettings.height, width: view.bounds.width, height: TabBarSettings.height)
        customTabBar.frame = customTabFrame
        layoutTabBar()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "AudioPlayerRateChanged", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "AudioPlayerTimeChanged", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "AudioPlayerEpisodeDidSet", object: nil)

    }
    
    func sectionPlayerDidChangeRate(notification: NSNotification) {
        if let rate = notification.userInfo?["rate"] as? Float {
            if rate == 0 {
                //TODO: change play button status
                let im = UIImage(named: "play")?.imageWithRenderingMode(TabBarSettings.tabsColorStyle)
                playPauseButton.setImage(im, forState: .Normal)
            } else if rate > 0 {
                let im = UIImage(named: "pause")?.imageWithRenderingMode(TabBarSettings.tabsColorStyle)
                playPauseButton.setImage(im, forState: .Normal)
            }
        }
    }
    func sectionPlayerDidChangeTime(notification: NSNotification) {
        if let time = notification.userInfo?["time"] as? Double {
            if let dur = audioPlayer.currentDuration {
                playPauseButton.progress = CGFloat(time / dur)
            } else {
                playPauseButton.progress = 0
            }
        }
    }
    
    var buttonNames = ["home 1","539","bell","901"]
    func addTabs(barView: UIView) {
        if let vcs = viewControllers {
            for i in 0 ..< vcs.count {
                let button = UIButton()
                
                //let x = CGFloat(i) * TabBarSettings.tabWidth
                //button.frame = CGRect(x: x, y: 0, width: TabBarSettings.tabWidth, height: barView.bounds.height)
                
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
        if selectedIndex == button.tag {
            if let vc = viewControllers![selectedIndex] as? UITableViewController {
                if (vc.tableView.numberOfSections < 1) || (vc.tableView.numberOfRowsInSection(0)) < 1 { return }
                let i = NSIndexPath(forRow: 0, inSection: 0)
                vc.tableView.scrollToRowAtIndexPath(i, atScrollPosition: .Top, animated: true)
            }
        } else if let vc = viewControllers![button.tag] as? ProfileViewController {
            
            let options : [String : AnyObject?] = [
                UserProfileKeys.UserID : PFUser.currentUser()?.objectId,
                UserProfileKeys.Username : PFUser.currentUser()?.username,
                //UserProfileKeys.Name : "Profile Name",
                UserProfileKeys.Intro : "Hello Hello Hello, How are you? I'm fine thank you and you?",
                UserProfileKeys.Weblink : "www.facebook.com",
                UserProfileKeys.ShouldHideNavOfTabBar : false
            ]
            vc.options = options
        }
        
        selectedIndex = button.tag
    }
    
    func layoutTabBar() {
        // TODO: change to autolayout in code
        var tabWid = TabBarSettings.tabWidth
        
        if audioPlayer.currentEpisode == nil {
            tabWid = view.bounds.width / CGFloat(tabs.count)
            audioTitleButton.hidden = true
        } else {
            audioTitleButton.hidden = false
            audioTitleButton.frame = TabBarSettings.audioTitleFrame(customTabBar.bounds, tabNum: tabs.count)
            playPauseButton.frame = CGRect(x: audioTitleButton.bounds.width - TabBarSettings.playButtonWidth, y: 0, width: TabBarSettings.playButtonWidth, height: audioTitleButton.bounds.height)
        }
        
        for i in 0 ..< tabs.count {
            let x = CGFloat(i) * tabWid
            tabs[i].frame = CGRect(x: x, y: 0, width: tabWid, height: customTabBar.bounds.height)
        }
    }
    
    func sectionPlayerDidSetEpisode(notification: NSNotification) {
        if let title = notification.userInfo?["title"] as? String {
            audioTitleButton.setTitle(title, forState: .Normal)
            view.setNeedsLayout()
        }
    }
    
    //TODO: add notifications and then change the layout
    
    
    
    func addPlayerViewToTabBar() {
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
        
        playPauseButton.tintColor = UIColor.whiteColor()
        playPauseButton.imageView?.contentMode = .ScaleAspectFit
        playPauseButton.addTarget(self, action: "playPauseAudio", forControlEvents: .TouchUpInside)
        playPauseButton.progress = 0
        
        audioTitleButton.addSubview(playPauseButton)
    }
    
    
    //TODO: make sure if audio was interrepted, can correctly display
    func playPauseAudio() {
        audioPlayer.playPauseToggle()
    }
    
    func openPlayer() {
        let playerVC = storyboard!.instantiateViewControllerWithIdentifier("SectionAudioPlayer") as! PlaySoundViewController
        playerVC.episode = audioPlayer.currentEpisode
        
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
            playerVC.modalPresentationStyle = .OverFullScreen
        }
        self.presentViewController(playerVC, animated: true, completion: nil)
    }
    
    
    
    
  
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}















