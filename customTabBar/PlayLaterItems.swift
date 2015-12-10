//
//  PlayLaterItems.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/8/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit

class PlayLaterItems: NSObject {
    var titles = [String]()
    var fileURLs = [NSURL]()
    var ids = [Int]()
    var addedIDs = Set<Int>()
    
    var episodes: [Episode]!
    
    
    
    
    
    func addItem(newItem: AnyObject) ->Bool {
        if let item = newItem as? Episode {
            let id = item.id
            if (!addedIDs.contains(id)) {
                addedIDs.insert(id)
                ids.insert(id, atIndex: 0)
                return true
            }
        }
        
        
        return false
    }
}

