//
//  EditProfileController.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 1/25/16.
//  Copyright © 2016 Wenxiang Deng. All rights reserved.
//

import UIKit
import Parse

class EditProfileController: UITableViewController, UITextFieldDelegate {
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
    @IBOutlet weak var webLink: UITextField!
    @IBOutlet weak var intro: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //saveButton.enabled = false
        webLink.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let user = PFUser.currentUser()!
        
        if let name = user["profileName"] {
            displayName.text = name as? String
        }
        if let web = user["website"] {
            webLink.text = web as? String
        }
        if let introduction = user["introduction"] {
            intro.text = introduction as? String
        }
        tabBarController?.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func saveProfile(sender: AnyObject) {
        
        if ((webLink.text?.isEmpty) == false) {
            if let urlString = verifyURL(webLink.text) {
                webLink.text = urlString
            } else {
                webLink.textColor = UIColor.redColor()
                return
            }
        }
        PFUser.currentUser()!["profileName"] = displayName.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        PFUser.currentUser()!["website"] = webLink.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        PFUser.currentUser()!["introduction"] = intro.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        AppUtils.addCustomView(toBarItem: saveButton)
        
        PFUser.currentUser()?.saveInBackgroundWithBlock{(success, error) -> Void in
            self.saveButton.customView = nil
            if success {
                self.performSegueWithIdentifier("saveEditProfile", sender: sender)
            } else {
                AppUtils.displayAlert("Could not upload Information", message: "Please try again later", onViewController: self)
            }
        }
        
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.redColor() {
            textView.textColor = UIColor.blackColor()
        }
    }
    
    
    @IBAction func resignKeyboard(sender: AnyObject) {
        sender.resignFirstResponder()
    }
    
    
    func verifyURL(urlString: String?) -> String? {
        //let link =  "http://www.yourUrl.com".stringByRemovingPercentEncoding!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        if var urlString = urlString?.stringByTrimmingCharactersInSet( NSCharacterSet.whitespaceAndNewlineCharacterSet()) {
            //let re = try! NSRegularExpression(pattern: "https?:\\/.*", options: .CaseInsensitive)
            
            let regex = "http(s)?://.*"
            if !NSPredicate(format: "SELF MATCHES %@", regex).evaluateWithObject(urlString.lowercaseString) {
                urlString = "http://" + urlString
            }
            
            //TODO: check if it works
            let reg = "http(s)?://([\\w-]+\\.)+[\\w-]+(/[\\w- ./?%#&=]*)?"
            
            if let url = NSURL(string: urlString) {
                if UIApplication.sharedApplication().canOpenURL(url) {
                    if NSPredicate(format: "SELF MATCHES %@", reg).evaluateWithObject(urlString.lowercaseString) {
                        return urlString
                    }
                }
            }
        }
        
        
        return nil
    }
}
