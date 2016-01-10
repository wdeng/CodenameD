//
//  SectionSlider.swift
//  CustomSliderExample
//
//  Created by William Archimede on 04/09/2014.
//  Copyright (c) 2014 HoodBrains. All rights reserved.
//

import UIKit
import QuartzCore

private let sectGap = CGFloat(1.0)
private let thumbConvexLevel = CGSize(width: 5, height: 10)

class SectSliderBackgroundTrackLayer: CALayer {
    weak var sectSlider: SectionSlider?
    
    override func drawInContext(ctx: CGContext) {
        if let slider = sectSlider {
            //Background fill
            //TODO: Maybe background bars should be start from intergers coord for better visual
            CGContextSetFillColorWithColor(ctx, slider.trackTintColor.CGColor)
            CGContextFillRect(ctx, bounds)
            
            //Sections fill
            // length of a section is: startOfSectionsInFrame[i] - startOfSectionsInFrame[i-1] - sectGap
            for i in 0 ..< slider.startOfSectionsInFrame.count {
                let startOSect = (i > 0) ? slider.startOfSectionsInFrame[i] + sectGap : slider.startOfSectionsInFrame[i]
                let wid = i < (slider.startOfSectionsInFrame.count - 1) ? (slider.startOfSectionsInFrame[i+1] - startOSect) : (bounds.maxX - startOSect)
                let rect = CGRect(x: startOSect, y: 0, width: wid, height: bounds.height)
                CGContextSetFillColorWithColor(ctx, slider.sectionTintColor.CGColor)
                CGContextFillRect(ctx, rect)
            }
        }
    }
}

class SectSliderProgressTrackLayer: CALayer {
    //TODO: maybe should change to to CALayers
    var sectionSelected: Int = 0 {
        didSet {
            prevSection = oldValue
            setNeedsDisplay()
        }
    }
    
    private var prevSection = -1
    private var startOSect: CGFloat!
    private var widthOSect: CGFloat!
    weak internal var sectSlider: SectionSlider!
    
    override internal func drawInContext(ctx: CGContext) {
        if let slider = sectSlider {
            // if prev!= -1, then need cleanning
            if prevSection != -1 {
                startOSect = slider.startOfSectionsInFrame[prevSection] + (prevSection > 0 ? sectGap : 0.0)
                widthOSect = prevSection < (slider.startOfSectionsInFrame.count - 1) ? (slider.startOfSectionsInFrame[prevSection+1] - startOSect) : (bounds.maxX - startOSect)
                let rect = CGRect(x: startOSect, y: 0, width: widthOSect, height: bounds.height)
                CGContextSetFillColorWithColor(ctx, slider.sectionTintColor.CGColor)
                CGContextFillRect(ctx, rect)
                prevSection = -1
            }
            
            // update to new
            startOSect = slider.startOfSectionsInFrame[sectionSelected] + (sectionSelected > 0 ? sectGap : 0.0)
            widthOSect = sectionSelected < (slider.startOfSectionsInFrame.count - 1) ? (slider.startOfSectionsInFrame[sectionSelected+1] - startOSect) : (bounds.maxX - startOSect)
            //print("the \(sectionSelected) is the selected section, and start of section is \(startOSect)")
            CGContextSetFillColorWithColor(ctx, slider.sectionHighlightColor.CGColor)
            CGContextFillRect(ctx, CGRect(x: startOSect, y: 0, width: widthOSect, height: bounds.height))
            
            // Fill the progress range
            let thumbPosition = slider.positionForValue(slider.value)
            CGContextSetFillColorWithColor(ctx, slider.progressBarColor.CGColor)
            let rect = CGRect(x: 0.0, y: 0.0, width: thumbPosition, height: bounds.height)
            CGContextFillRect(ctx, rect)
            
            
            
            
            
            
        }
    }
}

class SectSliderThumbLayer: CALayer {
    var highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    weak var sectSlider: SectionSlider?
    
    override func drawInContext(ctx: CGContext) {
        if let slider = sectSlider {
            let thumbFrame = bounds//.insetBy(dx: 2.0, dy: 2.0)
            let cornerRadius = thumbFrame.height * 0.0
            let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)
            
            // Fill
            CGContextSetFillColorWithColor(ctx, slider.thumbTintColor.CGColor)
            CGContextAddPath(ctx, thumbPath.CGPath)
            CGContextFillPath(ctx)
            
            // Outline
            let strokeColor = UIColor.lightGrayColor()
            CGContextSetStrokeColorWithColor(ctx, strokeColor.CGColor)
            CGContextSetLineWidth(ctx, 0)
            CGContextAddPath(ctx, thumbPath.CGPath)
            CGContextStrokePath(ctx)
            
            if highlighted {
                CGContextSetFillColorWithColor(ctx, UIColor(white: 0.0, alpha: 0.1).CGColor)
                CGContextAddPath(ctx, thumbPath.CGPath)
                CGContextFillPath(ctx)
            }
        }
    }
}


