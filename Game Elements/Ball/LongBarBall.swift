//
//  LongBarBall.swift
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

/// 道具小球 - 滑块变长
class LongBarBall: Ball {
    
    // MARK: 初始化
    init?(center: CGPoint,size: CGSize, speed: CGFloat) {
        super.init(center: center, size: size, speed: speed, defaultTexture: SKTexture(imageNamed: "BallLongImage"))
    }
    
    convenience init?(center: CGPoint, speed: CGFloat) {
        #if os(iOS)
            guard let image = UIImage(named: "BallLongImage") else { return nil }
        #elseif os(OSX)
            guard let image = NSImage(named: "BallLongImage") else { return nil }
        #endif
        self.init(center: center, size: image.size, speed: speed)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setPhysicsBody() {
        super.setPhysicsBody()
        self.physicsBody?.categoryBitMask = LongBallCategory
        self.physicsBody?.contactTestBitMask = waterCategory | ballCategory | barCategory
    }
}