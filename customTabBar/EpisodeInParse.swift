//
//  AudioInParse.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 12/24/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import Foundation
import AVFoundation
import Parse

class EpisodeInParse: NSObject {
    var episode: NSURL?
    var imageSets: [PFFile]?
    var sectionDurations: [Float]?
}