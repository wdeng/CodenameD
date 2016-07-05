//
//  RecordingVC+Record.swift
//  customTabBar
//
//  Created by Wenxiang Deng on 3/3/16.
//  Copyright © 2016 Wenxiang Deng. All rights reserved.
//

import UIKit
import AVFoundation

extension RecordingViewController {
    //colorWithAlphaComponent
    
    // MARK: recording events
    @IBAction func recordStart(sender: UIButton) {
        
        UIView.animateWithDuration(0.2,
            delay: 0,
            options: [.BeginFromCurrentState, .CurveEaseInOut],
            animations: {
                self.recordBackgroundView.transform = CGAffineTransformMakeScale(0.8, 0.8)
            }, completion: nil)
        
        
        self.audioPlayerShouldStop()
        
        audioRecorder.record()
        
        // timer to sample sound level
        sampledAudioLevel.removeAll()
        updateTime?.invalidate()
        updateTime = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(RecordingViewController.updateTimer(_:)), userInfo: audioRecorder, repeats: true)
        
    }
    
    // sample audio level
    func updateTimer(timer: NSTimer) {
        
        if (timer.userInfo is AVAudioRecorder) {
            // currentTime
            let time = audioRecorder.currentTime
            if time < 1.3 {
                navigationItem.title = "Tap & Hold to Record"
            } else if time > 60.4 {
                //navigationItem.title = "Release to Post"
                stopRecorder()
            } else {
                var displayTime = AppUtils.durationToClockTime(time)
                if time > 50 {
                    displayTime += "/1:00"
                }
                if navigationItem.title != displayTime {
                    navigationItem.title = displayTime
                }
            }
            
            // meter
            audioRecorder.updateMeters()
            let meter = Double(meterTable.ValueAt(audioRecorder.averagePowerForChannel(0)))
            sampledAudioLevel.append(meter)
            if recordMeterView.isDescendantOfView(view) {
                let scale = CGFloat(meter) * 2.0 + 1
                recordMeterView.transform = CGAffineTransformMakeScale(scale, scale)
            } else {
                showRecordMeterGradientView()
                //view.insertSubview(recordMeterView, belowSubview: recordBackgroundView)
            }
        }
    }
    
    @IBAction func recordEndSucceed(sender: AnyObject) {
        UIView.animateWithDuration(0.1) {
            self.recordBackgroundView.transform = CGAffineTransformIdentity
        }
        stopRecorder()
    }
    
    @IBAction func recordEndFail(sender: UIButton) {
        UIView.animateWithDuration(0.1) {
            self.recordBackgroundView.transform = CGAffineTransformIdentity
        }
        //recordingShouldFail = true   TODO: add back when title can notify cancel
        stopRecorder()
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        
        // remove first a few level when recording is starting
        if sampledAudioLevel.count > 5 {
            sampledAudioLevel[0 ... 2] = []
        }
        
        updateTime?.invalidate()
        
        if (flag && !recordingShouldFail){
            let dur = CMTimeGetSeconds(AVURLAsset(URL: recorder.url).duration)
            if dur > 1.1 {
                let recordedAudio = AudioModel(withURL: recorder.url)
                recordedAudio.duration = dur
                recordedAudio.samples = sampledAudioLevel
                
                totalRecordedLength += dur
                recordingNameIndex+=1
                appendItemInCollectionView(withItem: recordedAudio)
                
                prepareRecorder()
            }
        }
        else{
            debugPrint("not succussful")
            recordingShouldFail = false
        }
        
        if totalRecordedLength > 540 {
            navigationItem.title = AppUtils.durationToClockTime(totalRecordedLength) + "/10:00"
        } else {
            navigationItem.title = "Record"
        }
    }
    
    func showRecordMeterGradientView() {
        recordMeterView.center = recordBackgroundView.center
        view.insertSubview(recordMeterView, belowSubview: recordBackgroundView)
        recordMeterView.transform = CGAffineTransformMakeScale(0.6, 0.6)
        UIView.animateWithDuration(0.15) {
            self.recordMeterView.transform = CGAffineTransformIdentity
        }
    }
    
    func removeRecordMeterGradientView() {
        UIView.animateWithDuration(0.15, animations: {
            self.recordMeterView.transform = CGAffineTransformMakeScale(0.6, 0.6)
            }) { _ in
            self.recordMeterView.removeFromSuperview()
        }
    }
    
    func hideRecordButton() {
        //recordBackgroundView.transform = CGAffineTransformIdentity
        UIView.animateWithDuration(0.15, animations: {
            self.recordBackgroundView.transform = CGAffineTransformMakeScale(0.01, 0.01)
            }) { _ in
                self.recordBackgroundView.hidden = true
                self.micButton.style = .Plain
        }
    }
    
    func showRecordButton() {
        //recordBackgroundView.transform = CGAffineTransformMakeScale(0.0, 0.0)
        recordBackgroundView.hidden = false
        UIView.animateWithDuration(0.15) {
            self.recordBackgroundView.transform = CGAffineTransformIdentity
            self.micButton.style = .Done
        }
    }
    
    @IBAction func showHideMicButton(sender: UIBarButtonItem) {
        if sender.style == .Done {
            hideRecordButton()
        } else if sender.style == .Plain {
            showRecordButton()
        }
    }
    
    func prepareRecorder() {  //  may be should be static,
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first! as String
        let recordingName = "myaudio\(recordingNameIndex).wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioRecorder = AVAudioRecorder(URL: filePath!, settings: RecordSettings.recordAudioSettings)
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled = true
            audioRecorder.prepareToRecord()
        } catch {
            debugPrint("recording failed")
            
            let alert = UIAlertController(title: "Error", message: "Couldn't initialize the recorder", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .Default) { (action) -> Void in
                self.prepareRecorder()
                })
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
                })
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func stopRecorder() {
        updateTime?.invalidate()
        audioRecorder?.stop()
        removeRecordMeterGradientView()
        
    }
}


