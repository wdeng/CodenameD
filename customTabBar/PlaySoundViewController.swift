//
//  PlaySoundViewController.swift
//  PitchPerfect
//
//  Created by Wenxiang Deng on 11/5/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MediaPlayer



class PlaySoundViewController: UIViewController, UIPageViewControllerDataSource,UIPageViewControllerDelegate, SectionSliderDelegate {
    //TODO: why page view scrolls at first
    private var pageViewController: UIPageViewController!
    let progressBar = SectionSlider(frame: CGRectZero)
    let audioPlayer = SectionPlayer.sharedInstance
    var playingSections: AudioMerger = AudioMerger()
    private var updateTime: NSTimer?
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    func sectionPlayerDidChangeRate(notification: NSNotification) {
        if notification.userInfo == nil {
            return
        }
        if let rate = notification.userInfo!["rate"] as? Float {
            setPlayerForPlayPause(rate)
        }
    }
    
    func setPlayerForPlayPause(rate: Float) {
        if rate == 0 {
            //TODO: change play button status
            let im = UIImage(named: "play")//?.imageWithRenderingMode(.AlwaysTemplate)
            playPauseButton.setImage(im, forState: .Normal)
            updateTime?.invalidate()
            progressBar.value = audioPlayer.currentTime!
            
        } else {
            let im = UIImage(named: "pause")//?.imageWithRenderingMode(.AlwaysTemplate)
            playPauseButton.setImage(im, forState: .Normal)
            if updateTime?.valid != true {
                updateTime = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateSlider", userInfo: nil, repeats: true)
            }
        }
    }
    
    func updateSlider() {
        progressBar.value = audioPlayer.currentTime!
    }
    
    
    var audioFile:AVAudioFile!
    private let progressBarHeight: CGFloat = 30.0
    
