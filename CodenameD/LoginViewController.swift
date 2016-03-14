//
//  LoginViewController.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/12/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import Parse

//TODO: check if works even when this is not the first screeen
//var currentUserID = PFUser.currentUser()?.objectId

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var login_signupLabel: UILabel!
    @IBOutlet weak var login_signupButton: UIButton!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var signupActive = true
    var signUpActived = true
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        username.delegate = self
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        login_signupButton.hidden = true
        username.layer.cornerRadius = 5
        //username.alpha = 0.8
        password.layer.cornerRadius = 5
        //password.alpha = 0.8
        
        username.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        username.leftViewMode = .Always
        password.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        password.leftViewMode = .Always
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func login(sender: AnyObject) {
        
        if username.text == "" || password.text == "" {
            AppUtils.displayAlert("Error", message: "Please enter a username and password", onViewController: self)
            return
        } //else if password.text?.characters.count < 8 {
            //displayAlert("Password too short", message: "Please enter password longer than 8 charactors")
            //return }
        
        //TODO: should check username is legal, without spaces and special characters
        
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        AppUtils.switchOnActivityIndicator(activityIndicator, forView: view, ignoreUser:  true)
        var errorMessage = "Please try again later"
        if signUpActived {
            // Parse
            
            let regex = "^(?=.{2,15}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$"
            if !NSPredicate(format: "SELF MATCHES %@", regex).evaluateWithObject(username.text!.lowercaseString) {
                activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                AppUtils.displayAlert("Sign Up Failed", message: "Username illegal, please don't include spaces and special characters", onViewController: self)
                return
            }
            
            let user = PFUser()
            user.username = username.text?.lowercaseString
            user.password = password.text
            
            
            user["postUpdatedAt"] = user.updatedAt ?? NSDate()
            
            user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                if error == nil {
                    // Signed up
                    self.performSegueWithIdentifier("login", sender: self)
                    // TODO: could go back to
                } else {
                    if let errorString = error!.userInfo["error"] as? String {
                        errorMessage = errorString
                    }
                    AppUtils.displayAlert("Sign Up Failed", message: errorMessage, onViewController: self)
                }
            })
        }
        else {
            PFUser.logInWithUsernameInBackground(username.text!.lowercaseString, password: password.text!, block: { (user, error) -> Void in
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                if user != nil {
                    //Logged in
                    self.performSegueWithIdentifier("login", sender: self)
                    //TODO: go to front page
                } else {
                    if let errorString = error!.userInfo["error"] as? String {
                        errorMessage = errorString
                    }
                    AppUtils.displayAlert("Login Failed", message: errorMessage, onViewController: self)
                }
            })
            // End Parse
        }
        
    }
    
    @IBAction func usernameDidEnd(sender: UITextField) {
        sender.resignFirstResponder()
        password.becomeFirstResponder()
    }
    
    @IBAction func passwordDidEnd(sender: UITextField) {
        password.resignFirstResponder()
        login(login_signupButton)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        login_signupButton.hidden = true
        login_signupLabel.text = "Type your username"
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let name = textField.text?.lowercaseString
        if name == "" {
            return
        }
        
        // Parse
        var errorMessage = "Please try again later"
        let query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: name!)
        query.findObjectsInBackgroundWithBlock( {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                self.login_signupButton.hidden = false
                if objects!.count > 0 {
                    self.signUpActived = false //  the username is taken
                    self.login_signupButton.setTitle("Login", forState: .Normal)
                    self.login_signupLabel.text = "Username registered, please type password"
                    
                    
                }
                else {
                    //TODO: check if name is illegal ---- no # and stuff
                    self.signUpActived = true
                    self.login_signupButton.setTitle("Sign Up", forState: .Normal)
                    self.login_signupLabel.text = "Username available, please set password"
                }
            } else {
                
                if let errorString = error!.userInfo["error"] as? String {
                    errorMessage = errorString
                }
                AppUtils.displayAlert("Login Failed", message: errorMessage, onViewController: self)
                return
            }
        })
        // End Parse
        
        
    }
    
    
    
    
    
    
    
    
    
    
    

}
