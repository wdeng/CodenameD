//
//  ProfileHeaderView.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 2/3/16.
//  Copyright © 2016 Wenxiang Deng. All rights reserved.
//

import UIKit

class ProfileHeaderView: UIView {

    @IBOutlet weak var isFollowing: UIButton!
    @IBOutlet weak var followingNum: UIButton!
    @IBOutlet weak var followerNum: UIButton!
    
    @IBOutlet weak var profileUsername: UILabel!
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var userIntro: UILabel!
    @IBOutlet weak var userLink: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        followerNum.titleLabel!.lineBreakMode = .ByWordWrapping
        followerNum.titleLabel!.numberOfLines = 2
        followingNum.titleLabel!.lineBreakMode = .ByWordWrapping
        followingNum.titleLabel!.numberOfLines = 2
        
        isFollowing.layer.cornerRadius = 6.0
        
    }
    
    func setTitleWithNum(num: Int?, withText text: String) -> NSAttributedString {
        let numStr = NumUtils.abbreviateNum(num)
        let str = "\(numStr)\n\(text)"
        let attr = NSMutableAttributedString(string: str)
        var range = NSRange(location: 0, length: numStr.characters.count+1)
        
        attr.addAttributes([NSFontAttributeName: UIFont.systemFontOfSize(22.0, weight: UIFontWeightBold)], range: range)
        
        range = NSRange(location: numStr.characters.count+1, length: text.characters.count)
        attr.addAttributes([NSFontAttributeName: UIFont.systemFontOfSize(12.0), NSForegroundColorAttributeName: UIColor.lightGrayColor()], range: range)
        
        return attr
        
        
    }
    
    func setupProfile(withOptions options: [String: AnyObject?]) {
        //TODO: what if current ID is nil??????????????
        
        //following/follower num
        //followerNum.titleLabel.textAlignment = UITextAlignmentCenter;
        
        
        followingNum.setAttributedTitle(setTitleWithNum(nil, withText: "FOLLOWING"), forState: .Normal)
        followerNum.setAttributedTitle(setTitleWithNum(nil, withText: "FOLLOWERS"), forState: .Normal)
        
        
        
        
        
        
        
        
        
        // isFollowing/editProfile settings
        isFollowing.setTitle("Loading", forState: .Normal)
        if let id = options[UserProfileKeys.UserID] as? String {
            if id == currentUserID {
                isFollowing.setTitle("Edit Profile", forState: .Normal)
                //isFollowing.backgroundColor = UIColor.grayColor()
            } else {
                ParseActions.isFollowingFollower([id], withType: .Following) { (x) -> Void in
                    self.isFollowing.enabled = true
                    if x.first == true {
                        self.isFollowing.setTitle("Following", forState: .Normal)
                    } else {
                        self.isFollowing.setTitle("Follow", forState: .Normal)
                    }
                    //self.isFollowing.backgroundColor = UIColor.greenColor()
                }
            }
        } //TODO: need to setup the target for the buttons
        
        //username
        if let un = options[UserProfileKeys.Username] as? String {
            profileUsername.text = "@" + un
        } else {
            profileUsername.text = ""
        }
        //profile name
        if let name = options[UserProfileKeys.Name] as? String {
            profileName.text = name
        } else {
            profileName.text = (options[UserProfileKeys.Username] as? String) ?? "Profile Name"
        }
        
        //intro and weblink
        userIntro.numberOfLines = 20
        if let intro = options[UserProfileKeys.Intro] as? String {
            userIntro.text = intro.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
        if var link = options[UserProfileKeys.Weblink] as? String {
            link = link.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            
            let idx = link.startIndex
            if link.characters.count >= 8 {
                if link[idx ..< idx.advancedBy(7)] == "http://" {
                    link = link.substringFromIndex(idx.advancedBy(7))
                } else if link[idx ..< idx.advancedBy(8)] == "https://" {
                    link = link.substringFromIndex(idx.advancedBy(8))
                }
            }
            userLink.setTitle(link, forState: .Normal)
        }
        
        //tabBarController?.navigationItem.title = profileView.profileName.text
    }
    
    @IBAction func openWebLink(sender: UIButton) {
        // add uialert, add "http://" to the string, need to check if webpage when inputing like Instagram
        let urlString = addScheme(sender.titleForState(.Normal))
        if let url = NSURL(string: urlString ) {
            if UIApplication.sharedApplication().canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
    func addScheme(urlString: String?) -> String {

        if let urlString = urlString {
            let regex = "http(s)?://.*"
            if !NSPredicate(format: "SELF MATCHES %@", regex).evaluateWithObject(urlString) {
                return "http://" + urlString
            } else {
                return urlString
            }
        } else {
            return ""
        }
    }
    
    class func verifyURL(urlString: String?) -> NSURL? {
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
                        return url
                    }
                }
            }
        }
        
        
        return nil
    }
}


























