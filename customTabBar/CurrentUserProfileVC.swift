//
//  CurrentUserProfileVC.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 1/15/16.
//  Copyright © 2016 Wenxiang Deng. All rights reserved.
//

import UIKit

class CurrentUserProfileVC: ProfileViewController {
    
    // TODO: set tab bar controllers programatically
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func loadView() {
        print("hahah")
        super.loadView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("miao")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        print("hehe")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("ok")
    }

}
