//
//  DiscoverTVC+Search.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 2/14/16.
//  Copyright © 2016 Wenxiang Deng. All rights reserved.
//

import UIKit
import Parse

extension DiscoverViewController {
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        //if !searchController.active {return}
        //print("the current text is: \(fetchSearchData(searchController.searchBar.text))")
        if searchController.searchResultsController?.view.hidden == true {
            searchController.searchResultsController?.view.hidden = false
        }
        
        guard let vc = searchController.searchResultsController as? SearchResultTVC else {return}
        if searchController.searchBar.text != "" {
            fetchSearchData(searchController.searchBar.text?.lowercaseString) { results in
                vc.searchedUsers = results
                vc.tableView.reloadData()
            }
        } else {
            vc.searchedUsers = []
            vc.tableView.reloadData()
        }
        
    }
    
    func willPresentSearchController(searchController: UISearchController) {
        //searchController.searchBar.selectedScopeButtonIndex = 0
        dispatch_async(dispatch_get_main_queue()) {
            searchController.searchResultsController?.view.hidden = false
        }
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBarShouldResignFirstResponder()
    }
    
    //MARK: searchresult delegates
    
    func shouldPushViewController(vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func searchBarShouldResignFirstResponder() {
        if searchController.searchBar.isFirstResponder() {
            searchController.searchBar.resignFirstResponder()
        }
    }
    
    /*func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if !searchController.active {return}
        
        //guard let vc = searchController.searchResultsController as? SearchResultTVC else {return}
        //vc.searchedItems = selectedScope
        //vc.searchedItems =
    
        /*
        JWSearchResultsController *resultsController = (JWSearchResultsController *)self.searchController.searchResultsController;
        resultsController.searchBarScopeIndex = selectedScope;
        resultsController.filterString = self.searchController.searchBar.text; 
        */
    }*/
    
    
    func fetchSearchData(searchingString: String?, finished: ([PFUser]) -> Void) {
        //Parse
        //searchedData.removeAll()  //TODO: put to search bar did become first responder
        
        guard let str = searchingString else {return}
        
        guard let query = PFUser.query() else {return}
        query.whereKey("username", containsString: str)
        query.limit = 100
        query.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
            if error != nil {
                print("couldn't search")
                return
            }
            
            guard let users = objects else {return}
            
            var searchedUsers = [PFUser]()
            for object in users {
                guard let u = object as? PFUser else {continue}
                if (u.objectId! == PFUser.currentUser()?.objectId) || (u.username == nil) {continue}
                
                searchedUsers.append(u)
            }
            finished(searchedUsers)
        }
    }
}
