    func sectionSliderSectionDidChange(oldVal: Int, newVal: Int) {
        if !pageViewScrollInTransit {
            if newVal > oldVal {
                for i in oldVal ..< newVal {
                    resetCurrentContentController(i+1, direction: .Forward)
                }
            }
            else if newVal < oldVal {
                for i in (newVal ..< oldVal).reverse() {
                    resetCurrentContentController(i, direction: .Reverse)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createPageViewController()
        
        //progress bar related
        var duration = 1.0
        for i in playingSections.imageSets {
            progressBar.sectionsLengths.append(i.sectionDuration)
            duration += i.sectionDuration
        }
        progressBar.maximumValue = duration
        view.addSubview(progressBar)
        view.bringSubviewToFront(progressBar)
        progressBar.delegate = self
        
        
        //TODO: background Play should not be in this controller
        // setup background play
        if NSClassFromString("MPNowPlayingInfoCenter") != nil {
            if let poster = UIImage(named: "IMG_0006.jpg") {
                let pic = MPMediaItemArtwork(image: poster)
                let info: [String: AnyObject] = [MPMediaItemPropertyTitle: "Hello this is MKBHD",
                    MPMediaItemPropertyArtist: "MKBHD",    /// place holder, neeeeeed to change
                    MPMediaItemPropertyArtwork: pic]
                
                MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = info
            }
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback) // if headphone plugged, should be PlayAndRecord
            print("Receiving remote control events")
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
            
        } catch _ {print("Audio session error")}
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        progressBar.sectionSelectedByUser = false
        if let currentTime = audioPlayer.currentTime {
            progressBar.value = currentTime
        } else { progressBar.value = 0.0}
        print(progressBar.currentSection)
        if audioPlayer.isPlaying == true { setPlayerForPlayPause(audioPlayer.rate) }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sectionPlayerDidChangeRate:", name: "SectionPlayerRateChanged", object: nil)  //TODO:  see if object useful
    }
    
    func sectionSliderThumbDidBeginTrack() {
        if audioPlayer.isPlaying != true {return}
        updateTime?.invalidate()
    }
    
    func sectionSliderThumbDidChange() {
        audioPlayer.currentTime = progressBar.value
        //if !progressBar.sectionSelectedByUser {hideSectionJumping = true}
    }
    
    func sectionSliderThumbDidEndTrack() {
        if audioPlayer.isPlaying != true {return}
        
        if updateTime?.valid != true {
            updateTime = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateSlider", userInfo: nil, repeats: true)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        // put progressBar in layoutsubviews so it conform to rotations
        super.viewDidLayoutSubviews()
        progressBar.frame = CGRect(x: 0.0, y: view.frame.height - progressBarHeight, width: view.frame.width, height: progressBarHeight)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "SectionPlayerRateChanged", object: nil)
        updateTime?.invalidate()
    }
    
    
    //MARK: Page View
    private func createPageViewController() {
        pageViewController = storyboard!.instantiateViewControllerWithIdentifier("PageController") as! UIPageViewController
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        let firstController = (playingSections.imageSets.count > progressBar.currentSection) ? viewControllerAtIndex(progressBar.currentSection) : viewControllerAtIndex(0)
        let startingViewControllers = [firstController]
            
        pageViewController.setViewControllers(startingViewControllers, direction: .Forward, animated: false, completion: nil)
        
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
        print(progressBar.currentSection)
    }
    
    private func resetCurrentContentController(index: Int, direction dir: UIPageViewControllerNavigationDirection) {
        let currentVC = (playingSections.imageSets.count > index) ? viewControllerAtIndex(index) : viewControllerAtIndex(0)
        pageViewController.setViewControllers([currentVC], direction: dir, animated: true, completion: nil)
        
    }
    
    func viewControllerAtIndex(index: Int) -> ImageTableContentController {
        if index < playingSections.imageSets.count {
            let vc = storyboard?.instantiateViewControllerWithIdentifier("ImageTableVC") as! ImageTableContentController
            vc.images = playingSections.imageSets[index].images
            vc.itemIndex = index
            
            return vc
        }
        
        return ImageTableContentController()
        
    }
    
    //MARK: UIPageViewController DataSource and Delegate
    private var pendingSection = 0
    private var pageViewScrollInTransit = false
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! ImageTableContentController
        
        if itemController.itemIndex > 0 {
            return viewControllerAtIndex(itemController.itemIndex-1)
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! ImageTableContentController
        
        if itemController.itemIndex + 1 < playingSections.imageSets.count {
            return viewControllerAtIndex(itemController.itemIndex+1)
        }
        return nil
    }
    
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        pendingSection = (pendingViewControllers.first as! ImageTableContentController).itemIndex
        progressBar.sectionSelectedByUser = true
        pageViewScrollInTransit = true
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        let currentSection = progressBar.sectionForLocation(progressBar.positionForValue(progressBar.value))
        if completed {
            progressBar.currentSection = pendingSection
        }
        else if finished {
            //If didn't successfully finished
        }
        
        pageViewScrollInTransit = false
        if currentSection == progressBar.currentSection {
            progressBar.sectionSelectedByUser = false
            //hideSectionJumping = true
        }
    }
    
    //MARK: hook page view to progressBar
    
    func sliderSelectedStatusDidChanged(oldVal: Bool, newVal: Bool) {
        if newVal == oldVal { return }
        else if newVal == false {
            dismissSection.hidden = true
            jumpToSection.hidden = true
        } else {
            dismissSection.hidden = false
            jumpToSection.hidden = false
        }
    }
    
    @IBOutlet weak var dismissSection: UIButton!
    @IBOutlet weak var jumpToSection: UIButton!
    
    @IBAction func dismissSelectedSection(sender: AnyObject) {
        progressBar.sectionSelectedByUser = false
        
        let l = progressBar.positionForValue(progressBar.value)
        
        progressBar.currentSection = progressBar.sectionForLocation(l)
    }
    
    @IBAction func jumpToSelectedSection(sender: AnyObject) {
        progressBar.sectionSelectedByUser = false
        
        progressBar.value = progressBar.valueForPosition(progressBar.startOfSectionsInFrame[progressBar.currentSection])
        audioPlayer.currentTime = progressBar.value + 0.2 ///TODO: because the length diff for merged audio
    }
    
    
    //MARK: play sound
    
    @IBAction func playPauseAudio(sender: AnyObject) {
        audioPlayer.playPauseToggle()
    }
    
    
    
    @IBAction func dismissPlayer(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