@objc protocol SectionSliderDelegate {
    optional func sectionSliderThumbDidBeginTrack()
    optional func sectionSliderThumbDidChange()
    optional func sectionSliderThumbDidEndTrack()
    
    optional func sectionSliderSectionDidChange(oldVal: Int, newVal: Int)
    optional func sliderSelectedStatusDidChanged(oldVal: Bool, newVal: Bool)
    
}

class SectionSlider: UIControl {
    //TODO: some of the didset funcs are not neccesary
    //TODO: should init using dictionary not set one by one [string: anyobject]
    var delegate: SectionSliderDelegate?
    var sectionSelectedByUser: Bool = false {
        didSet {
            self.delegate?.sliderSelectedStatusDidChanged?(oldValue, newVal: sectionSelectedByUser)
        }
    }
    var currentSection: Int = 0 {
        didSet {
            if oldValue != currentSection {
                progressTrackLayer.sectionSelected = currentSection // Redraw the selected Section
                
                self.delegate?.sectionSliderSectionDidChange?(oldValue, newVal: currentSection)
            }
        }
    }
    
    var minimumValue: Double = 0.0 {
        didSet {
            if maximumValue < minimumValue {
                maximumValue = minimumValue + AppSettings.reallySmallNumber
            }
            updateLayerFrames()
        }
    }
    
    var maximumValue: Double = 1.0 {
        didSet {
            if minimumValue > maximumValue {
                minimumValue = maximumValue - AppSettings.reallySmallNumber
            }
            updateLayerFrames()
        }
    }
    
    var sectionsLengths: [Double] = [] {
        didSet {
            backgroundTrackLayer.setNeedsDisplay()
        }
    }
    
    private(set) var startOfSectionsInFrame: [CGFloat]!
    
    private var touchableFrame: CGRect!
    
    var value: Double = 0.0 {
        // value changes in two situations: one is dragging, the other is sound playing
        didSet {
            if value > maximumValue {
                value = maximumValue
            }
            else if value < minimumValue {
                value = minimumValue
            }
            
            let thumbCenter = positionForValue(value)
            if !sectionSelectedByUser {
                currentSection = sectionForLocation(thumbCenter)
            }
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            progressTrackLayer.setNeedsDisplay()
            thumbLayer.frame = CGRect(x: thumbCenter - thumbSize.width/2.0, y: 0.0, width: thumbSize.width, height: thumbSize.height)
            thumbLayer.setNeedsDisplay()
            CATransaction.commit()
            
        }
    }
    
    var valueShouldUpdate = false
    
    var trackTintColor: UIColor = UIColor(white: 0.3, alpha: 1.0) {
        didSet {
            progressTrackLayer.setNeedsDisplay()
        }
    }
    
    var sectionTintColor: UIColor = UIColor(white: 0.5, alpha: 1.0) {
        didSet {
            backgroundTrackLayer.setNeedsDisplay()
        }
    }
    
    var sectionHighlightColor: UIColor = UIColor.whiteColor() { //UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 0.5) {
        didSet {
            progressTrackLayer.setNeedsDisplay()
        }
    }
    
    var progressBarColor: UIColor = UIColor(white: 0.1, alpha: 0.2) {
        didSet {
            progressTrackLayer.setNeedsDisplay()
        }
    }
    
    var thumbTintColor: UIColor = UIColor.darkGrayColor() {
        didSet {
            thumbLayer.setNeedsDisplay()
        }
    }
    
    private var previousLocation = CGPoint()
    private let backgroundTrackLayer = SectSliderBackgroundTrackLayer()
    private let progressTrackLayer = SectSliderProgressTrackLayer()
    private let thumbLayer = SectSliderThumbLayer()
    
    private var thumbSize: CGSize {
        return CGSize(width: thumbConvexLevel.width, height: bounds.height)
    }
    
