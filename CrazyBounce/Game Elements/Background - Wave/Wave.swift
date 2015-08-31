//
//  Wave.swift
//  CrazyBounce
//
//  Created by Semper Idem on 14-12-7.
//  Copyright (c) 2014年 益行人-星夜暮晨. All rights reserved.
//

import UIKit
import SpriteKit

@objc protocol waterViewDelegate {
    optional func checkWaterRiseOver(riseOver: Bool)
    optional func checkWaterDropOver(dropOver: Bool)
}

// 动态波浪效果页面
class waterView: UIView, waterViewDelegate {
    
    var waterRise: Bool = false                                     // 控制水面是否上升, true 上升
    var waterDrop: Bool = false                                     // 控制水面是否下降，false下降
    var waterRiseOrDropSpeed: CGFloat = 8.5 / 768          //水面上升或下降的速度
    
    var currentWaterColor: UIColor = UIColor()              // 波浪颜色
    var currentLinePointY: CGFloat = 0                         // 水面高度
    var savedWaveHeight: CGFloat = 0
    
    var peakHeight: Float = 0                                      // 波浪高度
    var waveSpeed: Float = 0                                      // 波浪速度
    
    var peakHeightChange: Float = 1.5                          // 波浪高度，用其改变波浪高度
    var waveSpeedChange: Float = 0.1                          // 波浪速度，用其改变波浪速度
    var savedPeakHeightChange: Float = 1.5
    var savedSpeedHeightChange: Float = 0.1
    
    var waveUp: Bool = false                                        // 判定波浪处于上升还是下降
    var delegate: waterViewDelegate?                        //这个代理遵循自定义的协议waterViewDelegtae
    var waveTimer = NSTimer()
    
    init(frame: CGRect, color: UIColor, waveHeight: Float) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        
        peakHeight = 1 + peakHeightChange
        waveSpeed = 0
        waveUp = false
        waterRise = false
        waterDrop = false
        
        currentWaterColor = color
        currentLinePointY = frame.size.height - CGFloat(waveHeight)
        savedWaveHeight = currentLinePointY
        waterRiseOrDropSpeed = waterRiseOrDropSpeed * self.frame.height
        
        waveTimer = NSTimer.scheduledTimerWithTimeInterval(0.02, target: self, selector: "waveAnimation", userInfo: nil, repeats: true)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 波浪属性设置
    func changeWave(#waveHeight: Float, waveSpeed: Float){
        peakHeightChange = waveHeight
        waveSpeedChange = waveSpeed
    }
    
    func waterRiseUp(){
        waterRise = true
    }
    
    func waterDropDown(){
        waterDrop = true
        currentLinePointY = 0
        savedPeakHeightChange = peakHeightChange
        savedSpeedHeightChange = waveSpeedChange
    }
    
    // 波浪动画
    func waveAnimation(){
        if waveUp {
            peakHeight += 0.01
        }else{
            peakHeight -= 0.01
        }
        
        if peakHeight <= 1 {
            waveUp = true
        }
        
        if peakHeight >= peakHeightChange {
            waveUp = false
        }
        
        waveSpeed += waveSpeedChange
        
        self.setNeedsDisplay()
        
        if waterRise {
            currentLinePointY -= waterRiseOrDropSpeed
            peakHeightChange = 0.5
            waveSpeedChange = 0.3
            if currentLinePointY < 0{
                waterRise = false
                waveTimer.invalidate()
                waveTimer = NSTimer()
                delegate?.checkWaterRiseOver!(true)
            }
        }
        
        if waterDrop {
            currentLinePointY += waterRiseOrDropSpeed
            peakHeightChange = 0.5
            waveSpeedChange = 0.3
            if currentLinePointY >= savedWaveHeight {
                waterDrop = false
                peakHeightChange = savedPeakHeightChange
                waveSpeedChange = savedSpeedHeightChange
                delegate?.checkWaterDropOver!(true)
            }
        }
    }
    
    override func drawRect(rect: CGRect) {
        var context = UIGraphicsGetCurrentContext()
        var path = CGPathCreateMutable()
        
        // 绘制水波
        CGContextSetLineWidth(context, 1)
        CGContextSetFillColorWithColor(context, currentWaterColor.CGColor)
        var lineY: CGFloat = currentLinePointY
        CGPathMoveToPoint(path, nil, 0, lineY)
        
        for var lineX: CGFloat = 0; lineX <= self.frame.size.width; lineX++ {
            var p1: CGFloat = CGFloat(peakHeight)
            var p21: CGFloat = lineX / CGFloat(180) * CGFloat(M_PI)
            var p22: CGFloat = CGFloat(4 * waveSpeed) / CGFloat(M_PI)
            var p2: CGFloat = sin(p21 + p22)
            var p3: CGFloat = CGFloat(5)
            lineY = p1 * p2 * p3 + currentLinePointY
            CGPathAddLineToPoint(path, nil, lineX, lineY)
        }
        
        CGPathAddLineToPoint(path, nil, self.frame.size.width, rect.size.height)
        CGPathAddLineToPoint(path, nil, 0, rect.size.height)
        CGPathAddLineToPoint(path, nil, 0, currentLinePointY)
        
        CGContextAddPath(context, path)
        CGContextFillPath(context)
        CGContextDrawPath(context, kCGPathStroke)
    }
}
