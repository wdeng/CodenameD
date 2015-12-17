//
//  AudioMerger.swift
//  PitchPerfect
//
//  Created by Wenxiang Deng on 12/9/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import AVFoundation

protocol AudioMergerDelegate {
    func mergingDidFinished(status: AVAssetExportSessionStatus)
}

class AudioMerger: NSObject {
    
    
    private var audios: [RecordedAudio] = []
    var imageSets: [AddedImageSet] = [AddedImageSet()]
    var outputAudio: NSURL?
    var exportSession: AVAssetExportSession?
    
    //let exportSession = AVAssetExportSession(asset: AVMutableComposition(), presetName: AVAssetExportPresetAppleM4A)
    
    private func bundleToSetions(items: [AnyObject]) {
        
        var currentSecionIndex = 0
        
        
        for i in 0 ..< items.count {
            if let item = items[i] as? AddedImageSet {
                if audios.last?.itemIndex == imageSets.last!.itemIndex { /// this also solves the first item as audio
                    currentSecionIndex++
                    imageSets.append(AddedImageSet())
                }
                imageSets.last!.itemIndex = currentSecionIndex
                imageSets.last!.images += item.images
            }
            else if let item = items[i] as? RecordedAudio {
                item.itemIndex = currentSecionIndex
                imageSets.last!.sectionDuration += item.duration   /// images hold the duration of the section
                audios.append(item)
            }
            else
            {
                print("something else added in recordedBundle")
            }
        }
        
        if (currentSecionIndex > 0) && (audios.last!.itemIndex != currentSecionIndex){
            imageSets[imageSets.count - 2].images += imageSets.last!.images
            imageSets.removeLast()
        }
        
    }
    
    
    
    
    
    init(withItems items: [AnyObject], toNewAudio: String = "combined.m4a") {
        super.init()
        
        bundleToSetions(items)
        var mergerAudios: [NSURL] = []
        
        for i in audios {
            mergerAudios.append(i.filePathURL)
        }
        
        outputAudio = merger(mergerAudios, toOneAudioName: toNewAudio)
    }
    
        
    
    var delegate: AudioMergerDelegate?
    
    func stopMerger() {
        if exportSession == nil{
            return
        }
        
        if (exportSession!.status == .Waiting) || (exportSession!.status == .Exporting) {
            exportSession!.cancelExport()
        }
    }
    
    func merger (audioURLs: [NSURL], toOneAudioName audio: String) -> NSURL? {
        //var error: NSError?
        //TODO:  how to check the quality exportSession and change to lower
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        
        var nextClipStartTime = kCMTimeZero
        let composition = AVMutableComposition()
        let compositionAudioTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid) //CMPersistentTrackID()
        
        for i in audioURLs {
            let avAsset = AVURLAsset(URL: i)
            let tracks = avAsset.tracksWithMediaType(AVMediaTypeAudio)
            
            if tracks.count == 0 {
                return nil
            }
            
            let timeRangeInAsset = CMTimeRange(start: kCMTimeZero, duration: avAsset.duration)
            let clipAudioTrack = tracks.first!
            do {
            try compositionAudioTrack.insertTimeRange(timeRangeInAsset, ofTrack: clipAudioTrack, atTime: nextClipStartTime)
            } catch _ {
                print("track error")
            }
            nextClipStartTime = CMTimeAdd(nextClipStartTime, timeRangeInAsset.duration)
        }
        
        //TODO: change the setting for AVAssetWriter,  if export session doesn't work
        
        exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
        if exportSession == nil {
            return nil
        }
        
        let resultPath = dirPath + "/" + audio
        print(resultPath)
        deleteDuplication(resultPath)
        let resultURL = NSURL.fileURLWithPath(resultPath)
        exportSession!.outputURL = resultURL
        exportSession!.outputFileType = AVFileTypeAppleM4A
        exportSession!.exportAsynchronouslyWithCompletionHandler({ () -> Void in
        
            switch self.exportSession!.status {
            case AVAssetExportSessionStatus.Failed:
                self.delegate?.mergingDidFinished(.Failed)
                print("failed \(self.exportSession!.error)")
            case AVAssetExportSessionStatus.Completed:
                print("Complete")
                self.delegate?.mergingDidFinished(.Completed)
            case AVAssetExportSessionStatus.Cancelled:
                self.delegate?.mergingDidFinished(.Cancelled)
                print("cancel")
            default:
                print("something happened in exporting")
                break
            }
        })
        
        return resultURL
        
    }
    
    
    
    
    
    func deleteDuplication(path: String) {
        let dm = NSFileManager.defaultManager()
        if dm.fileExistsAtPath(path) {
            print("file exist")
            do {
                try dm.removeItemAtPath(path)
                print("deleted")
            } catch _ { print("deletion got wrong")}
        }
        else {
            print("file not exist")
        }
    }
}