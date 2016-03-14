//
//  RecordingVC+Edit.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 2/27/16.
//  Copyright © 2016 Wenxiang Deng. All rights reserved.
//

import UIKit

// Edit scene
extension RecordingViewController {
    
    func editButtonPressed() {
        guard let idx = collectionView.indexPathsForSelectedItems() else {return} //indexPathsForVisibleItems()
        if self.editing {
            setEditing(false, animated: true)
            navigationItem.rightBarButtonItem = closeButton
            collectionView.removeGestureRecognizer(longPress)
            collectionView.allowsMultipleSelection = false
            for i in idx { collectionView.deselectItemAtIndexPath(i, animated: true) }
            
            navigationItem.title = "Record"
            showRecordButton()
        }
        else {
            setEditing(true, animated: true)
            deleteButton.enabled = false
            navigationItem.rightBarButtonItem = deleteButton
            
            audioPlayerShouldStop()//TODO: maybe use KVO of model data for audio player should stop
            collectionView.addGestureRecognizer(longPress)
            collectionView.allowsMultipleSelection = true
            
            stopRecorder()
            navigationItem.title = "Tap or Drag"
            hideRecordButton()
        }
        
    }
    
    @IBAction func deleteAction(sender: AnyObject) {
        guard let idx = collectionView.indexPathsForSelectedItems() else {return}
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            
        }
        alertController.addAction(cancelAction)
        
        let multiplier = idx.count > 1 ? "s" : ""
        let destroyAction = UIAlertAction(title: "Delete Item" + multiplier, style: .Destructive) { (action) in
            
            let rank = idx.sort({$0.item > $1.item})//rank in reverse order, model missmatch if not
            self.collectionView.performBatchUpdates({
                for i in rank {
                    if let dur = (self.addedItems.data[i.item] as? AudioModel)?.duration {
                        self.totalRecordedLength -= dur
                    }
                    
                    self.addedItems.data.removeAtIndex(i.item)
                    self.collectionView.deleteItemsAtIndexPaths([i])
                } }, completion: nil)
            
            //self.postSceneButton.enabled = (self.addedItems.data.audioCount() > 0)
            self.deleteButton.enabled = false
            
            if self.addedItems.data.count == 0 {
                self.editButtonPressed()
            }
        }
        alertController.addAction(destroyAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if collectionView.allowsMultipleSelection {
            return true
        } else {
            //show image, or play sound
            if audioRecorder?.recording != true {
                if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? UIPhotoCell {
                    performSegueWithIdentifier("openImageViewer", sender: cell)
                } else if let _ = collectionView.cellForItemAtIndexPath(indexPath) as? UIAudioCell {
                    playSelectedAudio(atIndexPath: indexPath)
                }
            }
            return false
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        deleteButton.enabled = true
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView.indexPathsForSelectedItems()?.count < 1 {
            deleteButton.enabled = false
        }
    }
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "openImageViewer") {
            let vc = segue.destinationViewController as! ImageCollectionViewController
            vc.delegate = self
            vc.model = addedItems
            let cell = sender as! UIPhotoCell
            vc.currentParentIndexPath = collectionView.indexPathForCell(cell)!
            
            vc.placeHoldViewForAnimation = ImageCollectionViewController.placeHolderImageView(forImageView: cell.imageView, presentingView: view)
        } else if (segue.identifier == "showPostEpisodeVC") {
            let postEpisodeVC = segue.destinationViewController as! PostEpisodeTVC
            postEpisodeVC.receivedBundles = sender as! [AnyObject]
            postEpisodeVC.post = post
        }
    }
    
    
    
    
    
    
    
    
    
    
}














