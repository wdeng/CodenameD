//
//  RecordedAudio.swift
//  PitchPerfect
//
//  Created by Wenxiang Deng on 11/5/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit

// TODO: set to a class for persistence, currently not persistentable


//TODO: possibly problems because of struct not class

class AddedImageSet {
    // hold up to 4 images
    var images = [UIImage]()
    var sectionDuration = 0.0
    var itemIndex: Int = -1
}

class RecordedAudio {
    var filePathURL = NSURL()
    var title: String = ""
    var duration: Double = 0.0
    var itemIndex: Int = -2
    
    
    class func durationToClockTime(duration: Double) ->String {
        //let h = Int(duration) / 3600
        //let m = (Int(duration) % 3600) / 60
        //let s = (Int(duration) % 3600) / 60
        if duration < 3600 {
            return String(format: "%d:%02d", Int(duration) / 60, Int(duration) % 60)
        }
        else {
            return String(format: "%d:%02d:%02d", Int(duration) / 3600, (Int(duration) % 3600) / 60, (Int(duration) % 3600) % 60)
        }
        
    }
}



// = ["IMG_0006.jpg", "IMG_0006.jpg", "IMG_0006.jpg", "IMG_0006.jpg"]

//TODO: after finished, we can use