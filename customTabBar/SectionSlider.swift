//
//  SectionSlider.swift
//  SectionSliderV2
//
//  Created by Wenxiang Deng on 3/10/16.
//  Copyright © 2016 Wenxiang Deng. All rights reserved.
//

import UIKit

@objc protocol SectionSliderDelegate {
    optional func sectionSliderDidBeginTrack()
    optional func sectionSliderThumbDidChange()
    optional func sectionSliderDidEndTrack()
    
    optional func sectionSliderSectionDidChange(oldVal: Int, newVal: Int)
    optional func sliderSelectedStatusDidChanged(oldVal: Bool, newVal: Bool)
}


class SectionSlider: UIControl {
    
    struct Options {
        static let range = "MinAndMaxValue" //(double, double)
        
        static let sliderBackgroundColor = "BackgroundColor" // uicolor
        static let sectionBackgroundColor = "SectionBackgroundColor" // uicolor
        static let currentSectionColor = "CurrentSectionColor" // uicolor
        static let progressTrackColor = "ProgressTrackColor" // uicolor
        static let thumbColor = "ThumbColor" // uicolor
        
        static let layersInset = "LayersInset" // cgfloat
        static let thumbWidth = "ThumbWidth" // cgfloat
    }
    
    var currentSection: Int = 0 {
        didSet {
            currentSection = min(max(currentSection, 0), sectionFrames.count - 1)
            if oldValue != currentSection {
                updateCurrentSection(toSection: currentSection)
            }
        }
    }
    var startValueForCurrentSection: Double {
        get {
            return Double(sectionFrames[currentSection].minX) * valueToPositionRatio
        }
    }
    
    private var valueToPositionRatio: Double = 0.5
    var currentValue: Double { // is in model value
        get {
            return Double(currentPosition) * valueToPositionRatio
        }
        set {
            
            let val = CGFloat(newValue / valueToPositionRatio)
            currentPosition = val
            
            if !sectionSelectedByUser {
                currentSection = sectionForPosition(currentPosition)
            }
            
        }
    }
    internal(set) var currentPosition: CGFloat = 0.0 { /// position in frame
        didSet {
            updateThumbRelatedLayers(toLocation: currentPosition)
        }
    }
    
    
    internal(set) var thumbIsTracking: Bool = false
    var sectionSelectedByUser: Bool = false {
        didSet {
            self.delegate?.sliderSelectedStatusDidChanged?(oldValue, newVal: sectionSelectedByUser)
        }
    }
    private var thumbWidth: CGFloat = 2.0
    
    var delegate: SectionSliderDelegate?
    
    private var backgroundLayer = CAShapeLayer()
    private var currentSectionLayer = CAShapeLayer()
    private var progressTrackLayer = CAShapeLayer()
    private var thumbLayer = CAShapeLayer()
    
    private var sectionFrames = [CGRect]()   // this should not be used for finding values
    
