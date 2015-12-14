//
//  LoginViewController.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/12/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import Parse

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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Parse
        if PFUser.currentUser() != nil {
            self.performSegueWithIdentifier("login", sender: self)
        }
    }
    
    //TODO: put in app settings
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)} ) )
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func turnOnActivityIndicator(ignoreUser: Bool) {
        activityIndicator = UIActivityIndicatorView(frame: view.bounds)
        activityIndicator.center = view.center
        activityIndicator.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        if ignoreUser {
            // maybe add a white view
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        }
    }
    
    @IBAction func login(sender: AnyObject) {
        
        if username.text == "" || password.text == "" {
            displayAlert("Error", message: "Please enter a username and password")
            return
        } //else if password.text?.characters.count < 8 {
            //displayAlert("Password too short", message: "Please enter password longer than 8 charactors")
            //return }
        
        turnOnActivityIndicator(true)
        var errorMessage = "Please try again later"
        if signUpActived {
            // Parse
            let user = PFUser()
            user.username = username.text
            user.password = password.text
            
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
                    self.displayAlert("Sign Up Failed", message: errorMessage)
                }
            })
        }
        else {
            PFUser.logInWithUsernameInBackground(username.text!, password: password.text!, block: { (user, error) -> Void in
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
                    self.displayAlert("Login Failed", message: errorMessage)
                }
            })
            // End Parse
        }
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        login_signupButton.hidden = true
        login_signupLabel.text = "Type your username"
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let name = textField.text
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
                self.displayAlert("Login Failed", message: errorMessage)
                return
            }
        })
        // End Parse
        
        
    }
    
    
    
    
    
    
    
    
    
    
    

}
