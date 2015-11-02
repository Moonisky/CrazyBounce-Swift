//
//  WaterWaveView.swift
//  CrazyBounce
//
//  Created by Semper_Idem on 15/11/2.
//  Copyright © 2015年 益行人-星夜暮晨. All rights reserved.
//

import AppKit

@objc protocol WaterWaveDelegate {
    optional func checkWaterRiseOver()
    optional func checkWaterDropOver()
}

/// 水面波浪动画视图
class WaterWaveView: NSView {
    
    // MARK: - 属性
    
    /// 填充度，默认为0.5
    private var progress: CGFloat = 1
    /// 填充颜色
    private var fillColor = NSColor(red: 86/255, green: 202/255, blue: 139/255, alpha: 1).CGColor
    /// 最小振幅，默认是0.5
    private var minAmplitude: CGFloat = 0.5
    /// 最大振幅，默认是1.0
    private var maxAmplitude: CGFloat = 1
    /// 波浪速度（向左←）
    private var waveSpeed: CGFloat = 1
    /// 波峰高度
    private var waveHeight: CGFloat = 20
    /// 波长（一个波浪的宽度）
    private var waveWidth: CGFloat = 180
    /// 波浪涨潮/落潮的速度
    private var waveRiseSpeed: CGFloat = 0.2
    /// 当前填充度
    private var currentProgress: CGFloat = 1
    /// 波浪的X 坐标点
    private var waveXNum = 0
    /// 是否在播放动画
    var isAnimate: Bool = false
    /// Layer 图层
    var circleLayer: CAShapeLayer!
    /// 这个代理遵循自定义的协议waterViewDelegate
    var delegate: WaterWaveDelegate?
    
    // MARK: 初始化
    
    /// 初始化波浪动画视图
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        // 设置背景
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.clearColor().CGColor
        
        // 添加绘制图层
        self.circleLayer = CAShapeLayer()
        self.circleLayer.path = pathWith(-1).CGPath
        self.circleLayer.lineWidth = 2
        self.layer?.addSublayer(circleLayer)
        self.setFillColor(NSColor.clearColor())
    }
    
    /// 初始化
    convenience init(frame: CGRect, color: NSColor) {
        self.init(frame: frame)
        self.setFillColor(color)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 相关控制函数
    
    /// 设置波浪的高度和宽度，height 是波浪的高度（即波峰的高度，默认20），width 是波浪的宽度（即波长，默认180）
    func setWaveHeight(height: CGFloat = 20, andWidth width: CGFloat = 180) {
        self.waveHeight = height
        self.waveWidth = width
    }
    
    /// 设置波浪的波浪速度，默认是1
    func setWaveSpeed(speed: CGFloat = 1) {
        self.waveSpeed = speed
    }
    
    /// 设置波浪上升/下降的速度，默认是0.2
    func setWaveRiseSpeed(speed: CGFloat = 0.2) {
        self.waveRiseSpeed = speed
    }
    
    /// 设置填充颜色
    func setFillColor(fillColor: NSColor) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 2
            self.fillColor = fillColor.CGColor
            self.circleLayer.fillColor = fillColor.CGColor
            self.circleLayer.strokeColor = fillColor.CGColor
        }, completionHandler: nil)
    }
    
    /// 设置当前进度，取值范围0~1
    func setCurrentProgress(progress: CGFloat) {
        if progress < 0.5 {
            self.progress = 1 - progress
        } else {
            self.progress = 1 - progress
        }
    }
    
    /// 启动波浪上升
    func riseUp() {
        self.setCurrentProgress(1.1)
    }
    
    func dropDown() {
        self.setCurrentProgress(0.19)
    }
    
    /// 启动动画，停止使用要调用 stopAnimation，以释放资源
    func startAnimation() {
        isAnimate = true
        waveAnimate()
    }
    
    /// 关闭动画
    func stopAnimation() {
        isAnimate = false
    }
    
    // MARK: Private Helper Method
    
    /// 波浪动画
    private func waveAnimate() {
        let circleAnimation = CABasicAnimation(keyPath: "path")
        circleAnimation.removedOnCompletion = false
        circleAnimation.duration = 0.5
        circleAnimation.timingFunction = CAMediaTimingFunction(name: "linear")
        
        let number = 4 / Int(waveSpeed)
        if waveXNum % number == 0 {
            circleLayer.path = pathWith(-1).CGPath
        }
        
        if currentProgress > progress {
            currentProgress -= waveRiseSpeed
            if currentProgress < progress {
                currentProgress = progress
            }
        }
        if currentProgress < progress {
            currentProgress += waveRiseSpeed
            if currentProgress > progress {
                currentProgress = progress
            }
        }
        if currentProgress > 0.8 {
            delegate?.checkWaterDropOver!()
        } else if currentProgress < 0 {
            delegate?.checkWaterRiseOver!()
        }
        
        circleAnimation.fromValue = circleLayer.path
        circleAnimation.toValue = pathWith(waveXNum % number).CGPath
        circleAnimation.delegate = self
        circleLayer.path = pathWith(waveXNum % number).CGPath
        circleLayer.addAnimation(circleAnimation, forKey: "circleAnimatePath")
        
        waveXNum++
    }
    
    /// 动画停止之前
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if waveHeight <= 0 {
            isAnimate = false
        }
        if flag && isAnimate {
            waveAnimate()
            //self.waveHeight -= self.waveHeight / 7
        }else {
            isAnimate = false
        }
    }
    
    /// 贝塞尔曲线绘制
    private func pathWith(tag: Int) -> NSBezierPath {
        var height = self.frame.height
        var py = height - height * currentProgress
        var px = -CGFloat(tag+1) * waveWidth * waveSpeed
        
        var bezierPath = NSBezierPath()
        
        func drawBezierLine() {
            var isAdd = true
            while px < frame.width + ((4 / waveSpeed) - CGFloat(tag)) * waveWidth * waveSpeed {
                px += waveWidth
                let newX = px - waveWidth / 2
                let newY = py + (isAdd ? waveHeight : -waveHeight) * (tag%1==0 ? maxAmplitude : minAmplitude)
                bezierPath.addQuadCurveToPoint(CGPointMake(px, py), controlPoint: CGPointMake(newX, newY))
                isAdd = !isAdd
            }
        }
        
        bezierPath.moveToPoint(CGPointMake(px, py))                                                                    // B
        drawBezierLine()
        bezierPath.addLineToPoint(CGPointMake(px, -1))                                                     // C
        bezierPath.addLineToPoint(CGPointMake(-CGFloat(tag+1) * waveWidth, -1))    // D
        bezierPath.addLineToPoint(CGPointMake(-CGFloat(tag+1) * waveWidth, py))                // A
        bezierPath.closePath()
        
        return bezierPath
    }
}
