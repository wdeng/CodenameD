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
    //private var sliderIsTracking = false
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    // Tool Bar
    @IBOutlet weak var tools: UIToolbar!
    @IBOutlet weak var moreButton: UIBarButtonItem!
    @IBOutlet weak var playSpeed: UIBarButtonItem!
    @IBOutlet weak var sleepTimer: UIBarButtonItem!
    
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
        
        if progressBar.sliderIsTracking {return}
        if let time = notification.userInfo?["time"] as? Double {
            print(time)
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
                    resetCurrentContentController(i+1, direction: .Forward, animated: true)
                }
            }
            else if newVal < oldVal {
                for i in (newVal ..< oldVal).reverse() {
                    resetCurrentContentController(i, direction: .Reverse, animated: true)
                }
            }
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .AllButUpsideDown
    }
    
    func orientationDidChange() {
        let orientation = UIDevice.currentDevice().orientation
        
        print(orientation.rawValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("orientationDidChange"),
            name: UIDeviceOrientationDidChangeNotification, object: nil)
        
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
    
    func sectionSliderThumbDidChange() {
        audioPlayer.currentTime = progressBar.value
    }
    
    override func viewWillLayoutSubviews() {
        // put progressBar in layoutsubviews so it conform to rotations
        super.viewWillLayoutSubviews()
        progressBar.frame = CGRect(x: 0.0, y: view.frame.height - PlaySoundSetting.progressBarHeight, width: view.frame.width, height: PlaySoundSetting.progressBarHeight)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "AudioPlayerRateChanged", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "AudioPlayerTimeChanged", object: nil)
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





























