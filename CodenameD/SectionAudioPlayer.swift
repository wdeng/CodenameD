//
//  PlaySound+SectionPlayer.swift
//  PitchPerfect
//
//  Created by Wenxiang Deng on 12/9/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import AVFoundation
import Parse

struct PlayerInfo {
    static var playSpeed: Float = 1.0
}


public class SectionAudioPlayer: NSObject {
    static let sharedInstance = SectionAudioPlayer()
    private var player: AVPlayer?
    private var periodicTimeObserver: AnyObject?
    
    private(set) var playbackSpeed: PlayingSpeed = .x100
    var sleepCountDown: Double?
    
    var currentEpisode: EpisodeToPlay?
    var currentSpeed: Float?
    var currentDuration: Double? {
        get {
            return player?.currentItem?.asset.duration.seconds
        }
    }
    var isPlaying: Bool? {
        get {
            if player == nil {
                return nil
            }
            else if player!.rate == 0 {
                return false
            }
            else {
                return true
            }
        }
    }
    var currentRate: Float {
        get {
            if let player = player {
                return (player.rate)
            }
            else {
                return -1
            }
        }
    }
    
    var playerIsSeekingTime = false   /// needed because
    var currentTime: Double? {
        get {
            return player?.currentTime().seconds
        }
        set {
            
            playerIsSeekingTime = true
            player?.seekToTime(CMTime(seconds: newValue!, preferredTimescale: 1000)) { (_) in
                self.playerIsSeekingTime = false
                //print("player is ready:\(self.player!.status == .ReadyToPlay), is unknown:\(self.player!.status == .Unknown)")
                NSNotificationCenter.defaultCenter().postNotificationName("AudioPlayerTimeChanged", object: nil, userInfo: ["time": newValue!])
            }
        }
    }
    
    override init() {
        super.init()
        if let data = NSUserDefaults.standardUserDefaults().objectForKey(PlaySoundSetting.currentEpisodeKey) as? NSData {
            if var episode = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? EpisodeToPlay {
                ParseActions.loadEpisode(&episode) {
                    self.currentEpisode = episode
                    self.setPlayerItemWithURL(episode.episodeURL)
                    
                    if let time: Double = NSUserDefaults.standardUserDefaults().doubleForKey(PlaySoundSetting.currentEpisodeTime) {
                        //NSNotificationCenter.defaultCenter().postNotificationName("AudioPlayerTimeChanged", object: nil, userInfo: ["time": time])
                        self.player?.seekToTime(CMTime(seconds: time, preferredTimescale: 1000))
                    }
                }
                
                //currentTime = NSUserDefaults.standardUserDefaults().doubleForKey(PlaySoundSetting.currentEpisodeTime)
                //TODO: set up the Downloaded episode
            }
        }
        
    }
    //TODO: seek track    test in very bad internet status
    
    func setupPlayerWithEpisode(episode: EpisodeToPlay) {
        if let url = episode.episodeURL {
            currentEpisode = episode
            
            let data = NSKeyedArchiver.archivedDataWithRootObject(episode)
            NSUserDefaults.standardUserDefaults().setObject(data, forKey: PlaySoundSetting.currentEpisodeKey)
            setPlayerItemWithURL(url)
        }
    }
    
    func setPlayerItemWithURL(url: NSURL?) {
        
        if let player = player {
            player.removeObserver(self, forKeyPath: "rate", context: nil)
            player.removeObserver(self, forKeyPath: "status", context: nil)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
            player.removeTimeObserver(periodicTimeObserver!)
            periodicTimeObserver = nil
        }
        
        // probably check the NSUserDefault for current playList
        if let url = url {
            player = AVPlayer(URL: url)
            player?.currentItem?.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmTimeDomain //TODO: what is better
            
            //print("\(currentEpisode) is current episode")
            if let title = (currentEpisode?.episodeTitle) {
                NSNotificationCenter.defaultCenter().postNotificationName("AudioPlayerEpisodeDidSet", object: nil, userInfo: ["title": title])
            }
            
            player!.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
            
            // not sure if this is needed
            player!.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
            //print("current status is unknown: \(player!.status == .Unknown)")
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: player!.currentItem)
            
            if periodicTimeObserver == nil {
                periodicTimeObserver = player!.addPeriodicTimeObserverForInterval(CMTime(seconds: PlaySoundSetting.playbackTimerInterval, preferredTimescale: 1000), queue: nil, usingBlock: {(time) in
                    if !self.playerIsSeekingTime {
                        
                        if (self.isPlaying == true) && (self.sleepCountDown != nil) {
                            if self.sleepCountDown > 0 {
                                self.sleepCountDown! -= (PlaySoundSetting.playbackTimerInterval / Double(self.currentRate))
                            } else {
                                self.sleepCountDown = nil
                                self.pause()
                            }
                        }
                        
                        
                        NSNotificationCenter.defaultCenter().postNotificationName("AudioPlayerTimeChanged", object: nil, userInfo: ["time": time.seconds])
                    }
                })
            }
        }
    }
    
    func replaceCurrentPlay(url: NSURL?) {
        if let url = url {
            let item = AVPlayerItem(URL: url)
            if let player = player {
                player.replaceCurrentItemWithPlayerItem(item)
                NSNotificationCenter.defaultCenter().postNotificationName("AudioPlayerEpisodeDidSet", object: nil, userInfo: ["title": (currentEpisode?.episodeTitle)!])
            }
        }
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (keyPath == "rate") && (player != nil) {
            
            NSNotificationCenter.defaultCenter().postNotificationName("AudioPlayerRateChanged", object: nil, userInfo: ["rate": player!.rate])
            
        }
        if (keyPath == "status") && (player != nil) {
            //print("status: \(player!.status.rawValue), is ready: \(player!.status == .ReadyToPlay)")
            if (player!.status == .ReadyToPlay) {
                //print("Player is ready\(player!.currentItem)")
            } else  {
                // something went wrong. player.error should contain some information
            }
        }
    }
    
    func fastForward(time: Double) {
        currentTime! += time
    }
    
    func fastReverse(time: Double) {
        currentTime! -= time
    }
    
    func setPlaySpeed(targetSpeed: PlayingSpeed) {
        playbackSpeed = targetSpeed
        NSNotificationCenter.defaultCenter().postNotificationName("AudioPlayerRateChanged", object: nil, userInfo: ["rate": player!.rate])
        if isPlaying == true {
            play()
        }
    }
    
    func play() {
        if AVAudioSession.sharedInstance().category != AVAudioSessionCategoryPlayback {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback) // if headphone plugged, should be PlayAndRecord
                UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
                
            } catch _ {debugPrint("Audio session error")}
        }
        player?.rate = playbackSpeed.rawValue
    }
    
    func playerDidFinishPlaying(notification: NSNotification) {
        
        // probably dont need to remove all the observers
        debugPrint("finished playing \(notification.object)")  ///  notification.object is player!.currentItem
        NSUserDefaults.standardUserDefaults().removeObjectForKey(PlaySoundSetting.currentEpisodeKey)
        currentTime = 0
    }
    
    func pause() {
        player?.pause()
    }
    
    func playPauseToggle() -> Bool? {
        if isPlaying == nil {
            return nil
        } else if isPlaying! {
            pause()
            return false
        } else {
            play()
            return true
        }
    }
    
}

































