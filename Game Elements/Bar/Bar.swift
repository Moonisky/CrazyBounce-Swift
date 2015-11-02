//
//  Bar.swift
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

/// 滑块
class Bar: SKSpriteNode {
    
    #if os(iOS)
    private let barImage = UIImage(named: "BarImage")
    #elseif os(OSX)
    private let barImage = NSImage(named: "BarImage")
    #endif
    /// 标记滑块变长的时间，如果为-1表示不变长
    var longTime = -1
    
    // MARK: 初始化
    init?(imageName: String) {
        
        super.init(texture: SKTexture(imageNamed: imageName), color: SKColor.clearColor(), size: barImage!.size)
        self.name = "bar"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPhysicsBody(){
        self.physicsBody = SKPhysicsBody(rectangleOfSize: barImage!.size)
        // 将球拍设置为静态物体
        self.physicsBody?.dynamic = false
        self.physicsBody?.categoryBitMask = barCategory
        self.physicsBody?.collisionBitMask = 0  //不会对其他碰撞物体发生作用力
    }
    
    func barBecomeLong(){
        self.runAction(SKAction.scaleXTo(2.0, duration: 1))
        longTime = 0
    }
    
    func barBackShort(){
        if longTime >= 0 {
            longTime++
            if longTime > 600{
                self.runAction(SKAction.scaleXTo(1, duration: 1))
                longTime = -1
            }
        }
    }
}