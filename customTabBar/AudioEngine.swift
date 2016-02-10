//
//  SoundPlayer.swift
//  PitchPerfect
//
//  Created by Wenxiang Deng on 12/2/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import AVFoundation


class SoundPlayer: NSObject {
    var audioPlayer: AVAudioPlayer!
}













/*
var audioEngine:AVAudioEngine!
audioEngine = AVAudioEngine()
audioFile = try! AVAudioFile(forReading: xxxxxxx.first!.filePathUrl)


@IBAction func playChipmunkAudio(sender: UIButton){
    playAudioWithVariablePitch(800)
}

func playAudioWithVariablePitch(pitch: Float){
    audioPlayer.stop()
    audioEngine.stop()
    audioEngine.reset()
    
    let audioPlayerNode = AVAudioPlayerNode()
    audioEngine.attachNode(audioPlayerNode)
    
    let changePitchEffect = AVAudioUnitTimePitch()
    changePitchEffect.pitch = pitch
    audioEngine.attachNode(changePitchEffect)
    
    audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
    audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
    
    audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
    try! audioEngine.start()
    
    audioPlayerNode.play()
}*/