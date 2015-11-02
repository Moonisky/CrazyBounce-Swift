//
//  NormalBall.swift
//  CrazyBounce
//
//  Created by Semper_Idem on 15/11/2.
//  Copyright © 2015年 益行人-星夜暮晨. All rights reserved.
//

import SpriteKit
#if os(iOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

/// 正常小球
class NormalBall: Ball {
    
    // MARK: 属性
    
    /// 小球向下图片纹理
    private let ballDownImage = SKTexture(imageNamed: "BallShockedImage")
    /// 小球向上图片纹理
    private let ballUpImage = SKTexture(imageNamed: "BallRelievedImage")
    /// 小球碰撞后图片纹理
    private let ballBounceImage = SKTexture(imageNamed: "BallFrustratedImage")
    
    /// 小球碰撞之后的时间
    private var shockTime = 0
    /// 小球是否处于“shocked”状态
    private var shocked = false
    
    init(center: CGPoint, size: CGSize, speed: CGFloat) {
        super.init(center: center, size: size, speed: speed, defaultTexture: ballDownImage)
    }
    
    convenience init?(center: CGPoint, speed: CGFloat) {
        #if os(iOS)
        guard let image = UIImage(named: "BallShockedImage") else { return nil }
        #elseif os(OSX)
        guard let image = NSImage(named: "BallShockedImage") else { return nil }
        #endif
        self.init(center: center, size: image.size, speed: speed)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: 配置方法
    /// 刷新小球
    override func setTheBall() {
        // 小球受到过撞击
        if shocked {
            shockTime++
        } else {
            if self.physicsBody?.velocity.dy > 0 {
                self.texture = ballDownImage
            }else {
                self.texture = ballUpImage
            }
        }
        // 小球进入Frustrated状态
        if shockTime > 30 {
            shockTime = 0
            shocked = false
            if self.physicsBody?.velocity.dy > 0 {
                self.texture = ballDownImage
            }else {
                self.texture = ballUpImage
            }
        }
    }
    
    override func knockBall(){
        if !shocked {
            shocked = true
            self.texture = ballBounceImage
        }
    }
    
    override func setPhysicsBody(){
        super.setPhysicsBody()
        self.physicsBody?.categoryBitMask = ballCategory
        self.physicsBody?.contactTestBitMask = waterCategory | ballCategory
    }
}
