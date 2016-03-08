//
//  ViewController.swift
//  DragNDropCollectionView
//
//  Created by Wenxiang Deng on 2/19/16.
//  Copyright © 2016 Wenxiang Deng. All rights reserved.
//

import UIKit
import AVFoundation
import Parse


typealias PhotoModel = UIImage

class AudioModel {
    
    init(withURL url: NSURL) {
        filePathURL = url
    }
    var filePathURL: NSURL!
    //var title: String = ""
    var duration = 0.0
    var samples = [Double]()
}

extension UINavigationController {
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        let orientations = (visibleViewController as? ImageCollectionViewController)?.supportedInterfaceOrientations() ?? .Portrait
        return orientations
    }
    
    public override func shouldAutorotate() -> Bool {
        return true
    }
}

class RecordingViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var recordBackgroundView: UIVisualEffectView!
    @IBOutlet weak var recordButton: UIButton!
    var recordMeterView: RecordingMeterView!
    
    @IBOutlet var deleteButton: UIBarButtonItem!
    @IBOutlet var closeButton: UIBarButtonItem!
    
    // Toolbar Items
    @IBOutlet weak var photoButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var micButton: UIBarButtonItem!
    @IBOutlet weak var postSceneButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    
    var updateTime: NSTimer?
    
    var recordingNameIndex = 0
    internal var recordingShouldFail = false
    internal var sampledAudioLevel = [Double]()
    internal var totalRecordedLength = 0.0 {
        didSet {
            if (totalRecordedLength > 0.5) && (totalRecordedLength < 600) {
                if !postSceneButton.enabled {
                    postSceneButton.enabled = true
                }
                
            } else {
                if postSceneButton.enabled {
                    postSceneButton.enabled = false
                }
            }
        }
    }
    let meterTable: MeterTable = MeterTable(minDecibels: AppSettings.minDBValue)!
    
    var audioRecorder:AVAudioRecorder!
    var audioPlayer: AVAudioPlayer?
    var audioPlayerCurrentIdxPath: NSIndexPath?
    //var audioPlayerAnimateTargetRect: CGRect?
    
    let pickerController = UIImagePickerController()
    var addedItems = RecordingModel() {
        didSet {
            audioPlayerShouldStop()
        }
    }
    
    var post = PFObject(className: "Episode")
    
    var longPress = UILongPressGestureRecognizer()
    private var statusBarShouldHide: Bool = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    override func prefersStatusBarHidden() -> Bool {
        return statusBarShouldHide
    }
    
    //TODO: maybe need to decrease things before viewdidappear
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let normalImage = UIImage(named: "mic")?.imageWithRenderingMode(.AlwaysTemplate)
        recordButton.setImage(normalImage, forState: .Normal)
        recordButton.tintColor = UIColor.whiteColor()
        recordButton.adjustsImageWhenHighlighted = false
        recordButton.imageView?.contentMode = .ScaleAspectFit
        
        recordBackgroundView.layer.cornerRadius = 35
        //recordBackgroundView.clipsToBounds = true
        
        longPress = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPress.minimumPressDuration = 0.3
        longPress.delegate = self
        
        //Removes the toolbar hairline
        //toolBar.clipsToBounds = true
        
        //nav button
        navigationItem.rightBarButtonItem = closeButton
        navigationItem.leftBarButtonItem = self.editButtonItem()
        navigationItem.leftBarButtonItem?.action = Selector("editButtonPressed")
        
        // record collection view
        //collectionView.allowsSelection = true
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 8, bottom: 46, right: 8)
        let layout = collectionView.collectionViewLayout as! LeftAlignedLayout //collectionView.collectionViewLayout = LeftAlignedLayout()
        layout.delegate = self
        
        pickerController.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        SectionAudioPlayer.sharedInstance.pause()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
        postSceneButton.enabled = addedItems.data.audioCount() > 0 ? true : false
        
        recordMeterView = RecordingMeterView(frame: recordBackgroundView.frame)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        audioPlayerShouldStop()
        updateTime?.invalidate()
        if audioRecorder != nil {
            audioRecorder.stop()
        }
    }
    
    
    
    
    
    // MARK: photo events
    
    @IBAction func takePhoto(sender: AnyObject) {
        pickerController.sourceType = .Camera
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
            pickerController.modalPresentationStyle = .OverCurrentContext
        }

        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func selectPhoto(sender: AnyObject) {
        pickerController.sourceType = .SavedPhotosAlbum
        
//        if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
//            pickerController.modalPresentationStyle = .OverCurrentContext
//        }
        self.presentViewController(pickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        //TODO: what is the problem, image pickers doesn't work sometimes
        dispatch_async(dispatch_get_main_queue()) {
            
            if let im = info[UIImagePickerControllerOriginalImage] as? UIImage {
                let image = ImageUtils.createFitImageFromSize(im)
                self.appendItemInCollectionView(withItem: image)
                
            }
        }
        picker.dismissViewControllerAnimated(true) {}
        
    }
    
    func appendItemInCollectionView(withItem item: AnyObject) {
        addedItems.data.append(item)
        
        let idxPath = NSIndexPath(forItem: addedItems.data.count-1, inSection: 0)
        
        collectionView.performBatchUpdates( {
            //TODO: change insert animation, put change offset into the animation
            //need photo and audio item animations different,   need to modify layout file
            self.collectionView.insertItemsAtIndexPaths([idxPath])
             }, completion: { _ in
                let maxOffset = CGPoint(x: self.collectionView.contentOffset.x, y: (self.collectionView.contentSize.height + self.collectionView.contentInset.bottom) - self.collectionView.frame.size.height)  // otherwise collection view content size haven't changed yet
                if maxOffset.y > -self.collectionView.contentInset.top { // larger than the min offset of collection view here
                    self.collectionView.setContentOffset(maxOffset, animated: true)
                }
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: play audio item
    func audioPlayerShouldStop() {
        if let idxPath = self.audioPlayerCurrentIdxPath {
            if let layer = (self.collectionView.cellForItemAtIndexPath(idxPath) as? UIAudioCell)?.audioProgressLayer {
                layer.removeAllAnimations()
                layer.path = nil
            }
        }
        audioPlayerCurrentIdxPath = nil
        audioPlayer?.stop()
    }
    
    func pauseAnimation(inPlayer player: AVAudioPlayer, forShapeLayer layer: CAShapeLayer, withTargetRect: CGRect?) {
        guard let targetRect = withTargetRect else {return}
        let playingRatio = CGFloat(player.currentTime / player.duration)
        let rect = CGRect(x: targetRect.minX, y: targetRect.minY, width: targetRect.width * playingRatio + 1, height: targetRect.width)
        layer.removeAnimationForKey("path")
        layer.path = UIBezierPath(rect:rect).CGPath
    }
    
    func resumeAnimation(inPlayer player: AVAudioPlayer, forShapeLayer layer: CAShapeLayer, withTargetRect: CGRect?) {
        guard let targetRect = withTargetRect else {return}
        
        let playingRatio = CGFloat(player.currentTime / player.duration)
        let rect = CGRect(x: targetRect.minX, y: targetRect.minY, width: targetRect.width * playingRatio + 1, height: targetRect.width)
        layer.path = UIBezierPath(rect:rect).CGPath
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.toValue = UIBezierPath(rect:targetRect).CGPath
        animation.duration = player.duration - player.currentTime
        layer.addAnimation(animation, forKey: animation.keyPath)
    }
    
    func playSelectedAudio(atIndexPath idxPath: NSIndexPath)
    {
        guard let audioToRun = addedItems.data[idxPath.item] as? AudioModel else {return}
        guard let cell = collectionView.cellForItemAtIndexPath(idxPath) as? UIAudioCell else {return}
        if idxPath == audioPlayerCurrentIdxPath {
            if audioPlayer?.playing == true {
                audioPlayer?.pause()
                pauseAnimation(inPlayer: audioPlayer!, forShapeLayer: cell.audioProgressLayer, withTargetRect: cell.bounds)
            } else {
                audioPlayer?.play()
                resumeAnimation(inPlayer: audioPlayer!, forShapeLayer: cell.audioProgressLayer, withTargetRect: cell.bounds)
            }
            return
        }
        
        audioPlayerShouldStop()
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
            //try session.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOfURL: audioToRun.filePathURL)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            audioPlayerCurrentIdxPath = idxPath
            
            cell.audioProgressLayer.hidden = false
            let rect = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: 0, height: cell.bounds.height)
            cell.audioProgressLayer.path = UIBezierPath(rect:rect).CGPath
            let animation = CABasicAnimation(keyPath: "path")
            animation.toValue = UIBezierPath(rect:cell.bounds).CGPath
            animation.duration = audioPlayer!.duration
            cell.audioProgressLayer.addAnimation(animation, forKey: animation.keyPath)
            
        } catch {
            debugPrint("playing item failed")
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayerShouldStop()
    }
    
    //MARK: change scene
    @IBAction func openPostEpisodeVC(sender: AnyObject) {
        self.performSegueWithIdentifier("showPostEpisodeVC", sender: addedItems.data)
    }
    
    @IBAction func closeRecordingController(sender: AnyObject) {
        
        if addedItems.data.count > 0 {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                
            }
            alertController.addAction(cancelAction)
            
            let destroyAction = UIAlertAction(title: "Delete Recorded", style: .Destructive) { (action) in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            alertController.addAction(destroyAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}



//MARK: collection view datasource
extension RecordingViewController: ImageViewerDelegate, LeftAlignedLayoutDelegate, UICollectionViewDataSource, UICollectionViewDelegate  {  //UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return addedItems.data.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let image = addedItems.data[indexPath.item] as? PhotoModel {
            let photoCell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoItem", forIndexPath: indexPath) as! UIPhotoCell
            photoCell.imageView.image = image ?? UIImage(named: placeHoldImage)
            return photoCell
        } else if let audio = addedItems.data[indexPath.item] as? AudioModel {
            let audioCell = collectionView.dequeueReusableCellWithReuseIdentifier("AudioItem", forIndexPath: indexPath) as! UIAudioCell
            
            //audioCell.audio = audio
            let duration = Int(audio.duration)
            let length = "\(duration)\""
            audioCell.playSound.text = length
            
            // single digit and double digit have different size for button
            audioCell.barChartNums = audio.samples
            //audioCell.setNeedsLayout()
            return audioCell
            
        } else {
            return collectionView.dequeueReusableCellWithReuseIdentifier("PhotoItem", forIndexPath: indexPath)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var size = RecordSettings.photoItemSize
        if let audio = addedItems.data[indexPath.row] as? AudioModel {
            size = RecordSettings.audioItemSize
            size.width = UIAudioCell.calculateButtonWidth(audioDuration: audio.duration, boundsWidth: view.bounds.width)
        }
        
        return size
    }
    
    func collectionView(collectionView: UICollectionView, shouldTakeAllRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if addedItems.data[indexPath.row] is AudioModel {
            return true
        } else {
            return false
        }
    }
    
    
    
    
    //MARK: Image Viewer Delegate
    func didDeleteModel(atParentIndex idx: Int) {
        audioPlayerShouldStop()  //TODO: maybe use KVO of model data for audio player should stop
        collectionView.deleteItemsAtIndexPaths([NSIndexPath(forItem: idx, inSection: 0)])
    }
    
    func imageViewerParentRect(atIndexPath idx: NSIndexPath) -> CGRect {
        if let rect = collectionView.collectionViewLayout.layoutAttributesForItemAtIndexPath(idx)?.frame {
            return collectionView.convertRect(rect, toView: view)
        } else {
            return CGRect(origin: view.center, size: CGSizeZero)
        }
    }
    
    func imageViewerWillAppear(atIndexPath idx: NSIndexPath?) {
        if let idx = idx {collectionView.cellForItemAtIndexPath(idx)?.hidden = true}
    }
    func imageViewerDidAppear(atIndexPath idx: NSIndexPath?) {
        if let idx = idx {collectionView.cellForItemAtIndexPath(idx)?.hidden = false}
        statusBarShouldHide = true
    }
    
    func imageViewerWillDisappear(atIndexPath idx: NSIndexPath?) {
        if let idx = idx {collectionView.cellForItemAtIndexPath(idx)?.hidden = true}
        statusBarShouldHide = false
        
    }
    func imageViewerDidDisappear(atIndexPath idx: NSIndexPath?) {
        if let idx = idx {collectionView.cellForItemAtIndexPath(idx)?.hidden = false}
        if statusBarShouldHide {
            statusBarShouldHide = false
        }
    }
    
    
}














