//
//  Ball.swift
//  CrazyBounce
//
//  Created by Semper Idem on 14-12-8.
//  Copyright (c) 2014年 益行人-星夜暮晨. All rights reserved.
//

import UIKit
import SpriteKit

class Ball: SKSpriteNode {
    
    let ballDownImage = SKTexture(imageNamed: "BallShockedImage")
    let ballUpImage = SKTexture(imageNamed: "BallRelievedImage")
    let ballBounceImage = SKTexture(imageNamed: "BallFrustratedImage")

    var knockTimes = 0      // 小球碰撞次数
    var shockTime = 0       // 小球碰撞之后的时间
    var shocked = false      // 小球是否处于“shocked”状态
    
    var initSpeed: CGFloat = 0
    
    convenience init(center: CGPoint, speed: CGFloat) {
        let size = UIImage(named: "BallShockedImage")!.size
        self.init(center: center, size: size, speed: speed)
    }
    
    init(center: CGPoint, size: CGSize, speed: CGFloat) {
        super.init(texture: ballDownImage, color: UIColor.clearColor(), size: size)
        self.position = center
        initSpeed = speed
    }
    
    func setTheBall(){
        // 小球受到过撞击
        if shocked {
            shockTime++
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
        if !shocked {
            if self.physicsBody?.velocity.dy > 0 {
                self.texture = ballDownImage
            }else {
                self.texture = ballUpImage
            }
        }
    }
    
    func knockBall(){
        if !shocked {
            shocked = true
            self.texture = ballBounceImage
        }
    }
    
    func setPhysicsBody(){
        self.name = "ball"
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.height / 2)
        self.physicsBody?.restitution = 1   //弹性
        self.physicsBody?.friction = 0      // 摩擦力
        self.physicsBody?.linearDamping = 0  //线性阻尼，气体或液体对物体的减速效果
        // 添加推力
        self.physicsBody?.applyImpulse(CGVectorMake(CGFloat(arc4random()%6) + 1, initSpeed))
        self.physicsBody?.usesPreciseCollisionDetection = true      // 精确碰撞检测
        self.physicsBody?.categoryBitMask = ballCategory
        self.physicsBody?.contactTestBitMask = waterCategory | ballCategory
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}