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

//TODO: add interactive dismiss
//UIViewControllerContextTransitioning      isInteractive()

class PlaySoundViewController: UIViewController, SectionSliderDelegate {
    var pageViewController: UIPageViewController!
    let progressBar = SectionSlider(frame: CGRectZero)
    let audioPlayer = SectionAudioPlayer.sharedInstance
    var episode: EpisodeToPlay!
    var sectionNum: Int = 0
    //private var updateTime: NSTimer?
    
    @IBOutlet weak var topBackgroundView: UIView!
    
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    
    // Tool Bar
    @IBOutlet weak var tools: UIToolbar!
    @IBOutlet weak var moreButton: UIBarButtonItem!
    @IBOutlet weak var playSpeed: UIBarButtonItem!
    @IBOutlet weak var sleepTimer: UIBarButtonItem!
    @IBOutlet weak var likeUnlike: UIBarButtonItem!
    
    
    private var sleepCountDown: Double?
    
    // Page view
    var pageViewPendingSection = 0
    var pageViewScrollInTransit = false
    
    func sectionPlayerDidChangeRate(notification: NSNotification) {
        if let rate = notification.userInfo?["rate"] as? Float {
            setPlayerForPlayPause(rate)
        }
    }
    func sectionPlayerDidChangeTime(notification: NSNotification) {
        
        //TODO: if multiple countDowns appears, should put this in the section player
        if let countDown = sleepCountDown {
            if countDown > 0 {
                sleepCountDown! -= PlaySoundSetting.playbackTimerInterval
            } else {
                sleepCountDown = nil
                audioPlayer.pause()
                //TODO: setback the button to original
            }
        }
        
        if progressBar.thumbIsTracking {return}
        if let time = notification.userInfo?["time"] as? Double {
            //print(time)
            progressBar.value = time
        }
    }
    
    func setPlayerForPlayPause(rate: Float) {
        if rate == 0 {
            let im = UIImage(named: "play")//?.imageWithRenderingMode(.AlwaysTemplate)
            playPauseButton.setImage(im, forState: .Normal)
            
        } else {
            let im = UIImage(named: "pause")//?.imageWithRenderingMode(.AlwaysTemplate)
            playPauseButton.setImage(im, forState: .Normal)
        }
    }
    
    
    func sectionSliderSectionDidChange(oldVal: Int, newVal: Int) {
        if !pageViewScrollInTransit {
            if newVal > oldVal {
                for i in oldVal ..< newVal {
                    //print("change to NEXT controller")
                    resetCurrentContentController(i+1, direction: .Forward, animated: true)
                }
            }
            else if newVal < oldVal {
                for i in (newVal ..< oldVal).reverse() {
                    //print("change to PREV controller")
                    resetCurrentContentController(i, direction: .Reverse, animated: true)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tools.clipsToBounds = true
        // Needed because we need shadows
        let btnName = functionButtonTemplate("dots")
        btnName.addTarget(self, action: Selector("otherFunctions:"), forControlEvents: .TouchUpInside)
        moreButton.customView = btnName
        
        //progress bar related
        if episode == nil { episode = EpisodeToPlay() }
        if episode.sectionDurations.count == 0 {
            episode.sectionDurations = [0.1]
            episode.imageSets = [[]]
        }
        
        progressBar.maximumValue = episode.sectionDurations.reduce(0, combine: +)
        progressBar.sectionsLengths = episode.sectionDurations
        sectionNum = episode.sectionDurations.count
        
        //progressBar.hidden = true
        
        createPageViewController()
        view.addSubview(progressBar)
        view.bringSubviewToFront(progressBar)
        progressBar.delegate = self
        
        //TODO: background Play should be in section av player
        // setup background play
//        if NSClassFromString("MPNowPlayingInfoCenter") != nil {
//            if let poster = UIImage(named: "IMG_0006.jpg") {
//                let pic = MPMediaItemArtwork(image: poster)
//                let info: [String: AnyObject] = [MPMediaItemPropertyTitle: "Hello this is MKBHD",
//                    MPMediaItemPropertyArtist: "MKBHD",    /// place holder, neeeeeed to change
//                    MPMediaItemPropertyArtwork: pic]
//                
//                MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = info
//            }
//        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback) // if headphone plugged, should be PlayAndRecord
            debugPrint("Receiving remote control events")
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
            
        } catch _ {print("Audio session error")}
        
        //add gradient color to background top
        let gradientOpacity = CAGradientLayer()
        gradientOpacity.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 74)
        gradientOpacity.frame.size.height = 74
        gradientOpacity.colors = [UIColor(white: 0.0, alpha: 0.2).CGColor, UIColor(white: 0.0, alpha: 0.2).CGColor, UIColor(white: 0.0, alpha: 0.12).CGColor, UIColor.clearColor().CGColor]
        gradientOpacity.locations = [0.0, 0.6, 0.8, 1.0]
        
        topBackgroundView.layer.addSublayer(gradientOpacity)
        
        // dismiss button color
        dismissButton.tintColor = UIColor.whiteColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //TODO: set progressbar hidden if player is not ready
        progressBar.sectionSelectedByUser = false
        if let currentTime = audioPlayer.currentTime {
            progressBar.value = currentTime
        } else { progressBar.value = 0.0}
        if audioPlayer.isPlaying == true { setPlayerForPlayPause(audioPlayer.rate) }
        
        progressBar.frame = CGRect(x: 0.0, y: view.frame.height - PlaySoundSetting.progressBarHeight, width: view.frame.width, height: PlaySoundSetting.progressBarHeight)
        let currentSection = progressBar.sectionForLocation(progressBar.positionForValue(progressBar.value))
        
        //print("view will appear current time: \(progressBar.positionForValue(progressBar.value))   value:  \(progressBar.value)   section: \(progressBar.startOfSectionsInFrame)")
        //resetCurrentContentController(currentSection, direction: .Reverse, animated: true)
        progressBar.currentSection = currentSection
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sectionPlayerDidChangeRate:", name: "AudioPlayerRateChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sectionPlayerDidChangeTime:", name: "AudioPlayerTimeChanged", object: nil)
        
        
    }
    
    override func viewWillLayoutSubviews() {
        // put progressBar in layoutsubviews so it conform to rotations
        super.viewWillLayoutSubviews()
        progressBar.frame = CGRect(x: 0.0, y: view.frame.height - PlaySoundSetting.progressBarHeight, width: view.frame.width, height: PlaySoundSetting.progressBarHeight)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //statusBarShouldHide = true
        //self.presentingViewController?.childViewControllers // Parent Controller
        
        ParseActions.setLikeUnlikeButton(likeUnlike, episodeID: episode.episodeId)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "AudioPlayerRateChanged", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "AudioPlayerTimeChanged", object: nil)
    }
    
    func sectionSliderThumbDidChange() {
        audioPlayer.currentTime = progressBar.value
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
        //print("bar current section: \(progressBar.currentSection)")
        
        progressBar.sectionSelectedByUser = false
        audioPlayer.currentTime = progressBar.valueForPosition(progressBar.startOfSectionsInFrame[progressBar.currentSection]) + 0.3 ///TODO: because the length diff for merged audio
    }
    
    
    //MARK: play sound
    
    @IBAction func playPauseAudio(sender: AnyObject) {
        audioPlayer.playPauseToggle()
    }
    
    @IBAction func fastBackwardAudio(sender: AnyObject) {
        audioPlayer.fastReverse(10)
    }
    
    @IBAction func fastForwardAudio(sender: AnyObject) {
        audioPlayer.fastForward(10)
    }
    
    
    @IBAction func dismissPlayer(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}





























