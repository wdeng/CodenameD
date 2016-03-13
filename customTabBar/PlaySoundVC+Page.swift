//
//  PlaySoundVC+Page.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 1/15/16.
//  Copyright © 2016 Wenxiang Deng. All rights reserved.
//

import UIKit
import Parse

extension PlaySoundViewController: UIPageViewControllerDataSource,UIPageViewControllerDelegate {
    //TODO: 可以变成 一个独立的vc probably need to check what is needed
    func createPageViewController() {
        pageViewController = storyboard!.instantiateViewControllerWithIdentifier("PageController") as! UIPageViewController
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        let firstController = viewControllerAtIndex(0)!
        
        pageViewController.setViewControllers([firstController], direction: .Forward, animated: false, completion: nil)
        
        pageViewController!.willMoveToParentViewController(self)
        self.addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
    }
    
    func resetCurrentContentController(index: Int, direction dir: UIPageViewControllerNavigationDirection, animated: Bool) {
        
        var vcs: [UIViewController]? = nil
        if let currentVC = viewControllerAtIndex(index) {
            vcs = [currentVC]
        }
        //print("will move to \(vcs?.first)")
        //pageViewScrollInTransit = true
        pageViewController.setViewControllers(vcs, direction: dir, animated: animated){ _ in
            //self.pageViewScrollInTransit = false
        }
    }
    
    func viewControllerAtIndex(index: Int) -> ImageTableContentController? {
        //print(index)
        if (index < 0) || (index >= episode.sectionDurations.count) {
            return nil
        }
        
        let vc = storyboard?.instantiateViewControllerWithIdentifier("ImageTableVC") as! ImageTableContentController
        
        vc.itemIndex = index
        
        //vc.images = []
        AppUtils.switchOnActivityIndicator(vc.activityIndicator, forView: vc.tableView, ignoreUser:  false)
        ParseActions.fetchImages(episode.imageSets[index]) { (imagesData) -> Void in
            if let images = imagesData as? [UIImage] {
                vc.images = images
            } else if let datas = imagesData as? [NSData] {
                for data in datas {
                    if let im = UIImage(data: data) {
                        vc.images.append(im)
                    }
                }
            }
            
            vc.activityIndicator.stopAnimating()
            vc.tableView.reloadData()
            
        }
        return vc
    }
    
    //MARK: UIPageViewController DataSource and Delegate,
    
    //These method only responsible for gesture sliding the VCs
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! ImageTableContentController
        return viewControllerAtIndex(itemController.itemIndex-1)

    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! ImageTableContentController
        return viewControllerAtIndex(itemController.itemIndex+1)
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        pageViewPendingSection = (pendingViewControllers.first as! ImageTableContentController).itemIndex
        progressBar.sectionSelectedByUser = true
        pageViewScrollInTransit = true
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        pageViewScrollInTransit = false
        
        if completed {
            progressBar.currentSection = pageViewPendingSection
        }
        else if finished {
            //If didn't successfully finished
        }
        
        let currentSection = progressBar.sectionForPosition(progressBar.currentPosition)
        if currentSection == progressBar.currentSection {
            progressBar.sectionSelectedByUser = false
        }
    }

}































