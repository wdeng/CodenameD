//
//  ImageCollectionViewController.swift
//  DragNDropCollectionView
//
//  Created by Wenxiang Deng on 2/22/16.
//  Copyright © 2016 Wenxiang Deng. All rights reserved.
//

import UIKit

let placeHoldImage = "image1.jpg"

@objc protocol ImageViewerDelegate {
    func didDeleteModel(atParentIndex idx: Int)
    
    optional func imageViewerWillAppear(atIndexPath idx: NSIndexPath?)
    optional func imageViewerDidAppear(atIndexPath idx: NSIndexPath?)
    optional func imageViewerWillDisappear(atIndexPath idx: NSIndexPath?)
    optional func imageViewerDidDisappear(atIndexPath idx: NSIndexPath?)
    
    optional func imageViewerParentRect(atIndexPath idx: NSIndexPath) -> CGRect
}

class ImageCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var model: RecordingModel!// = RecordingModel()
    var placeHoldViewForAnimation: UIImageView!
    var currentParentIndexPath: NSIndexPath! = NSIndexPath(forItem: 0, inSection: 0)
    var currentIndexPath: NSIndexPath? {
        get{
            return collectionView.indexPathForItemAtPoint(collectionView.convertPoint(view.center, fromView: view))
        }
    }
    var currentCell: ImageViewCell? {
        get {
            return (currentIndexPath == nil) ? nil : collectionView.cellForItemAtIndexPath(currentIndexPath!) as? ImageViewCell
        }
    }
    
    var delegate: ImageViewerDelegate?
    var supportedOrientations = UIInterfaceOrientationMask.Portrait
    var orientationBeforeDismiss: UIInterfaceOrientation = .Unknown
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitioningDelegate = self
        
        //TODO: currently doesn't support edit in this scene
        //ButtonUtils.addShadow(closeButton)
        //ButtonUtils.addShadow(deleteButton)
        if model == nil {
            debugPrint("model is not set")
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        supportedOrientations = .AllButUpsideDown
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: view.bounds.size.width + 10, height: view.bounds.size.height)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("orientationDidChange"),
            name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func contentOffsetX(forImageViewer imageView: UICollectionView, forIndexPath idxPath: NSIndexPath) -> CGFloat {
        return imageView.frame.width * CGFloat(idxPath.item)
    }

    // MARK: UICollectionView DataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.data.photoIdxList().count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageViewCell", forIndexPath: indexPath) as! ImageViewCell
        let modelIdx = model.data.photoIdxList()[indexPath.item]
        if let image = model.data[modelIdx] as? PhotoModel { //TODO: as? UIImage
            cell.imageView.image = image
        } else {
            let image = UIImage(named: placeHoldImage)!
            cell.imageView.image = image
        }
        
        cell.panGesture = UIPanGestureRecognizer(target: self, action: "handlePan:")
        cell.addGestureRecognizer(cell.panGesture)
        cell.panGesture.delegate = self
        
        cell.tapGesture = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        cell.tapGesture.numberOfTapsRequired = 1
        cell.scrollView.addGestureRecognizer(cell.tapGesture)
        
        cell.tapGesture.requireGestureRecognizerToFail(cell.doubleTap)
        
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if self.isBeingPresented() {
            cell.hidden = true
        } else if cell.hidden {
            cell.hidden = false
        }
    }
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? ImageViewCell {
            cell.scrollView.zoomScale = cell.scrollView.minimumZoomScale
            cell.removeGestureRecognizer(cell.panGesture)
            cell.scrollView.removeGestureRecognizer(cell.tapGesture)
        }
    }
}

extension ImageCollectionViewController { //Orientations
    
    struct Orientation {
        static var previousIndexPath: NSIndexPath!
    }
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if placeHoldViewForAnimation != nil {
            return .Portrait
        } else {
            return supportedOrientations
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        Orientation.previousIndexPath = currentIndexPath
        collectionView.cellForItemAtIndexPath(currentParentIndexPath)?.hidden = false
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize(width: size.width + 10, height: size.height)
    }
    
    func orientationDidChange() {
        if let idxPath = Orientation.previousIndexPath {
            collectionView.contentOffset.x = contentOffsetX(forImageViewer: collectionView, forIndexPath: idxPath)
        } //TODO: if idxPath is large, content offset maximum problem is still an issue
    }
}

extension ImageCollectionViewController {  // Actions
    @IBAction func closeImageViewer(sender: UIButton) {
        //print((self.presentingViewController?.childViewControllers.first as? ViewController))
        self.dismissViewControllerAnimated(true) {}
    }
    
    @IBAction func deleteCurrentImage() {
        if let idx = currentIndexPath {
            let parentIdx = model.data.photoIdxList()[idx.item]
            model.data.removeAtIndex(parentIdx)
            collectionView.deleteItemsAtIndexPaths([idx])
            delegate?.didDeleteModel(atParentIndex: parentIdx)
        }
    }
}



