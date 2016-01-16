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
    var episodeData: AudioMerger?
    let audioPlayer = SectionPlayer.sharedInstance
    var finishedMerging: Bool? = false    // nil means failed merging
    var tableViewDefaultOffset: CGFloat!
    var thumbImage: UIImage?
    
    @IBOutlet var postButton: UIBarButtonItem!
    var playerForRecordedItem: Bool = false
    var post = PFObject(className: "Episode")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        episodeTitle.delegate = self
        
        episodeData = AudioMerger(withItems: receivedBundles)
        episodeData?.delegate = self
        self.navigationItem.rightBarButtonItem = postButton
        openPlayer.setTitle(nil, forState: .Normal)
        
        thumbImage = ImageUtils.createCropImageFromSize(episodeData!.imageSets.first?.images.first)
        openPlayer.setBackgroundImage(thumbImage, forState: .Normal)
        
        openPlayer.setImage(UIImage(named: "play"), forState: .Normal)
        openPlayer.tintColor = UIColor.whiteColor()
    }
    
    //MARK: Upload images
    func uploadMedia() {
        
        post["images"] = [PFFile]()
        
        for i in 0 ..< episodeData!.imageSets.count {
            let set = episodeData!.imageSets[i]
            for j in 0 ..< set.images.count {
                // Parse
                let imData = UIImageJPEGRepresentation(set.images[j], GeneralSettings.compressQuality)
                let im = PFFile(name: "\(i)-\(j).jpg", data: imData!)
                
                im!.saveInBackgroundWithBlock{(success, error) -> Void in
                    if error == nil {
                        self.post.addObject(im!, forKey: "images") //addObject
                        self.post.saveInBackgroundWithBlock{(success, error) -> Void in
                            if success {
                                //AppUtils.displayAlert("Image Posted!", message: "Your image has been posted successfully", onViewController: self)
                            } else {
                                AppUtils.displayAlert("Could not upload an image", message: "Please try again later", onViewController: self)
                            }
                        }
                    } else {
                        AppUtils.displayAlert("Could not upload images", message: "Please try again later", onViewController: self)
                    }
                }
            }
        }
        
        let audioData = NSData(contentsOfURL: episodeData!.outputAudio!)
        let audioFile = PFFile(data: audioData!)
        
        post["audio"] = audioFile
        post.saveInBackgroundWithBlock{(success, error) -> Void in
            if success {
                //AppUtils.displayAlert("Audio Uploaded", message: "Your audio has been posted successfully", onViewController: self)
            } else {
                AppUtils.displayAlert("Could not upload", message: "Please try again later", onViewController: self)
            }
        }
    }
    
    //TODO: handle errors!!!
    // should set the pffiles else where
    func uploadImages() {
        if episodeData == nil {return}
        var images = [PFFile]()
        
        for i in 0 ..< episodeData!.imageSets.count {
            let set = episodeData!.imageSets[i]
            for j in 0 ..< set.images.count {
                let imData = UIImageJPEGRepresentation(set.images[j], GeneralSettings.compressQuality)
                if let im = PFFile(name: "\(i)-\(j).jpg", data: imData!) {
                    images.append(im)
                }
            }
        }
        post["images"] = images
        
        if let thumbImage = thumbImage {
            let thumb = UIImageJPEGRepresentation(thumbImage, GeneralSettings.compressQuality)
            post["thumb"] = PFFile(data: thumb!)
        }
        
        post.saveInBackgroundWithBlock{(success, error) -> Void in
            if success {
                print("images uploaed")
                //AppUtils.displayAlert("Image Posted!", message: "Your image has been posted successfully", onViewController: self)
            } else {
                AppUtils.displayAlert("Could not upload images", message: "Please try again later", onViewController: self)
            }
        }
    }
    
    func uploadAudio() {
        if episodeData == nil {return}
        guard let audioData = NSData(contentsOfURL: episodeData!.outputAudio!) else {return}
        if let audioFile = PFFile(name: "audio.m4a", data: audioData) {
            post["audio"] = audioFile
        }
        post.saveInBackgroundWithBlock{(success, error) -> Void in
            if success {
                //AppUtils.displayAlert("Image Posted!", message: "Your image has been posted successfully", onViewController: self)
            } else {
                AppUtils.displayAlert("Could not upload audio", message: "Please try again later", onViewController: self)
            }
        }
        
    }
    
    @IBAction func postEpisode(sender: AnyObject) {
        
        if episodeTitle.textColor == UIColor.lightGrayColor() || episodeTitle.text.isEmpty {
            post["title"] = "Posted an Episode"
        }
        else { post["title"] = episodeTitle.text }
        post["userId"] = PFUser.currentUser()!.objectId!
        var sectionDurs = [Double]()
        for i in episodeData!.imageSets {
            sectionDurs.append(i.sectionDuration)
        }
        
        post.saveInBackgroundWithBlock{(success, error) -> Void in
            if error == nil {
                self.updateFollowersTime(self.post.updatedAt)
            } else {
                AppUtils.displayAlert("Could not post", message: "Please try again later", onViewController: self)
            }
        }
    }
    
    func updateFollowersTime(date: NSDate?) {
        
        let q = PFQuery(className: "Activities")
        q.whereKey("toUser", equalTo: PFUser.currentUser()!.objectId!)
        q.whereKey("type", equalTo: "following")
        
        q.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
            if error != nil {
                AppUtils.displayAlert("Fetching Users Failed", message: "Please try later", onViewController: self)
                return
            }
            
            // TODO: change into only use save() to change updatedAt remove postUpdatedAt
            PFObject.saveAllInBackground(objects)
            self.self.dismissViewControllerAnimated(true, completion: nil)
            //guard let followers = objects else {return}
            
            
//            for u in followers {
//                u["postUpdatedAt"] = d
//                u.saveInBackgroundWithBlock{(success, error) -> Void in
//                    if success{
//                        //self.dismissViewControllerAnimated(true, completion: nil)
//                    }
//                }
//            }
        }
    }
    

    //MARK: Segue to Section Playing Scene
    @IBOutlet weak var episodeTitle: UITextView!
    @IBOutlet weak var openPlayer: UIButton!
    @IBAction func openSoundPlayer(sender: AnyObject) {
        
        if finishedMerging != true { return}
        guard let data = episodeData else {return}
        audioPlayer.setPlayerItemWithURL(episodeData!.outputAudio)
        audioPlayer.play()
        
        self.performSegueWithIdentifier("showSoundPlayer", sender: data)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showSoundPlayer") {
            
            let postEpisodeVC = segue.destinationViewController as! PlaySoundViewController
            postEpisodeVC.playingSections = sender as! AudioMerger
            //TODO: This make the user can see through the VC to the parent View, or OverFullScreen
            if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
                postEpisodeVC.modalPresentationStyle = .OverFullScreen
            }
        }
    }
    
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if episodeTitle.text.isEmpty {
            episodeTitle.text = "Title"
            episodeTitle.textColor = UIColor.lightGrayColor()
        }
        containerView.frame.size.height = 80.0
        
        uploadImages()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableViewDefaultOffset = tableView.contentOffset.y
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
        print("begin editing")
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
            print("Merging complete")
            uploadAudio()
            finishedMerging = true
        }
        else {
            finishedMerging = nil
            print("Merge Of Audios failed")
        }
        
    }

}