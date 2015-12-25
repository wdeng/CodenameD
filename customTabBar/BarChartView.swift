//
//  BarChartView.swift
//  NumbersToBarchart
//
//  Created by Wenxiang Deng on 12/5/15.
//  Copyright © 2015 Wenxiang Deng. All rights reserved.
//

import UIKit

class BarChartView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    // TODO: sound wave doesn't seems right
    
    //init setttings
    struct Settings {
        static let Round            = "barchart_round_corner"
        static let Color            = "barchart_color"
        static let BarWidth         = "barchart_bar_width"
        static let SeparaterWidth   = "barchart_bar_separate_width"
        static let BColor           = "barchart_background_color"
        static let Insets           = "barchart_insets"
    }
    
    let barChartLayer = CAShapeLayer()
    var roundCorner = RecordSettings.recordedAudioCellCornerRadius
    var nums: [Double]!
    var soundLevelEdgeInsetRight: CGFloat = 30.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configs()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configs()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        barChartLayer.frame = bounds //.insetBy(dx: 2.0, dy: 2.0)
        let inset = min(RecordSettings.recordedAudioCellCornerRadius, 2.0)
        drawBarChart(withNumbers: nums, barWidths: (2, 1), andInset: UIEdgeInsetsMake(inset, RecordSettings.recordedAudioCellCornerRadius, inset, soundLevelEdgeInsetRight))
        
        
    }
    
    
    func configs() {
        layer.cornerRadius = roundCorner  // Round
        backgroundColor = UIColor.grayColor() // BColor
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGrayColor().CGColor
        clipsToBounds = true
        
        //barChartLayer.frame = bounds
        barChartLayer.lineWidth = 0
        barChartLayer.fillColor = UIColor.whiteColor().CGColor  // Color
        barChartLayer.strokeColor = UIColor.whiteColor().CGColor // Color
        //barChartLayer.backgroundColor
        layer.addSublayer(barChartLayer)
    }
    
    func drawBarChart(withNumbers nums: [Double], barWidths bw: (Double, Double), andInset inset: UIEdgeInsets) {
        
        barChartLayer.frame = UIEdgeInsetsInsetRect(barChartLayer.frame, inset)
        
        let b = barChartLayer.bounds
        let w = b.size.width
        let h = Double(b.size.height)
        let midy = Double(b.midY)
        
        //Calculate bins for each bar level
        // bw = barwidth + separaterwidth
        let binNum = Int(floor(Double(w) / (bw.0 + bw.1)))
        var bins = [Double]()
        let numsPerBin = nums.count / binNum
        //let residue = nums.count % binNum()
        for i in 0 ..< binNum {
            
            let numsInBin = Array(nums[i*numsPerBin ..< (i+1) * numsPerBin])
            bins.append(average(numsInBin))
        }
        let minOfBins = bins.minElement(), maxOfBins = bins.maxElement()
        
        // normalization      not needed when there is only tiny sounds
        if bins.maxElement() > AppSettings.minSoundLevel {
            for i in 0 ..< bins.count {
                let normalized = (bins[i] - minOfBins!) / (maxOfBins! - minOfBins! + AppSettings.reallySmallNumber)
                bins[i] = normalized * (h - 1) + 1
                // TODO: if blured edge in iphone
                //bins[i] = floor((normalized * (h - 1) + 1)*2)/2
            }
        }
        else {
            for i in 0 ..< bins.count {
                bins[i] = bins[i] * (h - 1) + 1
                // TODO: if blured edge in iphone
            }
        }
        
        //Draw the Bar chart
        let path = CGPathCreateMutable()
        for i in 0 ..< bins.count {
            let rect = CGRect(x: Double(i) * (bw.0+bw.1), y: midy - bins[i] / 2, width: bw.0, height: bins[i])
            CGPathAddRect(path, nil, rect)
            //UIBezierPath(rect: rect).CGPath
            //barChartLayer.fillColor =
        }
        barChartLayer.path = path
        //let rect = CGRect(x: 10, y: 5, width: 30, height: 20)
        //barChartLayer.path = UIBezierPath(rect: rect).CGPath
    }
    
    func average(nums: [Double]) -> Double {
        var result = 0.0
        for i in nums {
            result += i
        }
        
        return result / Double(nums.count)
    }
    
    //TODO: Use drawRect to change background layer????
    
    
    //TODO: recording progress and playing back progress can be added an extra layer
    
}









































