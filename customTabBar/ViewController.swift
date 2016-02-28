//
//  ViewController.swift
//  DragNDropCollectionView
//
//  Created by Wenxiang Deng on 2/19/16.
//  Copyright © 2016 Wenxiang Deng. All rights reserved.
//

import UIKit

struct RecordCollectionSettings {
    static let photoItemSize: CGSize = CGSize(width: 88, height: 88)
    static let audioItemSize: CGSize = CGSize(width: UIScreen.mainScreen().bounds.width - 82, height: 40)
    static let itemMinSpacing: CGFloat = 2.0
    static let itemSectInset: UIEdgeInsets = UIEdgeInsetsMake(4.0, 10.0, 4.0, 10.0)
    static var photoitemLimit: Int? = 4
}

class PhotoModel {
    init(item: Int) {
        photo = "\(item)"
    }
    var photo = ""
}
class AudioModel {
    
    init(item: Int) {
        audio = "\(item)"
    }
    var audio = ""
}

func generateRandomData() -> RecordingModel {
    let numberOfRows = 49
    //let numberOfItemsPerRow = 3
    let model = RecordingModel()
    
    model.data = (0..<numberOfRows).map { x in
        if x % 6 == 2 {
            return AudioModel(item: x) //(0..<numberOfItemsPerRow).map { y in "\(x), \(y)" }
        } else {
            return PhotoModel(item: x)
        }
    }
    
    return model
}

extension Array {
    mutating func moveItemAtIndex(fromIndex: Int, toIndex: Int) {
        let element = self.removeAtIndex(fromIndex)
        self.insert(element, atIndex: toIndex)
    }
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

class ViewController: UIViewController, ImageViewerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!

    var model = generateRandomData()
    var storedOffsets = [Int: CGFloat]()
    var colorTracker = 0
    var updateTime: NSTimer?
    private var longPress = UILongPressGestureRecognizer()
    
    private var statusBarShouldHide: Bool = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    override func prefersStatusBarHidden() -> Bool {
        return statusBarShouldHide
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = editButtonItem()
        navigationItem.rightBarButtonItem?.action = Selector("editButtonPressed")
        //collectionView.allowsSelection = true
        
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 4, right: 8)
        //collectionView.collectionViewLayout = LeftAlignedLayout()
        let layout = collectionView.collectionViewLayout as! LeftAlignedLayout
        layout.delegate = self
        
        longPress = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPress.minimumPressDuration = 0.3
        longPress.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //let layout = collectionView.collectionViewLayout as! LeftAlignedLayout
        //TODO: doesn't support screen rotate
        //layout.invalidateLayout()  //  Snapshotting a view that has not been rendered results in an empty snapshot. Ensure your view has been rendered at least once before snapshotting or snapshot after screen updates.
        
        //snapshotViewAfterScreenUpdates(afterUpdates: Bool) -> UIView
    }
    
    
    //MARK: Image Viewer Delegate
    func didDeleteModel(atParentIndex idx: Int) {
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

// Edit scene
extension ViewController {
    
    func editButtonPressed() {
        guard let idx = collectionView.indexPathsForSelectedItems() else {return} //indexPathsForVisibleItems()
        if self.editing {
            setEditing(false, animated: true)
            //navigationItem.rightBarButtonItem = closeButton
            
            collectionView.removeGestureRecognizer(longPress)
            collectionView.allowsMultipleSelection = false
            for i in idx { collectionView.deselectItemAtIndexPath(i, animated: true) }
        }
        else {
            setEditing(true, animated: true)
            //deleteButton.enabled = false
            //navigationItem.rightBarButtonItem = deleteButton
            
            collectionView.addGestureRecognizer(longPress)
            collectionView.allowsMultipleSelection = true
        }
        
    }
    
    
    @IBAction func deleteAction(sender: AnyObject) {
        guard let idx = collectionView.indexPathsForSelectedItems() else {return}
        let rank = idx.sort({$0.item > $1.item}) // rank in reverse order
        
        collectionView.performBatchUpdates({
            for i in rank {
                self.model.data.removeAtIndex(i.item)
                self.collectionView.deleteItemsAtIndexPaths([i])  // have to be like this because model missmatch if not reverse order
            } }, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if collectionView.allowsMultipleSelection {
            return true
        } else {
            //show image, or play sound
            if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? UIPhotoCell {
                performSegueWithIdentifier("openImageViewer", sender: cell)
            }
            
            //print(collectionView.collectionViewLayout.layoutAttributesForItemAtIndexPath(idx)?.frame)
            // another idea is to slide the collection view to the visible cell
            
            return false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "openImageViewer") {
            let vc = segue.destinationViewController as! ImageCollectionViewController
            vc.delegate = self
            vc.model = model
            
            let cell = sender as! UIPhotoCell
            vc.currentParentIndexPath = collectionView.indexPathForCell(cell)!
            
            vc.placeHoldViewForAnimation = ImageCollectionViewController.placeHolderImageView(forImageView: cell.imageView, presentingView: view)
            vc.placeHoldViewForAnimation.contentMode = .ScaleAspectFill
            vc.placeHoldViewForAnimation.clipsToBounds = true
        }
    }
}



// collection view datasource
extension ViewController: LeftAlignedLayoutDelegate, UICollectionViewDataSource, UICollectionViewDelegate  {  //UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.data.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let text = model.data[indexPath.row] as? PhotoModel { //TODO: change when actually use
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoItem", forIndexPath: indexPath) as! UIPhotoCell
            cell.imageView.image = UIImage(named: placeHoldImage)
            cell.textLabel.text = text.photo
            return cell
        } else if let text = model.data[indexPath.row] as? AudioModel { //TODO: change when actually use
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AudioItem", forIndexPath: indexPath) as! UIAudioCell
            cell.textLabel.text = text.audio
            return cell
        } else {
            return collectionView.dequeueReusableCellWithReuseIdentifier("PhotoItem", forIndexPath: indexPath)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var size = RecordCollectionSettings.photoItemSize
        if (model.data[indexPath.row] is AudioModel) {
            size = RecordCollectionSettings.audioItemSize
        }// else if (model[indexPath.section] as? [String]) != nil {size = RecordCollectionSettings.photoItemSize}
        
        return size
    }
    
    func collectionView(collectionView: UICollectionView, shouldTakeAllRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if model.data[indexPath.row] is AudioModel {
            return true
        } else {
            return false
        }
    }
}