    override var frame: CGRect {
        didSet {
            startOfSectionsInFrame = [backgroundTrackLayer.frame.minX]
            updateLayerFrames()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundTrackLayer.sectSlider = self
        backgroundTrackLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(backgroundTrackLayer)
        
        progressTrackLayer.sectSlider = self
        progressTrackLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(progressTrackLayer)
        
        thumbLayer.sectSlider = self
        thumbLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(thumbLayer)
        
        startOfSectionsInFrame = [backgroundTrackLayer.frame.minX]
        updateLayerFrames()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        progressTrackLayer.frame = CGRect(x: bounds.minX, y: bounds.minY + thumbConvexLevel.height, width: bounds.width, height: bounds.height - thumbConvexLevel.height)
        progressTrackLayer.setNeedsDisplay()
        
        backgroundTrackLayer.frame = progressTrackLayer.frame
        resetSectionStarters()
        backgroundTrackLayer.setNeedsDisplay()
        
        let thumbCenter = positionForValue(value)
        thumbLayer.frame = CGRect(x: thumbCenter - thumbSize.width/2.0, y: 0.0, width: thumbSize.width, height: thumbSize.height)
        thumbLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    func positionForValue(v: Double) -> CGFloat {
        let p = (v - minimumValue) * Double(backgroundTrackLayer.frame.width - thumbSize.width) / (maximumValue - minimumValue) + Double(thumbSize.width / 2.0) + Double(backgroundTrackLayer.frame.minX)
        return CGFloat(p)
    }
    
    func valueForPosition(p: CGFloat) -> Double {
        //v = ((p - backgroundTrackLayer.frame.minX - thumbSize.width / 2) * CGFloat(maximumValue - minimumValue)) / (backgroundTrackLayer.frame.width - thumbSize.width) + CGFloat(minimumValue)
        
        let v = (p - backgroundTrackLayer.frame.minX - thumbSize.width / 2) / (backgroundTrackLayer.frame.width - thumbSize.width)
        return (Double(v) * (maximumValue - minimumValue) + minimumValue)
    }
    
    
    private func resetSectionStarters()
    {
        startOfSectionsInFrame = [backgroundTrackLayer.frame.minX]
        
        if self.sectionsLengths.count - 1 > 0 {
            for i in 0 ..< self.sectionsLengths.count - 1 {
                startOfSectionsInFrame.append(positionForValue(sectionsLengths[i]) + startOfSectionsInFrame[i])
            }
        }
    }
    
    func sectionForLocation (loc: CGFloat) -> Int {
        let x = loc //.x
        if x < startOfSectionsInFrame[0] {
            return 0
        }
        
        for i in 0 ..< startOfSectionsInFrame.count - 1 {
            if (x >= startOfSectionsInFrame[i] && x < startOfSectionsInFrame[i+1]) {
                return i
            }
        }
        
        return startOfSectionsInFrame.count - 1
    }

    // MARK: - Touches
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        previousLocation = touch.locationInView(self)
        
        // Hit test the thumb layers
        
        if abs(thumbLayer.frame.midX - previousLocation.x) < 20 {
        //if thumbLayer.frame.contains(previousLocation) {
            thumbLayer.highlighted = true
            delegate?.sectionSliderThumbDidBeginTrack?()
            return true
        }
        else if backgroundTrackLayer.frame.contains(previousLocation){
            sectionSelectedByUser = true
            currentSection = sectionForLocation(previousLocation.x)
            return true
        }
        
        return false
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        var location = touch.locationInView(self)
        // Determine by how much the user has dragged
        
        //TODO: need to clean up the code very redundant
        //TODO: to implement apple's fine tune, need conditionally change location depending on location.y
        let deltaLocation = Double(location.x - previousLocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(backgroundTrackLayer.frame.width - thumbSize.width)
        location.x = min(max(location.x, backgroundTrackLayer.frame.minX), backgroundTrackLayer.frame.maxX)
        
        // Update the values
        
        if thumbLayer.highlighted {
            sectionSelectedByUser = false
            value += deltaValue
            valueShouldUpdate = true
            delegate?.sectionSliderThumbDidChange?()
            //sendActionsForControlEvents(.ValueChanged)
        }
        currentSection = sectionForLocation(location.x)
        
        previousLocation = location
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        let s = sectionForLocation(positionForValue(value))
        if sectionSelectedByUser && (currentSection == s) {
            sectionSelectedByUser = false
        }
        //sendActionsForControlEvents(.ValueChanged)
        if thumbLayer.highlighted {
            delegate?.sectionSliderThumbDidEndTrack?()
            thumbLayer.highlighted = false
        }
    }
}
