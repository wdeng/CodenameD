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
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
