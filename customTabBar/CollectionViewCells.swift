//
//  CollectionViewCells.swift
//  DragNDropCollectionView
//
//  Created by Wenxiang Deng on 2/20/16.
//  Copyright © 2016 Wenxiang Deng. All rights reserved.
//

import UIKit

class UIPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    override var bounds: CGRect {
        didSet{
            contentView.frame = bounds
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .ScaleAspectFill
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        //selected = true
    }
    
    
    
    override var selected: Bool {
        didSet {
            if selected {
                layer.borderColor = UIColor.darkGrayColor().CGColor
                layer.borderWidth = 3
                imageView.alpha = 0.5
                
                //contentView.layer.opacity = 0.7
                // could use custom layout for the selected
                //set image view alpha to be 0.3
                //backgroundColor = UIColor.blueColor()
            } else {
                layer.borderWidth = 0
                imageView.alpha = 1.0
                
                //set image view alpha to be 0
                //backgroundColor = UIColor.brownColor()
            }
        }
    }
}



class UIAudioCell: UICollectionViewCell {
    
    @IBOutlet weak var playSound: UILabel!
    var audioProgressLayer = CAShapeLayer()
    var barChartLayer = CAShapeLayer()
    var barChartNums: [Double]!
    
    override var bounds: CGRect {
        didSet{
            contentView.frame = bounds
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.playSound.layer.cornerRadius = RecordSettings.recordedAudioCellCornerRadius
        layer.cornerRadius = RecordSettings.recordedAudioCellCornerRadius
        self.clipsToBounds = true
        
        audioProgressLayer.fillColor = UIColor.grayColor().CGColor
        barChartLayer.fillColor = UIColor.whiteColor().CGColor
        
        self.layer.addSublayer(audioProgressLayer)
        playSound.layer.addSublayer(barChartLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let maxSize = CGSize(width: CGFloat.max, height: bounds.size.height)
        let rightInset = playSound.sizeThatFits(maxSize).width + 5
        
        barChartLayer.frame = bounds
        let inset = UIEdgeInsets(top: 2, left: layer.cornerRadius - 2, bottom: 2, right: rightInset)
        drawBarChart(withNumbers: barChartNums, barWidths: (2, 1), andInset: inset)
    }
    
    class func calculateButtonWidth(audioDuration duration: Double, boundsWidth: CGFloat) -> CGFloat {
        let durationInterval = RecordSettings.recordedDurationLimit.1 - RecordSettings.recordedDurationLimit.0
        let ratio = min(1.0, CGFloat(duration / durationInterval))
        let maxButtonWidth = boundsWidth - RecordSettings.minCellBlankWidth
        let minButtonWidth = RecordSettings.minAudioButtonWidth
        
        return ratio * (maxButtonWidth - minButtonWidth) + minButtonWidth
    }
    
    override var selected: Bool {
        didSet {
            if selected {
                layer.borderColor = UIColor.darkGrayColor().CGColor
                layer.borderWidth = 3
                playSound.alpha = 0.5
                //backgroundColor = UIColor.blueColor()
            } else {
                layer.borderWidth = 0
                playSound.alpha = 1.0
                //backgroundColor = UIColor.greenColor()
            }
        }
    }
    
    //Audio Meter Bar Layer
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
        }
        barChartLayer.path = path
        //let rect = CGRect(x: 10, y: 5, width: 30, height: 20)
        //barChartLayer.path = UIBezierPath(rect: rect).CGPath
        //barChartLayer.fillColor =
    }
    
    func average(nums: [Double]) -> Double {
        var result = 0.0
        for i in nums {
            result += i
        }
        
        return result / Double(nums.count)
    }
    
    //TODO: check if this is better
    //    override func drawRect(rect: CGRect)
    //    {
    //        let context = UIGraphicsGetCurrentContext()
    //        CGContextSetLineWidth(context, 20.0)
    //        CGContextSetStrokeColorWithColor(context,
    //            UIColor.blueColor().CGColor)
    //        let dashArray:[CGFloat] = [2,6,4,2]
    //        CGContextSetLineDash(context, 3, dashArray, 4)
    //        CGContextMoveToPoint(context, 10, 200)
    //        CGContextAddQuadCurveToPoint(context, 150, 10, 300, 200)
    //        CGContextStrokePath(context)
    //    }
}




























