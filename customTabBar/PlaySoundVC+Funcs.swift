//
//  PlaySoundViewController+BottomButtons.swift
//  PitchPerfect
//
//  Created by Wenxiang Deng on 12/13/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import Parse

extension PlaySoundViewController {
    
    func functionButtonTemplate(withName: String) -> UIButton {
        let btn = UIButton()
        let im = UIImage(named: withName)?.imageWithRenderingMode(TabBarSettings.tabsColorStyle)
        btn.tintColor = UIColor.whiteColor()
        btn.setImage(im, forState: .Normal)
        btn.frame = CGRectMake(0, 0, 50, 44)
        btn.imageView?.contentMode = .ScaleAspectFit
        btn.bounds = btn.bounds.insetBy(dx: 10, dy: 6)
        
        btn.layer.shadowOffset = CGSize(width: 0, height: 0)
        btn.layer.shadowRadius = 5.0
        btn.layer.shadowOpacity = 0.7
        //btn.layer.shadowColor = UIColor.blackColor().CGColor
        //button with image and text
        //http://stackoverflow.com/questions/3903018/how-to-have-a-uibarbuttonitem-with-both-image-and-text
        //http://stackoverflow.com/questions/11717219/uibutton-image-text-ios    set image as well as title
        return btn
    }
    
    
    func otherFunctions(sender: AnyObject) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let shareAct = UIAlertAction(title: "Share...", style: .Default) { (action) in
            
        }
        alertController.addAction(shareAct)
        
        let downAct = UIAlertAction(title: "Download", style: .Default) { (action) in
            
        }
        downAct.enabled = false
        alertController.addAction(downAct)
        
        let laterAct = UIAlertAction(title: "Add to Play Later", style: .Default) { (action) in
            
        }
        alertController.addAction(laterAct)
        
        let listAct = UIAlertAction(title: "Add to playlist", style: .Default) { (action) in
            
        }
        alertController.addAction(listAct)
        
        let reportAct = UIAlertAction(title: "Report", style: .Destructive) { (action) in
            
        }
        alertController.addAction(reportAct)
        
        //TODO: remove
        for action in alertController.actions {
            action.enabled = false
        }
        cancelAction.enabled = true
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func likeUnlikeEpisode(sender: UIBarButtonItem) {
        ParseActions.likeUnlike(sender, userID: episode.authorId, episodeID: episode.episodeId)
    }
    
    @IBAction func sleepCounting(sender: UIBarButtonItem) {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        ac.addAction(cancelAction)
        
        let laterAct = UIAlertAction(title: "Off", style: .Default) { (action) in
            self.audioPlayer.sleepCountDown = nil
            self.sleepTimer.title = "Sleep"
        }
        ac.addAction(laterAct)
        
        let fiveMin = UIAlertAction(title: "5 Min", style: .Default) { (action) in
            self.audioPlayer.sleepCountDown = 300
        }
        ac.addAction(fiveMin)
        
        let fifteenMin = UIAlertAction(title: "15 Min", style: .Default) { (action) in
            self.audioPlayer.sleepCountDown = 900
        }
        ac.addAction(fifteenMin)
        
        let thirtyMin = UIAlertAction(title: "30 Min", style: .Default) { (action) in
            self.audioPlayer.sleepCountDown = 1800
        }
        ac.addAction(thirtyMin)
        
        let hour = UIAlertAction(title: "60 Min", style: .Default) { (action) in
            self.audioPlayer.sleepCountDown = 3600
        }
        ac.addAction(hour)
        
        presentViewController(ac, animated: true, completion: nil)
    }
    
    @IBAction func speedChange(sender: UIBarButtonItem) {
        
//        let shadow : NSShadow = NSShadow()
//        shadow.shadowBlurRadius = 5.0
//        let attributes = [NSShadowAttributeName: shadow]
//        let attr = NSAttributedString(string: "hahahah", attributes: attributes)
//        dismissSection.setAttributedTitle(attr, forState: .Normal)
//        print(dismissSection.titleLabel?.text)
    }
}


































