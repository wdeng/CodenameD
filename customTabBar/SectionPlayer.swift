//
//  PlaySound+SectionPlayer.swift
//  PitchPerfect
//
//  Created by Wenxiang Deng on 12/9/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import AVFoundation

public class SectionPlayer: NSObject {
    static let sharedInstance = SectionPlayer()
    
    private var player: AVPlayer?
    
    //private var player: AVPlayer = AVPlayer(URL: NSURL(string: "http://www.radiobrasov.ro/listen.m3u")!)
    
    func setPlayerItemWithURL(u: NSURL?) {
        
        if player != nil {
            player?.removeObserver(self, forKeyPath: "rate", context: nil)
        }
        
        if u != nil {
            player = AVPlayer(URL: u!)
            
            player!.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions(), context: nil)
            
        }
    }
    
    func replaceCurrentPlay(item: AVPlayerItem) {
        player?.replaceCurrentItemWithPlayerItem(item)
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (keyPath == "rate") && (player != nil) {
            //print("player rate: \(player!.rate)")
            
            NSNotificationCenter.defaultCenter().postNotificationName("SectionPlayerRateChanged", object: nil, userInfo: ["rate": player!.rate])
        }
    }
    
    var currentTime: Double? {
        get {
            //print("currentTime is \(player?.currentTime().seconds)")
            return player?.currentTime().seconds
        }
        set {
            player?.seekToTime(CMTime(seconds: newValue!, preferredTimescale: 1000))
            //TODO: maybe changed to new preferred time scale
            
            //timeScale = self.player.currentItem.asset.duration.timescale;
            //CMTime time = CMTimeMakeWithSeconds(77.000000, timeScale);
            //[self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        }
    }
    
    func fastForward(time: Double) {
        currentTime! += time
    }
    
    func fastReverse(time: Double) {
        currentTime! -= time
    }
    
    func tempHolderForFunction(items: [AVPlayerItem]) {
        //TODO: check how to use queueplayer and
        
        //NSArray *theItems = [NSArray arrayWithObjects:thePlayerItemA, thePlayerItemB, thePlayerItemC, thePlayerItemD, nil];
        //theQueuePlayer = [AVQueuePlayer queuePlayerWithItems:theItems];
        
        //[[NSNotificationCenter defaultCenter] addObserver:self
        //    selector:@selector(playerItemDidReachEnd:)
        //name:AVPlayerItemDidPlayToEndTimeNotification
        //object:[theItems lastObject]];
        //[theQueuePlayer play];
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: items.last)
        
    }
    
    //playerItemDidReachEnd:(NSNotification *)notification {
    
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
    
    func setPlaySpeed(targetSpeed: PlayingSpeed) {
        player?.rate = targetSpeed.rawValue
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func playPauseToggle() -> Bool? {
        // TODO: check if needed to !
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