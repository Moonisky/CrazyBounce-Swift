//
//  Ball.swift
//  CrazyBounce
//
//  Created by Semper_Idem on 15/11/2.
//  Copyright © 2015年 益行人-星夜暮晨. All rights reserved.
//

import SpriteKit

/// 小球基础类
class Ball: SKSpriteNode {
    
    // MARK: 属性
    
    /// 小球碰撞次数
    var knockTimes = 0
    /// 小球初始速度
    var initSpeed: CGFloat = 0
    
    // MARK: 初始化
    init(center: CGPoint, size: CGSize, speed: CGFloat, defaultTexture texture: SKTexture) {
        super.init(texture: texture, color: SKColor.clearColor(), size: size)
        self.position = center
        initSpeed = speed
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: 配置方法
    /// 刷新小球
    func setTheBall() { }
    
    func knockBall() { }
    
    func setPhysicsBody(){
        self.name = "ball"
        self.physicsBody = SKPhysicsBody(circleOfRadius: size.height / 2)
        self.physicsBody?.restitution = 1   //弹性
        self.physicsBody?.friction = 0      // 摩擦力
        self.physicsBody?.linearDamping = 0  //线性阻尼，气体或液体对物体的减速效果
        // 添加推力
        self.physicsBody?.applyImpulse(CGVectorMake(CGFloat(arc4random()%6) + 1, initSpeed))
        self.physicsBody?.usesPreciseCollisionDetection = true      // 精确碰撞检测
    }
}
