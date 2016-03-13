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

class AudioMerger {
    
    var episode = EpisodeToPlay()
    private let trimLength: (start: Int64, end: Int64) //end is the actual (start + end), use for duration change
    private var audioTimescale = 1.0
    
    private var tmpAudios: [NSURL] = []
    var outputAudio: NSURL?
    var exportSession: AVAssetExportSession?
    
    
    var assetWriter: AVAssetWriter?
    var assetReader: AVAssetReader?
    var assetQueue: dispatch_queue_t?
    
    private enum ItemType {
        case Photo
        case Audio
        case Possible
    }
    
    //TODO: This should be changed to dynamic in recording scene                       will need a placeholder image if no image
    private func classifyAudioAndPhoto(fromModel items: [AnyObject]) {
        //var sectionIdx = 0
        var prevItemType = ItemType.Possible
        
        var imagesSets = [[AnyObject]()]
        var sectDurations = [0.0]
        
        for i in  0 ..< items.count {
            if let photo = items[i] as? UIImage {
                if prevItemType == .Audio {
                    imagesSets.append([AnyObject]())
                    sectDurations.append(0.0)
                }
                imagesSets[imagesSets.count-1].append(photo)
                prevItemType = .Photo
            } else if let audio = items[i] as? AudioModel {
                tmpAudios.append(audio.filePathURL)
                let trim = Double(trimLength.end) / audioTimescale
                sectDurations[imagesSets.count-1] += (audio.duration - trim) // each section will be correct length same as audio
                if prevItemType != .Possible {
                    prevItemType = .Audio
                }
            } else {
                debugPrint("something else added in recordedBundle Model")
            }
        }
        
        if (prevItemType == .Photo) && (imagesSets.count >= 2){
            imagesSets[imagesSets.count - 2] += imagesSets[imagesSets.count - 1]
            imagesSets.removeLast()
            sectDurations.removeLast()
        } else if sectDurations.last == 0.0{
            imagesSets.removeLast()
            sectDurations.removeLast()
        }
        
        episode.imageSets = imagesSets
        episode.sectionDurations = sectDurations
        episode.thumb = ImageUtils.createCropImageFromSize((episode.imageSets).first?.first as? UIImage)
    }
    
    
    init(withItems items: [AnyObject], toNewAudio: String = "combined.m4a", trim: (start: Double, end: Double) = (0.35, 0.05)) { //TODO: test how long to trim is the best, value/timescale=seconds, try this again afte optimize recorder
        
        //get the time scale
        for i in items {
            if let audio = i as? AudioModel {
                audioTimescale = Double(AVURLAsset(URL: audio.filePathURL).duration.timescale)
                break
            }
        }
        audioTimescale = audioTimescale > 0 ? audioTimescale : 1.0
        
        trimLength = (Int64(trim.start * audioTimescale), Int64((trim.start + trim.end) * audioTimescale))
        
        classifyAudioAndPhoto(fromModel: items)
        episode.episodeURL = merge(tmpAudios, toOneAudioName: toNewAudio)
        
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
            
            
            var startTime = avAsset.duration
            startTime.value = trimLength.start
            var dur = avAsset.duration
            dur.value -= trimLength.end
            let timeRangeInAsset = CMTimeRange(start: startTime, duration: dur)
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