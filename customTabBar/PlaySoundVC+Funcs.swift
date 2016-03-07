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
        btn.layer.shadowColor = UIColor.blackColor().CGColor
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
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func likeUnlikeEpisode(sender: UIBarButtonItem) {
        ParseActions.likeUnlike(sender, userID: episode.authorId, episodeID: episode.episodeId)
    }
    
}


































