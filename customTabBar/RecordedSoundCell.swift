//
//  RecordedSoundCell.swift
//  PitchPerfect
//
//  Created by Wenxiang Deng on 11/25/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import AVFoundation

class RecordedSoundCell: UITableViewCell {
    
    
    
    @IBOutlet weak var audioButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var audioLevels: BarChartView!
    @IBOutlet weak var playSound: UILabel!
    var audio: RecordedAudio!
    var insetForLabel: CGFloat!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.playSound.layer.cornerRadius = RecordSettings.recordedAudioCellCornerRadius
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        audioLevels.soundLevelEdgeInsetRight = insetForLabel
        audioLevels.backgroundColor = RecordSettings.audioButtonColor
        
    }
    
    
    
    func calculateButtonWidth(audioDuration duration: Double, boundsWidth: CGFloat) -> CGFloat {
        let durationInterval = RecordSettings.recordedDurationLimit.1 - RecordSettings.recordedDurationLimit.0
        let ratio = min(1.0, CGFloat(duration / durationInterval))
        let maxButtonWidth = boundsWidth - RecordSettings.minCellBlankWidth
        let minButtonWidth = RecordSettings.minAudioButtonWidth
        
        return ratio * (maxButtonWidth - minButtonWidth) + minButtonWidth
        
        
    }
    
}