extension ImageCollectionViewController: UIViewControllerTransitioningDelegate {   ///Animations
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ImageViewerTransition(duration: 0.25, transitType: .Present)
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ImageViewerTransition(duration: 0.35, transitType: .Dismiss)
    }
    
    func performPresentAnimation(finished: (Bool) -> Void) {
        if placeHoldViewForAnimation == nil {
            let rect = view.bounds.insetBy(dx: 80, dy: 50)
            placeHoldViewForAnimation = UIImageView(frame: rect)
            placeHoldViewForAnimation.image = (model.data.first as? UIImage) ?? UIImage(named: placeHoldImage)
            placeHoldViewForAnimation.alpha = 0.0
        }
        
        let topView = view.window ?? view
        topView?.addSubview(placeHoldViewForAnimation)
        
        self.view.alpha = 0.0
        let imageNewFrame = ImageUtils.getFitRect(placeHoldViewForAnimation.image!, targetRect: view.bounds)
        
        var idxPath = NSIndexPath(forItem: 0, inSection: 0)
        if let idx = self.model.data.photoIdxList().indexOf(self.currentParentIndexPath.item) {
            idxPath = NSIndexPath(forItem: idx, inSection: 0)
        }
        
        self.delegate?.imageViewerWillAppear?(atIndexPath: currentParentIndexPath)
        UIView.animateWithDuration(0.25,
            delay: 0,
            options: [.BeginFromCurrentState, .CurveEaseInOut],
            animations: {
                self.view.alpha = 1.0
                self.placeHoldViewForAnimation.alpha = 1.0
                self.placeHoldViewForAnimation.frame = imageNewFrame
            }) { [unowned self] (completed) in
                self.currentCell?.hidden = false
                self.collectionView.contentOffset.x = self.contentOffsetX(forImageViewer: self.collectionView, forIndexPath: idxPath)
                self.delegate?.imageViewerDidAppear?(atIndexPath: self.currentParentIndexPath)
                self.placeHoldViewForAnimation.removeFromSuperview()
                self.placeHoldViewForAnimation = nil
                finished(completed)
        }
        
    }
    
    
    override func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        orientationBeforeDismiss = UIApplication.sharedApplication().statusBarOrientation
        supportedOrientations = .Portrait
        super.dismissViewControllerAnimated(flag, completion: completion)
    }
    
    func performDismissAnimation(finished: (Bool) -> Void) {
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
        
        var rect: CGRect?
        var targetAlpha: CGFloat = 1.0
        
        if let cell = currentCell {
            let topView = view
            
            if placeHoldViewForAnimation == nil {
                placeHoldViewForAnimation = ImageCollectionViewController.placeHolderImageView(forImageView: cell.imageView, presentingView: topView)
            }
            if !placeHoldViewForAnimation.isDescendantOfView(topView) {
                topView.addSubview(placeHoldViewForAnimation)
            }
            
            let currentIdxPath = collectionView.indexPathForCell(cell)!
            
            currentParentIndexPath = NSIndexPath(forItem: model.data.photoIdxList()[currentIdxPath.item], inSection: 0)
            delegate?.imageViewerWillDisappear?(atIndexPath: currentParentIndexPath)
            rect = delegate?.imageViewerParentRect?(atIndexPath: currentParentIndexPath)
            
            cell.hidden = true
            placeHoldViewForAnimation.clipsToBounds = true
            
        } else {
            targetAlpha = 0.0
        }
        
        if orientationBeforeDismiss.isLandscape && (rect != nil) {
            let tmp = rect!.origin.x
            rect!.origin.x = rect!.origin.y
            rect!.origin.y = tmp
            if orientationBeforeDismiss == .LandscapeRight {
                rect!.origin.x += (rect!.height - rect!.width)/2
                rect!.origin.y = self.view.frame.size.width - rect!.origin.y - (rect!.width + rect!.height)/2
            } else if orientationBeforeDismiss == .LandscapeLeft {
                rect!.origin.y += (rect!.width - rect!.height)/2
                rect!.origin.x = self.view.frame.size.height - rect!.origin.x - (rect!.width + rect!.height)/2
            }
        }
        
        //placeHoldViewForAnimation.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        UIView.animateWithDuration(0.35,
            delay: 0,
            options: [.BeginFromCurrentState, .CurveEaseInOut],
            animations: {
                
                self.collectionView.alpha = 0.0
                self.placeHoldViewForAnimation?.alpha = targetAlpha
                self.placeHoldViewForAnimation?.frame = rect ?? CGRect(origin: self.view.center, size: CGSizeZero)
                self.placeHoldViewForAnimation?.layer.shadowOpacity = 0.0

                if self.orientationBeforeDismiss == .LandscapeLeft {
                    self.placeHoldViewForAnimation.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
                } else if self.orientationBeforeDismiss == .LandscapeRight {
                    self.placeHoldViewForAnimation.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
                }
                
            }) { (completed) in
                self.delegate?.imageViewerDidDisappear?(atIndexPath: self.currentParentIndexPath)
                self.placeHoldViewForAnimation?.removeFromSuperview()
                self.placeHoldViewForAnimation = nil
                finished(completed)
        }
        
    }
    
    class func placeHolderImageView(forImageView imageView: UIImageView, presentingView: UIView) -> UIImageView {
        
        let image = imageView.image ?? UIImage(named: placeHoldImage)!
        let placeHoldView = UIImageView(image: image)
        
        placeHoldView.clipsToBounds = true
        placeHoldView.contentMode = .ScaleAspectFill
        
        if imageView.contentMode == .ScaleAspectFit {
            let rect = ImageUtils.getFitRect(image, targetRect: imageView.frame) // the frame is zoomed inside of scrollview bounds (zoomed)
            placeHoldView.frame = CGRect(origin: presentingView.convertPoint(rect.origin, fromView: imageView.superview), size: rect.size)/// scroll view coord system is the zoomed coord
        } else {
            placeHoldView.frame = presentingView.convertRect(imageView.frame, fromView: imageView.superview)
            placeHoldView.contentMode = imageView.contentMode
        }
        
        return placeHoldView
    }
    
}






























