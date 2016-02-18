//
//  EditProfileController.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 1/25/16.
//  Copyright © 2016 Wenxiang Deng. All rights reserved.
//

import UIKit

class EditProfileController: UITableViewController {
    //TODO: use left view textField.leftView to set edit profile items
    //http://stackoverflow.com/questions/22326288/how-do-i-add-padding-to-a-uitextfield-with-an-icon
    //http://stackoverflow.com/questions/27903500/swift-add-icon-image-in-uitextfield
    
//    var imageView = UIImageView();
//    var image = UIImage(named: "email.png");
//    imageView.image = image;
//    emailField.leftView = imageView;
//    emailField.leftViewMode = UITextFieldViewMode.Always
    
    
//    UIView *vwContainer = [[UIView alloc] init];
//    [vwContainer setFrame:CGRectMake(0.0f, 0.0f, 50.0f, 45.0f)];
//    [vwContainer setBackgroundColor:[UIColor clearColor]];
//    
//    UIImageView *icon = [[UIImageView alloc] init];
//    [icon setImage:[UIImage imageNamed:@"text-input-icon-password-key.png"]];
//    [icon setFrame:CGRectMake(0.0f, 0.0f, 45.0f, 45.0f)];
//    [icon setBackgroundColor:[UIColor lightGrayColor]];
//    
//    [vwContainer addSubview:icon];
//    
//    [self.passwordTextField setLeftView:vwContainer];
//    [self.passwordTextField setLeftViewMode:UITextFieldViewModeAlways];
    
    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var webLink: UITextField!
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var profilePicCell: UITableViewCell!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        webLink.text = nil
        print(displayName.text)
        print(webLink.text)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

}