class RecordingMeterView: UIView {
    var circleCenter = CGPointZero
    var radius = CGFloat()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.frame.size.width *= 1.2
        self.frame.size.height *= 1.2
        self.center = CGPoint(x: frame.midX, y: frame.midY)
        
        circleCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        radius = self.frame.height / 2
        self.userInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect)
    {
        let context = UIGraphicsGetCurrentContext()
        
        let locations: [CGFloat] = [0.0, 0.7, 1.0]
        let tintColor = AppSettings.AppTintColor
        let colors = [tintColor.colorWithAlphaComponent(0.9).CGColor,
            tintColor.colorWithAlphaComponent(0.3).CGColor,   // 0.5 in lime
            tintColor.colorWithAlphaComponent(0.01).CGColor]
        let colorspace = CGColorSpaceCreateDeviceRGB()
        
        let gradient = CGGradientCreateWithColors(colorspace,
            colors, locations)
        
        let startPoint = circleCenter
        let endPoint  = circleCenter
        
        let startRadius: CGFloat = radius * 0.4
        let endRadius: CGFloat = radius
        
        CGContextDrawRadialGradient(context, gradient, startPoint,
            startRadius, endPoint, endRadius, .DrawsBeforeStartLocation)
    }
}

class RadialGradientLayer: CALayer {
    
    override init(){
        
        super.init()
        
        needsDisplayOnBoundsChange = true
    }
    
    init(center:CGPoint,radius:CGFloat,colors:[CGColor]){
        
        self.center = center
        self.radius = radius
        self.colors = colors
        
        super.init()
        
    }
    
    required init(coder aDecoder: NSCoder) {
        
        super.init()
        
    }
    
    var center:CGPoint = CGPointMake(50,50)
    var radius:CGFloat = 20
    var colors:[CGColor] = [UIColor(red: 251/255, green: 237/255, blue: 33/255, alpha: 1.0).CGColor , UIColor(red: 251/255, green: 179/255, blue: 108/255, alpha: 1.0).CGColor]
    
    override func drawInContext(ctx: CGContext) {
        
        CGContextSaveGState(ctx)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let locations:[CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradientCreateWithColors(colorSpace, colors, locations)
        
        //let startPoint = CGPointMake(0, self.bounds.height)
        //let endPoint = CGPointMake(self.bounds.width, self.bounds.height)
        
        CGContextDrawRadialGradient(ctx, gradient, center, 0.0, center, radius, CGGradientDrawingOptions(rawValue: 0))
        
    }
    
}