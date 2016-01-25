//
//  RecordVC+Edit.swift
//  PitchPerfect
//
//  Created by Wenxiang Deng on 12/19/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit

extension RecordSoundViewController {
    
    //MARK: Edit Table View
    
    func editButtonPressed() {
        guard let idx = self.recordedTableView.indexPathsForVisibleRows else {return}
        if self.editing {
            setEditing(false, animated: true)
            navigationItem.rightBarButtonItem = closeButton
            recordedTableView.reloadRowsAtIndexPaths(idx, withRowAnimation: .None)
            recordedTableView.setEditing(false, animated: true)
        }
        else {
            setEditing(true, animated: true)
            deleteButton.enabled = false
            navigationItem.rightBarButtonItem = deleteButton
            recordedTableView.reloadRowsAtIndexPaths(idx, withRowAnimation: .None)
            recordedTableView.setEditing(true, animated: true)
        }
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the object
            if let _ = addedItems[indexPath.row] as? RecordedAudio {
                numberOfAudios--
            }
            addedItems.removeAtIndex(indexPath.row)
            
            // Delete the row
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            // Save the array
            //NSKeyedArchiver.archiveRootObject(objects, toFile: filePath)
        }
    }
    
    
    func deletePhoto(sender: UIButton) {
        guard let row = recordedTableView.indexPathForRowAtPoint(recordedTableView.convertPoint(sender.center, fromView: sender))?.row else {return}
        
        guard let imSet = addedItems[row] as? AddedImageSet else {return}
        imSet.images.removeAtIndex(sender.tag)
        if imSet.images.count == 0 {
            addedItems.removeAtIndex(row)
        }
        // possibly add some merging rows
        let indexPath = NSIndexPath(forRow: row, inSection: 0)
        self.recordedTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
    
    @IBAction func deleteAction(sender: AnyObject) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            
        }
        alertController.addAction(cancelAction)
        
        let multiplier = recordedTableView.indexPathsForSelectedRows?.count > 1 ? "s" : ""
        let destroyAction = UIAlertAction(title: "Delete Item"+multiplier, style: .Destructive) { (action) in
            guard let selectedRows = self.recordedTableView.indexPathsForSelectedRows else {return}
            //TODO: images more than 4 is probably not separated items, need to change uibuttons to collection view
            for i in selectedRows {
                if let _ = self.addedItems[i.row] as? RecordedAudio {
                    self.numberOfAudios--
                }
                self.addedItems.removeAtIndex(i.row)
            }
            self.recordedTableView.deleteRowsAtIndexPaths(selectedRows, withRowAnimation: .Automatic)
            
            if self.addedItems.count < 1 {
                self.deleteButton.enabled = false
            }
            
        }
        alertController.addAction(destroyAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if recordedTableView.editing {
            deleteButton.enabled = true
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if recordedTableView.indexPathsForSelectedRows?.count < 1 {
            deleteButton.enabled = false
        }
    }
    
    
}
