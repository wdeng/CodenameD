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
        
        let firstController = (sectionNum > progressBar.currentSection) ? viewControllerAtIndex(progressBar.currentSection) : viewControllerAtIndex(0)
        
        firstController.willMoveToParentViewController(pageViewController)
        pageViewController.setViewControllers([firstController], direction: .Forward, animated: false, completion: nil)
        firstController.didMoveToParentViewController(pageViewController)
        pageViewController!.willMoveToParentViewController(self)
        self.addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
    }
    
    func resetCurrentContentController(index: Int, direction dir: UIPageViewControllerNavigationDirection, animated: Bool) {
        let currentVC = (sectionNum > index) ? viewControllerAtIndex(index) : viewControllerAtIndex(0)
        currentVC.willMoveToParentViewController(pageViewController)
        print("will move to \(currentVC)")
        pageViewScrollInTransit = true
        pageViewController.setViewControllers([currentVC], direction: dir, animated: animated){ success in
            self.pageViewScrollInTransit = false
        }
        currentVC.didMoveToParentViewController(pageViewController)
    }
    
    func viewControllerAtIndex(index: Int) -> ImageTableContentController {
        //print(index)
        let vc = storyboard?.instantiateViewControllerWithIdentifier("ImageTableVC") as! ImageTableContentController
        
        if index > -1 && index < sectionNum {
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
        } else {
            
        }
        print("image tvc current itemIndex: \(vc.itemIndex)")
        return vc
        
    }
    
    //MARK: UIPageViewController DataSource and Delegate
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let itemController = viewController as! ImageTableContentController
        if itemController.itemIndex > 0 {
            return viewControllerAtIndex(itemController.itemIndex-1)
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        print(pageViewController.childViewControllers)
        let itemController = viewController as! ImageTableContentController
        
        if itemController.itemIndex + 1 < sectionNum {
            print("delegate called vc at idx")
            return viewControllerAtIndex(itemController.itemIndex+1)
        }
        return nil
    }
    
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        pageViewPendingSection = (pendingViewControllers.first as! ImageTableContentController).itemIndex
        progressBar.sectionSelectedByUser = true
        pageViewScrollInTransit = true
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        pageViewScrollInTransit = false
        let currentSection = progressBar.sectionForLocation(progressBar.positionForValue(progressBar.value))
        if completed {
            progressBar.currentSection = pageViewPendingSection
        }
        else if finished {
            //If didn't successfully finished
        }
        
        
        if currentSection == progressBar.currentSection {
            progressBar.sectionSelectedByUser = false
        }
    }

}