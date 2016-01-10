//
//  RecordSoundViewController.swift
//  PitchPerfect
//
//  Created by Wenxiang Deng on 11/4/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import AVFoundation
import Parse

class RecordSoundViewController: UIViewController, AVAudioRecorderDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var recordedTableView: UITableView!
    @IBOutlet var deleteButton: UIBarButtonItem!
    @IBOutlet var closeButton: UIBarButtonItem!
    
    
    var updateTime: NSTimer?
    var recordingNameIndex = 0
    var playingTag = -1  //// the tag of the play sound button that is playing
    private var recordingSuccessful = false
    private var durationOfRecording = 0.0
    private var sampledAudioLevel = [Double]()
    let meterTable: MeterTable = MeterTable(minDecibels: AppSettings.minDBValue)!
    
    var audioRecorder:AVAudioRecorder!
    var audioPlayer: AVAudioPlayer?
    var addedItems = [AnyObject]() // TODO: if we want Edit button to hide and appear
    var numberOfAudios: Int = 0 {
        didSet {
            postSceneButton.hidden = numberOfAudios > 0 ? false : true
        }
    }
    
    var post = PFObject(className: "Episode")
    
    // MARK: - life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //close button
        navigationItem.rightBarButtonItem = closeButton

        // disable next step
        postSceneButton.hidden = true
        
        // record table view
        recordedTableView.delegate = self
        recordedTableView.dataSource = self
        recordedTableView.contentInset.top = 2.0
        recordedTableView.contentInset.bottom = 50.0
        
        // setup edit button
        navigationItem.leftBarButtonItem = self.editButtonItem()
        navigationItem.leftBarButtonItem?.action = Selector("editButtonPressed")
        
        
        recordedTableView.allowsMultipleSelectionDuringEditing = true
    }
    
    override func viewWillAppear(animated: Bool) {
        //recordButton.enabled = true
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        audioPlayer?.stop()
        if audioRecorder != nil {
            audioRecorder.stop()
        }
    }
    
    // Dismiss controller
    
    @IBAction func closeRecordingController(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    // MARK: recording events
    // touch down event to start record
    @IBAction func recordStart(sender: UIButton) {
        //button stats change
        recordingInProgress.hidden = false
        audioPlayer?.stop()
        
        //audio saving dir
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as String
        let recordingName = "myaudio\(recordingNameIndex).wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        let recordSettings:[String : AnyObject] = [
            //AVFormatIDKey: NSNumber(unsignedInt:kAudioFormatMPEG4AAC),
            AVEncoderAudioQualityKey : AVAudioQuality.High.rawValue,
            AVEncoderBitRateKey : 64000,
            AVNumberOfChannelsKey: 1,
            AVSampleRateKey : 32000.0]   ///TODO: need to change sample rate key, if cannot change export session in the
        
        //start recording
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! audioRecorder = AVAudioRecorder(URL: filePath!, settings: recordSettings)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        
        // timer to sample sound level
        sampledAudioLevel.removeAll()
        updateTime = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "addLevelSample", userInfo: audioRecorder, repeats: true)
    }
    
    @IBAction func recordEndSucceed(sender: UIButton) {
        updateTime?.invalidate()
        // remove first a few level when recording is starting
        if sampledAudioLevel.count > 5 {
        sampledAudioLevel[0 ... 3] = []
        }
        recordingInProgress.hidden = true
        let len = audioRecorder.currentTime
        if (len > 1.0)
        {
            durationOfRecording = len
            recordingSuccessful = true
        }
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    @IBAction func recordEndFail(sender: UIButton) {
        updateTime?.invalidate()
        recordingInProgress.hidden = true
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
        
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        // stop timer
        updateTime?.invalidate()
        
        if (flag && recordingSuccessful){
            //prepare for next
            let recordedAudio = RecordedAudio()
            recordedAudio.filePathURL = recorder.url
            if let l = recorder.url.lastPathComponent {
                recordedAudio.title = l
            }
            recordedAudio.duration = durationOfRecording
            recordingSuccessful = false
            
            numberOfAudios++
            recordingNameIndex++
            
            addedItems.append(recordedAudio)
            insertRecordInTableView()
        }
        else{
            print("not succussful")
        }
    }
    
    // sample audio level
    func addLevelSample() {
        audioRecorder.updateMeters()
        let meter = meterTable.ValueAt(audioRecorder.averagePowerForChannel(0))
        sampledAudioLevel.append( Double(meter) )
    }
    
    //MARK: Open Section Player
    
    @IBOutlet weak var postSceneButton: UIButton!
    @IBAction func openPostVC(sender: AnyObject) {
        self.performSegueWithIdentifier("showPostVC", sender: addedItems)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showPostVC") {
            let postEpisodeVC = segue.destinationViewController as! PostEpisodeTVC
            postEpisodeVC.receivedBundles = sender as! [AnyObject]
            postEpisodeVC.post = post
        }
    }
    
    // MARK: photo events
    
    @IBAction func takePhoto(sender: AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .Camera
        
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
            pickerController.modalPresentationStyle = .OverCurrentContext
        }
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func selectPhoto(sender: UIButton) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .SavedPhotosAlbum
        
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
            pickerController.modalPresentationStyle = .OverCurrentContext
        }
        
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let im = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let image = ImageUtils.createFitImageFromSize(im, targetSize: RecordSettings.defaultImageLimit)!
            if let imageSet = addedItems.last as? AddedImageSet {
                if imageSet.images.count < 4 {
                    picker.dismissViewControllerAnimated(true, completion: nil)
                    dispatch_async(dispatch_get_main_queue()) {
                        imageSet.images.append(image)
                        let indexPath = NSIndexPath(forRow: self.addedItems.count-1, inSection: 0)
                        self.recordedTableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                        //self.recordedTableView.reloadData()
                    }
                    return
                }
            }
            
            picker.dismissViewControllerAnimated(true, completion: nil)
            
            dispatch_async(dispatch_get_main_queue()) {
                let item = AddedImageSet()
                item.images.append(image)
                self.addedItems.append(item)
                let indexPath = NSIndexPath(forRow: self.addedItems.count-1, inSection: 0)
                self.recordedTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                self.recordedTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: Edit Table View
    
    func editButtonPressed() {
        guard let idx = self.recordedTableView.indexPathsForVisibleRows else {return}
        if self.editing {
            setEditing(false, animated: true)
            navigationItem.rightBarButtonItem = closeButton
            self.recordedTableView.reloadRowsAtIndexPaths(idx, withRowAnimation: .None)
            recordedTableView.setEditing(false, animated: true)
        }
        else {
            setEditing(true, animated: true)
            deleteButton.enabled = false
            navigationItem.rightBarButtonItem = deleteButton
            self.recordedTableView.reloadRowsAtIndexPaths(idx, withRowAnimation: .None)
            recordedTableView.setEditing(true, animated: true)
        }
        
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
    
    
    //MARK: Table View
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //TODO: ADD COVER PHOTOS
        if indexPath.row >= addedItems.count {
            return UITableViewCell()
        }
        
        // audio cell
        if let audio = addedItems[indexPath.row] as? RecordedAudio {
            //audio.itemIndex = indexPath.row
            let audioCell = tableView.dequeueReusableCellWithIdentifier("RecordedAudioCell") as! RecordedSoundCell
            audioCell.audio = audio
            
            let duration = Int(audio.duration)
            let length = "\(duration)\""
            audioCell.playSound.text = length
            
            audioCell.audioButtonWidth.constant = audioCell.calculateButtonWidth(audioDuration: audio.duration, boundsWidth: min(self.view.bounds.width, self.view.bounds.height))
            audioCell.showsReorderControl = true
            
            // single digit and double digit have different size for button
            audioCell.insetForLabel = RecordSettings.recordedAudioCellInsetForLabel(duration)
            
            audioCell.audioLevels.nums = sampledAudioLevel
            audioCell.audioLevels.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "playSelectedSound:"))
            if self.editing {
                audioCell.audioLevels.userInteractionEnabled = false
            } else {
                audioCell.audioLevels.userInteractionEnabled = true
            }
            return audioCell
        }
        // photo cell
        else if let imageSet = addedItems[indexPath.row] as? AddedImageSet {
            //imageSet.itemIndex = indexPath.row
            
            let photoCell = tableView.dequeueReusableCellWithIdentifier("SelectedPhotoCell") as! SelectedPhotoCell
            photoCell.showsReorderControl = true
            //print(photoCell.photoButtons[0].hidden)
            for i in 0 ..< 4 {
                // change to more efficient way maybe, doesn't set image every time
                if i < imageSet.images.count {
                    photoCell.photoButtons[i].setImage(imageSet.images[i], forState: .Normal)
                    photoCell.photoButtons[i].imageView?.contentMode = .ScaleAspectFill
                    photoCell.photoButtons[i].hidden = false
                    
                    photoCell.photoButtons[i].tag = i
                    
                    if self.editing {
                        photoCell.photoButtons[i].userInteractionEnabled = false
                    } else {
                        photoCell.photoButtons[i].userInteractionEnabled = true
                    }
                }
                else {
                    photoCell.photoButtons[i].hidden = true
                }
            }
            return photoCell
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedItems.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if let _ = addedItems[indexPath.row] as? RecordedAudio {
            return RecordSettings.recordedAudioCellHeight
        }
        else if let _ = addedItems[indexPath.row] as? AddedImageSet {
            // calculate how tall cell should be
            //TODO: not really good solution
            let wid = min(view.bounds.width, view.bounds.height)
            let imgWid = (wid - 12.0 - 8.0 - 2.0 * 3) / 4 /// compute the width via image constraints

            return imgWid + 2.0
        }
        
        return 5
    }
    
    //
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
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let item = addedItems[sourceIndexPath.row]
        
        addedItems[sourceIndexPath.row] = addedItems[destinationIndexPath.row]
        addedItems[destinationIndexPath.row] = item
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
    
    func playSelectedSound(gesture: UITapGestureRecognizer)
    {
        
        //guard let v = gesture.view else {return}
        guard let row = recordedTableView.indexPathForRowAtPoint(gesture.locationInView(recordedTableView))?.row else {return}
        
        guard let audioToRun = addedItems[row] as? RecordedAudio else {return}
        if(audioPlayer?.playing == true) && (playingTag == row) { // TODO: use button selected for the playing handling, and use delegate to detect finished playing
            audioPlayer!.stop()
            return
        }
        
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
            //try session.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOfURL: audioToRun.filePathURL)
            audioPlayer?.currentTime = 0.0
            audioPlayer?.play()
            playingTag = row
        } catch {
            print("playing bullet failed")
        }
        
        
    }

    
    func insertRecordInTableView() {
        //recordedTableView.beginUpdates()
        let indexPath = NSIndexPath(forRow: addedItems.count-1, inSection: 0)
        recordedTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        //recordedTableView.endUpdates()
        recordedTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
        
        }

    
    
}

