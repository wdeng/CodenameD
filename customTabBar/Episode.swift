//
//  Movie.swift
//  TheMovieDB
//
//  Created by Jason on 1/11/15.
//

import UIKit

class Episode : NSObject, NSCoding {
    
    struct Keys {
        static let Title = "title"
        static let ID = "id"
        static let ThumbPath = "thumbnail_path"
        static let ReleaseDate = "release_date"
        static let Duration = "duration"
        static let FilePath = "file_path"
        static let Likes = "likes"
        static let Dislikes = "dislikes"
    }
    
    var title = ""
    var id = 0
    var posterPath: String? = nil
    var releaseDate: NSDate? = nil
        
    init(dictionary: [String : AnyObject]) {
        title = dictionary[Keys.Title] as! String
        id = dictionary[Keys.ID] as! Int
        posterPath = dictionary[Keys.ThumbPath] as? String
        
        //if let releaseDateString = dictionary[Keys.ReleaseDate] as? String {
        //    releaseDate = TheMovieDB.sharedDateFormatter.dateFromString(releaseDateString)
        //}
    }
    
    var posterImage: UIImage? {
        
        get {
            return nil//TheMovieDB.Caches.imageCache.imageWithIdentifier(posterPath)
        }
        
        set {
            //TheMovieDB.Caches.imageCache.storeImage(newValue, withIdentifier: posterPath!)
        }
    }
    
    // MARK: - NSCoding
    
    func encodeWithCoder(archiver: NSCoder) {
        
        archiver.encodeInteger(id, forKey: Keys.ID)
        archiver.encodeObject(title, forKey: Keys.Title)
        archiver.encodeObject(posterPath, forKey: Keys.ThumbPath)
        archiver.encodeObject(releaseDate, forKey: Keys.ReleaseDate)
    }
    
    required init(coder unarchiver: NSCoder) {
        super.init()
        
        id = unarchiver.decodeIntegerForKey(Keys.ID)
        title = unarchiver.decodeObjectForKey(Keys.Title) as! String
        posterPath = unarchiver.decodeObjectForKey(Keys.ThumbPath) as? String
        releaseDate = unarchiver.decodeObjectForKey(Keys.ReleaseDate) as? NSDate
    }
}



