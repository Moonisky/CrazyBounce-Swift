//
//  AllCleanBall.swift
//  CrazyBounce
//
//  Created by Semper Idem on 15-1-3.
//  Copyright (c) 2015年 益行人-星夜暮晨. All rights reserved.
//

import UIKit
import SpriteKit

class SlowBall: Ball {
    
    let SlowBall = SKTexture(imageNamed: "BallSlowImage")
    
    init(center: CGPoint, speed: CGFloat) {
        let size = UIImage(named: "BallSlowImage")!.size
        super.init(center: center, size: size, speed: speed)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setPhysicsBody() {
        self.texture = SlowBall
        self.name = "ball"
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.height / 2)
        self.physicsBody?.restitution = 1   //弹性
        self.physicsBody?.friction = 0      // 摩擦力
        self.physicsBody?.linearDamping = 0  //线性阻尼，气体或液体对物体的减速效果
        // 添加推力
        self.physicsBody?.applyImpulse(CGVectorMake(CGFloat(arc4random()%6) + 1, initSpeed))
        self.physicsBody?.usesPreciseCollisionDetection = true      // 精确碰撞检测
        self.physicsBody?.categoryBitMask = SlowBallCategory
        self.physicsBody?.contactTestBitMask = waterCategory | ballCategory | barCategory
    }
    
    override func setTheBall() {
        
    }
    
    override func knockBall() {
        
    }
    
}
