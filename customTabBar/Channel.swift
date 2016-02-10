//
//  Person.swift
//  TheMovieDB
//
//  Created by Jason on 1/11/15.
//

import UIKit

// NOTE: - The Person class now extends NSObject, and conforms to NSCoding

struct UserProfileKeys {
    static let Name = "ProfileName"
    static let Username = "Username"
    static let FollowerNum = "FollowerNum"
    static let FollowingNum = "FollowingNum"
    static let IsFollowing = "IsFollowing"
    static let ProfilePhoto = "ProfilePhoto"
    static let Intro = "Intro"
    static let Weblink = "Weblink"
    static let IsCurrentUser = "IsCurrentUser"
    static let UserID = "UserID"
}

class Channel : NSObject, NSCoding {
    
    struct Keys {
        static let Name = "name"
        static let ProfilePath = "profile_path" //// optional profile image
        static let Episodes = "episodes"
        static let ID = "id"
        static let TwitterPath = "twitter_path"
        static let ChannelWebsite = "channel_website"
    }
    
    var name = ""
    var id = 0
    var imagePath = ""
    var episodes = [Episode]()
    
    init(dictionary: [String : AnyObject]) {
        name = dictionary[Keys.Name] as! String
        id = dictionary[Keys.ID] as! Int
        
        if let pathForImgage = dictionary[Keys.ProfilePath] as? String {
            imagePath = pathForImgage
        }
    }
    
    var image: UIImage? {
        get {
            return nil //TheMovieDB.Caches.imageCache.imageWithIdentifier(imagePath)
        }
        
        set {
            //TheMovieDB.Caches.imageCache.storeImage(image, withIdentifier: imagePath)
        }
    }
    
    
    // MARK: - NSCoding
    
    func encodeWithCoder(archiver: NSCoder) {
        
        // archive the information inside the Person, one property at a time
        archiver.encodeObject(name, forKey: Keys.Name)
        archiver.encodeObject(id, forKey: Keys.ID)
        archiver.encodeObject(imagePath, forKey: Keys.ProfilePath)
        archiver.encodeObject(episodes, forKey: Keys.Episodes)
    }

    required init(coder unarchiver: NSCoder) {
        super.init()
        
        // Unarchive the data, one property at a time
        name = unarchiver.decodeObjectForKey(Keys.Name) as! String
        id = unarchiver.decodeObjectForKey(Keys.ID) as! Int
        imagePath = unarchiver.decodeObjectForKey(Keys.ProfilePath) as! String
        episodes = unarchiver.decodeObjectForKey(Keys.Episodes) as! [Episode]
    }
}


