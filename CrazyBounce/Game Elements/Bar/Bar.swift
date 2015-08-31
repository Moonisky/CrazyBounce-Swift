//
//  Bar.swift
//  CrazyBounce
//
//  Created by Semper Idem on 14-12-7.
//  Copyright (c) 2014年 益行人-星夜暮晨. All rights reserved.
//

import UIKit
import SpriteKit

class Bar: SKSpriteNode {
    
    let barImage = UIImage(named: "BarImage")
    var long = false
    var times = 0

    init(imageName: String){
        super.init(texture: SKTexture(imageNamed: imageName), color: SKColor.clearColor(), size: barImage!.size)
        
        self.name = "bar"
    }
    
    func setPhysicsBody(){
        self.physicsBody = SKPhysicsBody(rectangleOfSize: barImage!.size)
        // 将球拍设置为静态物体
        self.physicsBody?.dynamic = false
        self.physicsBody?.categoryBitMask = barCategory
        self.physicsBody?.collisionBitMask = 0  //不会对其他碰撞物体发生作用力
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func barBecomeLong(){
        self.runAction(SKAction.scaleXTo(2.0, duration: 1))
        long = true
    }
    
    func barBackShort(){
        if long {
            times++
            if times > 600{
                self.runAction(SKAction.scaleXTo(1, duration: 1))
                long = false
                times = 0
            }
        }
    }    
}
