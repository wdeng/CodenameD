//
//  PostingViewController.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/14/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import Parse

class PostingViewController: UIViewController {
    
    var activityIndicator: UIActivityIndicatorView!
    var playingSections: AudioMerger!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //TODO: use uploading complex, be sure even after go back to last page, uploading won't re-upload anything, uploading complex should be a static class can be seen anywhere
        
        // TODO: if under wifi, should start, if not, we'll see
        
        //let imageData = UIImagePNGRepresentation(imageToPost.image!)
        //let imageFile = PFFile(name: "image.png", data: imageData!)
        //post["imageFile"] = imageFile
        
        uploadMedia()
        
        
    }
    

    @IBOutlet var message: UITextView!
    
    func uploadMedia() {
        for i in 0 ..< playingSections.imageSets.count {
            let set = playingSections.imageSets[i]
            for j in 0 ..< set.images.count {
                // Parse
                let imData = UIImageJPEGRepresentation(set.images[j], GeneralSettings.compressQuality)
                let im = PFFile(name: "\(i)-\(j).jpg", data: imData!)
                let objectForSave = PFObject(className: "Episode")
                
                im!.saveInBackgroundWithBlock{(success, error) -> Void in
                    if error == nil {
                        objectForSave.setObject(im!, forKey: "image") //addObject
                        objectForSave.saveInBackgroundWithBlock{(success, error) -> Void in
                            if success {
                                //AppUtils.displayAlert("Image Posted!", message: "Your image has been posted successfully", onViewController: self)
                            } else {
                                AppUtils.displayAlert("Could not upload image", message: "Please try again later", onViewController: self)
                            }
                        }
                    } else {
                        AppUtils.displayAlert("Could not upload images", message: "Please try again later", onViewController: self)
                    }
                    
                }
                // End Parse
                
            }
        }
        
        let audioData = NSData(contentsOfURL: playingSections.outputAudio!)
        let audioFile = PFFile(name: "audio.m4a", data: audioData!)
        let post = PFObject(className: "Episode")
        post["audio"] = audioFile
        post.saveInBackgroundWithBlock{(success, error) -> Void in
            //self.activityIndicator.stopAnimating()
            //UIApplication.sharedApplication().endIgnoringInteractionEvents()
            if error == nil {
                //AppUtils.displayAlert("Audio Uploaded", message: "Your audio has been posted successfully", onViewController: self)
            } else {
                
                AppUtils.displayAlert("Could not upload", message: "Please try again later", onViewController: self)
                
            }
            
        }
    }
    
    @IBAction func postEpisode(sender: AnyObject) {
        
        //TODO: go back to main feed while posting
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        AppUtils.switchOnActivityIndicator(activityIndicator, forView: view, ignoreUser: true)
        
        let post = PFObject(className: "Episode")
        
        post["title"] = message.text
        post["userId"] = PFUser.currentUser()!.objectId!
        
        post.saveInBackgroundWithBlock{(success, error) -> Void in
            self.activityIndicator.stopAnimating()
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            if error == nil {
                AppUtils.displayAlert("Image Posted!", message: "Your image has been posted successfully", onViewController: self)
                
                //self.imageToPost.image = UIImage(named: "315px-Blank_woman_placeholder.svg.png")
                
                //self.message.text = ""
                
            } else {
                
                AppUtils.displayAlert("Could not post image", message: "Please try again later", onViewController: self)
                
            }
            
        }
    }
    

}
