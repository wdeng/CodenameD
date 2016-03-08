//
//  PostEpisodeTVC.swift
//  PitchPerfect
//
//  Created by Wenxiang Deng on 12/20/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import AVFoundation
import Parse

class PostEpisodeTVC: UITableViewController, UITextViewDelegate, AudioMergerDelegate {

    var activityIndicator: UIActivityIndicatorView!
    var receivedBundles = [AnyObject]()
    var episodeCreating: AudioMerger!
    let audioPlayer = SectionAudioPlayer.sharedInstance
    var finishedMerging: Bool? = false    // nil means failed merging
    var tableViewDefaultOffset: CGFloat!
    
    @IBOutlet var postButton: UIBarButtonItem!
    var playerForRecordedItem: Bool = false
    var post = PFObject(className: "Episode")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        episodeTitle.delegate = self
        
        self.navigationItem.rightBarButtonItem = postButton
        openPlayer.setTitle(nil, forState: .Normal)
        
        openPlayer.setImage(UIImage(named: "play"), forState: .Normal)
        openPlayer.tintColor = UIColor.whiteColor()
        
        tableView.keyboardDismissMode = .OnDrag
    }
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        containerView.frame.size.height = 80.0
        
        if episodeTitle.text.isEmpty {
            episodeTitle.text = "Title"
            episodeTitle.textColor = UIColor.lightGrayColor()
        }
        
        finishedMerging = false
        episodeCreating = AudioMerger(withItems: receivedBundles)
        episodeCreating.delegate = self
        
        openPlayer.setBackgroundImage((episodeCreating.episode.thumb as? UIImage), forState: .Normal)
        
        uploadImages()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableViewDefaultOffset = tableView.contentOffset.y
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        episodeCreating?.stopMerge()
    }
    
    //MARK: scroll view delegate
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= tableViewDefaultOffset {
            // scrolling up
            containerView.clipsToBounds = true
            //bottomSpaceConstraint?.constant = -scrollView.contentOffset.y / 2
            //topSpaceConstraint?.constant = scrollView.contentOffset.y / 2
        } else {
            // scrolling down
            topSpaceConstraint?.constant = scrollView.contentOffset.y - tableViewDefaultOffset
            containerView.clipsToBounds = false
        }
    }
    
    //MARK: textView delegate
    func textViewDidBeginEditing(textView: UITextView) {
        //print("begin editing")
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Title"
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    //MARK: audio merger delegate
    func mergingDidFinished(status: AVAssetExportSessionStatus) {
        if status == .Completed {
            debugPrint("Merging complete")
            uploadAudio()
            finishedMerging = true
        }
        else {
            finishedMerging = nil
            debugPrint("Merge Of Audios failed")
        }
        
    }
    
    //TODO: handle errors!!!
    // should set the pffiles else where
    func uploadImages() {
        if episodeCreating.episode.imageSets.count == 0 {return}
        
        //images
        var images: [[PFFile]] = []
        for i in 0 ..< episodeCreating.episode.imageSets.count {
            var imSect = [PFFile]()
            let set = episodeCreating.episode.imageSets[i] as! [UIImage]
            for j in 0 ..< set.count {
                let imData = UIImageJPEGRepresentation(set[j], GeneralSettings.compressQuality)
                if let im = PFFile(data: imData!) {
                    imSect.append(im)
                }
            }
            images.append(imSect)
        }
        post["images"] = images
        
        //thumbnail
        if let thumbImage = episodeCreating.episode.thumb as? UIImage {
            let thumb = UIImageJPEGRepresentation(thumbImage, GeneralSettings.compressQuality)
            post["thumb"] = PFFile(data: thumb!)
        }
        
        //lengths
        var sectionDurs: [Double] = []
        for i in episodeCreating.episode.sectionDurations {
            sectionDurs.append(i)
        }
        post["durations"] = sectionDurs
        
        post.saveInBackgroundWithBlock{(success, error) -> Void in
            if success {
                //AppUtils.displayAlert("Image Posted!", message: "Your image has been posted successfully", onViewController: self)
            } else {
                AppUtils.displayAlert("Could not upload images", message: "Please try again later", onViewController: self)
            }
        }
    }
    
    func uploadAudio() {
        //TODO: delete PFFile filenames
        guard let audioData = NSData(contentsOfURL: episodeCreating.episode.episodeURL!) else {return}
        post["audio"] = PFFile(name: "audio.m4a", data: audioData)
        post.saveInBackgroundWithBlock{(success, error) -> Void in
            if success {
                //AppUtils.displayAlert("Image Posted!", message: "Your image has been posted successfully", onViewController: self)
            } else {
                AppUtils.displayAlert("Could not upload audio", message: "Please try again later", onViewController: self)
            }
        }
        
    }
    
    @IBAction func postEpisode(sender: UIBarButtonItem) {
        episodeTitle.resignFirstResponder()
        
        if episodeTitle.textColor == UIColor.lightGrayColor() || episodeTitle.text.isEmpty {
            post["title"] = "Posted an Episode"
        }
        else { post["title"] = episodeTitle.text }
        post["userId"] = PFUser.currentUser()!.objectId!
        
        AppUtils.addCustomView(toBarItem: sender)
        post.saveInBackgroundWithBlock{(success, error) -> Void in
            sender.customView = nil
            if error == nil {
                //self.dismissViewControllerAnimated(true, completion: nil)
                PFUser.currentUser()!["postUpdatedAt"] = self.post.updatedAt
                PFUser.currentUser()?.saveInBackground()
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                AppUtils.displayAlert("Could not post", message: "Please try again later", onViewController: self)
            }
        }
        
        
    }
    
    
    //MARK: Segue to Section Playing Scene
    @IBOutlet weak var episodeTitle: UITextView!
    @IBOutlet weak var openPlayer: UIButton!
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "showSoundPlayer" {
            if finishedMerging != true { return false}
            //else {return super.shouldPerformSegueWithIdentifier(identifier, sender: sender)}
        }
        
        return super.shouldPerformSegueWithIdentifier(identifier, sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showSoundPlayer") {
            
            audioPlayer.setPlayerItemWithURL(episodeCreating.episode.episodeURL!)
            audioPlayer.play()
            
            let postEpisodeVC = segue.destinationViewController as! PlaySoundViewController
            postEpisodeVC.episode = episodeCreating.episode
        }
    }
    
    
    
    
    
    
    
    
    
    

}


































