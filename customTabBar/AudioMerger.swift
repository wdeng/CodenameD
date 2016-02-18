//
//  AudioMerger.swift
//  PitchPerfect
//
//  Created by Wenxiang Deng on 12/9/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol AudioMergerDelegate {
    optional func mergingDidFinished(status: AVAssetExportSessionStatus)
    optional func mergingWillStart()
}

class AudioMerger: NSObject {
    
    var episode = EpisodeToPlay()
    
    private var audios: [RecordedAudio] = []
    private var imageSets: [AddedImageSet] = []
    var outputAudio: NSURL?
    var exportSession: AVAssetExportSession?
    
    
    var assetWriter: AVAssetWriter?
    var assetReader: AVAssetReader?
    var assetQueue: dispatch_queue_t?
    
    //TODO: This should be changed to dynamic in recording scene                       will need a placeholder image if no image
    private func getImageSetions(items: [AnyObject]) {
        //TODO: unexpectedly nil optional
        print(items)
        var currentSecionIndex = 0
        for i in 0 ..< items.count {
            if let item = items[i] as? AddedImageSet {
                if i == 0 {
                    imageSets.append(AddedImageSet())
                }
                else if audios.last?.itemIndex == imageSets.last!.itemIndex { /// this also solves the first item as audio
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
                debugPrint("something else added in recordedBundle")
            }
        }
        
        if (currentSecionIndex > 0) && (audios.last!.itemIndex != currentSecionIndex){
            imageSets[imageSets.count - 2].images += imageSets.last!.images
            imageSets.removeLast()
        }
        
    }
    
    override init() {
        super.init()
    }
    
    //TODO: change to convenience init
    init(withItems items: [AnyObject], toNewAudio: String = "combined.m4a") {
        super.init()
        
//        if imageSets.count == 0 {
//            if let d = (items.first as? RecordedAudio) {
//                episode.sectionDurations.append(d.duration)
//                episode.episodeURL = d.filePathURL
//                return
//            }
//        }
        
        getImageSetions(items)
        for i in imageSets {
            episode.sectionDurations.append(i.sectionDuration)
            episode.imageSets.append(i.images)
        }
        episode.thumb = ImageUtils.createCropImageFromSize((episode.imageSets).first?.first as? UIImage)
        
        var mergerAudios: [NSURL] = []
        for i in audios {
            mergerAudios.append(i.filePathURL)
        }
        
        
        
        episode.episodeURL = merge(mergerAudios, toOneAudioName: toNewAudio)
    }
    
        
    
    var delegate: AudioMergerDelegate?
    
    func stopMerge() {
        if let q = assetQueue {
            dispatch_async(q) {
                self.assetWriter?.cancelWriting()
                self.assetReader?.cancelReading()
            }
        }
    }
    
    func merge (audioURLs: [NSURL], toOneAudioName audio: String) -> NSURL? {
        //var error: NSError?
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
        
        //http://www.rockhoppertech.com/blog/ios-trimming-audio-files/  trimming
        
        
        let outputSettings:[String : AnyObject] = [
            AVFormatIDKey: NSNumber(unsignedInt:kAudioFormatMPEG4AAC),
            AVEncoderBitRateKey : 64000,
            AVNumberOfChannelsKey: 1,
            AVSampleRateKey : 32000.0]   ///TODO: need to change sample rate key
        
        let resultPath = dirPath + "/" + audio
        deleteDuplication(resultPath)
        let resultURL = NSURL.fileURLWithPath(resultPath)
        
        do{
            assetWriter = try AVAssetWriter(URL: resultURL, fileType: AVFileTypeAppleM4A)
            assetReader = try AVAssetReader(asset: composition)
        }catch{
            print("Couldn't start the reader writer")
        }
        
        if (assetWriter == nil) || (assetReader == nil) {return nil}
        
        assetReader!.timeRange = CMTimeRange(start: kCMTimeZero, end: kCMTimePositiveInfinity)
        let readerOutput = AVAssetReaderTrackOutput(track: compositionAudioTrack, outputSettings: nil)
        assetReader!.addOutput(readerOutput)
        
        let writerInput = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: outputSettings)
        writerInput.expectsMediaDataInRealTime = false
        if assetWriter!.canAddInput(writerInput) {
            assetWriter!.addInput(writerInput)
        }
        assetWriter!.shouldOptimizeForNetworkUse = true
        //let duration = composition.duration
        
        assetWriter!.startWriting()
        assetWriter!.startSessionAtSourceTime(kCMTimeZero)
        assetReader!.startReading()
        
        assetQueue = dispatch_queue_create("com.lbs.audiorecorder.assetreadingqueue", DISPATCH_QUEUE_SERIAL)
        self.delegate?.mergingWillStart?()
        writerInput.requestMediaDataWhenReadyOnQueue(assetQueue!){
            
            while writerInput.readyForMoreMediaData {
                let nextBuffer = readerOutput.copyNextSampleBuffer()
                if (self.assetReader!.status == .Reading) && (nextBuffer != nil) {
                    writerInput.appendSampleBuffer(nextBuffer!)
                } else {
                    writerInput.markAsFinished()
                    
                    switch self.assetReader!.status {
                    case .Failed:
                        print("Writer writing Failed")
                        self.assetWriter!.cancelWriting()
                        self.delegate?.mergingDidFinished?(.Failed)
                    case .Completed:
                        print("Writer writing Complete")
                        self.assetWriter!.endSessionAtSourceTime(composition.duration)
                        self.assetWriter!.finishWritingWithCompletionHandler{ _ in
                            dispatch_async(dispatch_get_main_queue()){
                                self.delegate?.mergingDidFinished?(.Completed)
                            }
                        }
                    case .Cancelled:
                        print("Writer writing cancelled")
                        self.delegate?.mergingDidFinished?(.Cancelled)
                    default:
                        print("Something happened in writing")
                        break
                        
                    }
                    
                    
                }
                
            }

        }

        
//        exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
//        if exportSession == nil {
//            return nil
//        }
//        
//        let resultPath = dirPath + "/" + audio
//        print(resultPath)
//        deleteDuplication(resultPath)
//        let resultURL = NSURL.fileURLWithPath(resultPath)
//        exportSession!.outputURL = resultURL
//        exportSession!.outputFileType = AVFileTypeAppleM4A
//        exportSession!.exportAsynchronouslyWithCompletionHandler({ () -> Void in
//        
//            switch self.exportSession!.status {
//            case AVAssetExportSessionStatus.Failed:
//                self.delegate?.mergingDidFinished(.Failed)
//                print("failed \(self.exportSession!.error)")
//            case AVAssetExportSessionStatus.Completed:
//                print("Complete")
//                self.delegate?.mergingDidFinished(.Completed)
//            case AVAssetExportSessionStatus.Cancelled:
//                self.delegate?.mergingDidFinished(.Cancelled)
//                print("cancel")
//            default:
//                print("something happened in exporting")
//                break
//            }
//        })
//        
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