//
//  AppDelegate.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/7/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import Parse
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Parse.enableLocalDatastore()
        
        Parse.setApplicationId("s8hP8hof2u8B6E301jYQSz0bnMzmzxFg7U8Qah7U", clientKey: "uhp9Z4aHpeojbO9eURsffvA0V8NIV9oniDopkAf5")
        
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)

        let defaultACL = PFACL()
        defaultACL.publicReadAccess = true
        defaultACL.publicWriteAccess = false
        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser:true)
        
//        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//        
//        // Load Main App Screen
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//        HomeScreenVC *homeScreenVC = [storyboard instantiateInitialViewController];
//        self.window.rootViewController = homeScreenVC;
//        [self.window makeKeyAndVisible];
//        
//        // Load Login/Signup View Controller
//        UIViewController *mainLoginVC = [storyboard instantiateViewControllerWithIdentifier:@"MainLoginVC"];
//        [mainLoginVC setModalPresentationStyle:UIModalPresentationFullScreen];
//        [homeScreenVC presentModalViewController:mainLoginVC animated:NO];
        //presentViewController:animated:completion
        
        
        
        return true
    }
    
    
    
    // background play control
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if event?.subtype == UIEventSubtype.RemoteControlPlay {
            print("received remote play")
            SectionAudioPlayer.sharedInstance.play()
        }
        else if event?.subtype == UIEventSubtype.RemoteControlPause {
            print("received remote play")
            SectionAudioPlayer.sharedInstance.pause()
        } else if event?.subtype == UIEventSubtype.RemoteControlTogglePlayPause {
            print("received toggle")
            SectionAudioPlayer.sharedInstance.playPauseToggle()
        } else if event?.subtype == UIEventSubtype.RemoteControlNextTrack {
            print("received next")
            SectionAudioPlayer.sharedInstance.playPauseToggle()
        } else if event?.subtype == UIEventSubtype.RemoteControlPreviousTrack {
            print("received previous")
            SectionAudioPlayer.sharedInstance.playPauseToggle()
        }
    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        if let currentTime = SectionAudioPlayer.sharedInstance.currentTime {
            NSUserDefaults.standardUserDefaults().setDouble(currentTime, forKey: PlaySoundSetting.currentEpisodeTime)
            let speed = SectionAudioPlayer.sharedInstance.rate > 0 ? SectionAudioPlayer.sharedInstance.rate : 1  //TODO: delete this after, and the speed should be a sharedInstance set playing speed
            NSUserDefaults.standardUserDefaults().setFloat(speed, forKey: PlaySoundSetting.currentEpisodePlaySpeed)
        }
        
        
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}