    init(var withFrame frame: CGRect, sectionLengths: [Double] = [1.0], options: [String: AnyObject?] = [:]) {
        print(frame)
        thumbWidth = (options[Options.thumbWidth] as? CGFloat) ?? 5.0
        frame.origin.x += (thumbWidth/2)
        frame.size.width -= thumbWidth
        super.init(frame: frame) // TODO: modify from here
        
        //Calculate section frames
        valueToPositionRatio = sectionLengths.reduce(0, combine: +) / Double(self.bounds.width)
        let layersInset = (options[Options.layersInset] as? CGFloat) ?? 6
        var sectionStartX: CGFloat = bounds.origin.x
        let sectionStartY: CGFloat = bounds.origin.y + layersInset, sectionHeight = bounds.height - layersInset
        
        let widthExtension = (thumbWidth/2 + 1)
        for i in 0 ..< sectionLengths.count {
            let sectionWidth = CGFloat(sectionLengths[i] / valueToPositionRatio)
            var rect = CGRect(x: sectionStartX, y: sectionStartY, width: sectionWidth, height: sectionHeight)
            if i == 0 {
                rect.origin.x -= widthExtension
                rect.size.width += widthExtension
            }
            if i == (sectionLengths.count - 1) {
                rect.size.width += widthExtension
            }
            sectionFrames.append(rect)
            sectionStartX += sectionWidth
        }
        
        //setup layer colors
        //backgroundLayer.backgroundColor = (options[Options.sliderBackgroundColor] as? UIColor)?.CGColor
        backgroundLayer.fillColor = (options[Options.sectionBackgroundColor] as? UIColor)?.CGColor ?? UIColor.grayColor().CGColor
        currentSectionLayer.backgroundColor = (options[Options.currentSectionColor] as? UIColor)?.CGColor ?? UIColor(white: 0.9, alpha: 1.0).CGColor
        progressTrackLayer.backgroundColor = (options[Options.progressTrackColor] as? UIColor)?.CGColor ?? UIColor(white: 0.1, alpha: 0.2).CGColor
        thumbLayer.backgroundColor = (options[Options.thumbColor] as? UIColor)?.CGColor ?? UIColor.darkGrayColor().CGColor
        
        setupSlider()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupSlider() {
        let path = CGPathCreateMutable()
        for i in sectionFrames {
            let rect = i.insetBy(dx: 1, dy: 0) //TODO: see if need modify first and last sect
            CGPathAddRect(path, nil, rect)
        }
        backgroundLayer.path = path
        layer.addSublayer(backgroundLayer)
        
        currentSectionLayer.frame = sectionFrames[currentSection].insetBy(dx: 1, dy: 0)
        layer.addSublayer(currentSectionLayer)
        
        let sectRect = CGRect(x: sectionFrames[0].minX+1, y: sectionFrames[0].minY, width: 0, height: sectionFrames.first!.height)
        progressTrackLayer.frame = sectRect //UIBezierPath(rect: sectRect).CGPath
        layer.addSublayer(progressTrackLayer)
        
        let thumbRect = CGRect(x: bounds.minX, y: 0, width: thumbWidth, height: bounds.height)
        thumbLayer.frame = thumbRect
        thumbLayer.position.x = 0
        layer.addSublayer(thumbLayer)
        
    }
    
    func updateThumbRelatedLayers(toLocation locX: CGFloat) {
        //print("position: \(locX)  value: \(currentValue)")
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        thumbLayer.position.x = locX
        
        progressTrackLayer.frame.size.width = locX
        CATransaction.commit()
    }
    
    func updateCurrentSection(toSection sect: Int) {
        //print("new section: \(sect)")
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        currentSectionLayer.frame.origin.x = (sectionFrames[sect].origin.x+1)
        currentSectionLayer.frame.size.width = (sectionFrames[sect].width-2)
        CATransaction.commit()
    }
    
    //MARK: Touches
    func setCurrentSection(currentLocactionX locx: CGFloat) {
        let sect = sectionForPosition(locx)
        if sect != currentSection {
            self.delegate?.sectionSliderSectionDidChange?(currentSection, newVal: sect)
            currentSection = sect
        }
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let locx = touch.locationInView(self).x
        delegate?.sectionSliderDidBeginTrack?()
        
        // if dragging by thumb, player itself should stop, if by track, value change won't affect
        if abs(thumbLayer.frame.midX - locx) < 20 {
            sectionSelectedByUser = false
            thumbIsTracking = true
        } else {
            sectionSelectedByUser = true
            setCurrentSection(currentLocactionX: locx)
        }
        
        return true
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let locx = min(max(touch.locationInView(self).x, self.bounds.minX), self.bounds.maxX)
        
        if thumbIsTracking {
            currentPosition = locx
            delegate?.sectionSliderThumbDidChange?()
        }
        
        setCurrentSection(currentLocactionX: locx)
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        if sectionForPosition(currentPosition) == currentSection {
            sectionSelectedByUser = false
        }
        
        thumbIsTracking = false
        delegate?.sectionSliderDidEndTrack?()
    }
    
    override func cancelTrackingWithEvent(event: UIEvent?) {
        thumbIsTracking = false
        delegate?.sectionSliderDidEndTrack?()
    }
    
    // Utils
    func sectionForPosition (loc: CGFloat) -> Int {
        if loc < sectionFrames.first?.minX {return 0}
        for i in 0 ..< sectionFrames.count {
            let rect = sectionFrames[i]
            if CGRectContainsPoint(rect, CGPoint(x: loc, y: rect.midY)) {
                return i
            }
        }
        
        return sectionFrames.count > 0 ? sectionFrames.count - 1 : 0
    }
}








































