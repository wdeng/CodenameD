//
//  PlaySoundVC+Page.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 1/15/16.
//  Copyright © 2016 Wenxiang Deng. All rights reserved.
//

import UIKit

extension PlaySoundViewController: UIPageViewControllerDataSource,UIPageViewControllerDelegate {
    //TODO: 可以变成 一个独立的vc
    func createPageViewController() {
        pageViewController = storyboard!.instantiateViewControllerWithIdentifier("PageController") as! UIPageViewController
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        let firstController = (playingSections.imageSets.count > progressBar.currentSection) ? viewControllerAtIndex(progressBar.currentSection) : viewControllerAtIndex(0)
        let startingViewControllers = [firstController]
        
        pageViewController.setViewControllers(startingViewControllers, direction: .Forward, animated: false, completion: nil)
        
        addChildViewController(pageViewController!)
        self.view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
        print(progressBar.currentSection)
    }
    
    func resetCurrentContentController(index: Int, direction dir: UIPageViewControllerNavigationDirection) {
        let currentVC = (playingSections.imageSets.count > index) ? viewControllerAtIndex(index) : viewControllerAtIndex(0)
        pageViewController.setViewControllers([currentVC], direction: dir, animated: true, completion: nil)
        
    }
    
    func viewControllerAtIndex(index: Int) -> ImageTableContentController {
        if index < playingSections.imageSets.count {
            let vc = storyboard?.instantiateViewControllerWithIdentifier("ImageTableVC") as! ImageTableContentController
            vc.images = playingSections.imageSets[index].images
            vc.itemIndex = index
            
            return vc
        }
        
        return ImageTableContentController()
        
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
        let itemController = viewController as! ImageTableContentController
        
        if itemController.itemIndex + 1 < playingSections.imageSets.count {
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
        
        let currentSection = progressBar.sectionForLocation(progressBar.positionForValue(progressBar.value))
        if completed {
            progressBar.currentSection = pageViewPendingSection
        }
        else if finished {
            //If didn't successfully finished
        }
        
        pageViewScrollInTransit = false
        if currentSection == progressBar.currentSection {
            progressBar.sectionSelectedByUser = false
        }
    }

}