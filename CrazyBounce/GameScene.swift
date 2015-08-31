//
//  GameScene.swift
//  CrazyBounce
//
//  Created by Semper Idem on 14-12-7.
//  Copyright (c) 2014年 益行人-星夜暮晨. All rights reserved.
//

import SpriteKit

enum GameMode: String {
    case Normal = "普通模式"             // 普通模式
    case Classic = "经典模式"              // 经典模式，小球不会消
    case Items = "道具模式"               // 道具模式，继承自普通模式
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let speedRotate: CGFloat = 4 / 768          // 速度比例，用以适配各设备上的速度
    
    var bar: Bar!
    var gameStart: Bool = false                      // 检测游戏是否开始
    var waveHeight: CGFloat = 0
    
    var lastBallInterval: NSTimeInterval = 0            // 最近小球出现的时间
    var lastUpdateInterval: NSTimeInterval = 0       //  上次更新时间
    var lastItemsInterval: NSTimeInterval = 0       //最近道具小球出现的时间
    var ItemsAppearRandomTime = arc4random()%9              // 道具小球随机出现时间
    var ItemsAppearTimePart = 0                     // 道具小球出现时间段
    var nowTime = 0                                     // 当前游戏时间
    var bestTime = 0                                        // 最佳游戏时间
    var gamemode:GameMode!
    
    var saveCurrentTime: UILabel!
    var saveBestTime: UILabel!
    var lbl_currentTime: SKLabelNode!
    var lbl_bestTime: SKLabelNode!
    
    var fileManager = FileManager()
    var gameViewController: GameViewController!
    
    override init() {
        super.init()
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        // 游戏场景设置
        self.backgroundColor = UIColor(red: 166/255, green: 216/255, blue: 238/255, alpha: 1)
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)      // 设置静态物理实体
        self.physicsBody?.friction = 0      // 取消摩擦
        self.physicsWorld.gravity = CGVectorMake(0, -1)      // 取消重力
        self.physicsBody?.angularDamping = 0  // 取消空气阻力
        self.physicsWorld.contactDelegate = self
        
        // 添加水底
        var waterRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 1)
        var water = SKNode()
        water.physicsBody = SKPhysicsBody(edgeLoopFromRect: waterRect)
        self.addChild(water)
        water.physicsBody?.categoryBitMask = waterCategory
    }
    
// ------游戏配置---------------------------------------------------------------------------------------------
    
    // 游戏启动
    func startGame(){
        gameStart = true
        println("start game")
        initLabel()
        fileManager.loadFile()
        switch gamemode! {
        case .Classic :
            startGameModeClassic()
        case .Normal:
            startGameModeNormal()
        case .Items:
            startGameModeItems()
        }
    }
    
    // 启动经典模式
    func startGameModeClassic(){
        println("start classic game mode")
        // 添加 Bar
        bar = Bar(imageName: "BarImage")
        bar.position = CGPointMake(self.frame.width / 2, self.frame.height / 2)
        self.addChild(bar)
        bar.setPhysicsBody()
        bestTime = fileManager.bestTimeClassic
        lbl_bestTime.text = "Classic Best:\(timeTransform(bestTime))"
        gamemode = GameMode.Classic
        addClassicBall()
    }
    
    // 启动普通模式
    func startGameModeNormal(){
        println("start normal game mode")
        // 添加Bar
        bar = Bar(imageName: "BarImage")
        bar.position = CGPointMake(self.frame.width / 2, self.frame.height / 2)
        self.addChild(bar)
        bar.setPhysicsBody()
        bestTime = fileManager.bestTimeNormal
        lbl_bestTime.text = "Normal Best:\(timeTransform(bestTime))"
        gamemode = GameMode.Normal
        addClassicBall()
    }
    
    // 启动道具模式
    func startGameModeItems(){
        println("start items game mode")
        // 添加Bar
        bar = Bar(imageName: "BarImage")
        bar.position = CGPointMake(self.frame.width / 2, self.frame.height / 2)
        self.addChild(bar)
        bar.setPhysicsBody()
        bestTime = fileManager.bestTimeIdems
        lbl_bestTime.text = "Items Best:\(timeTransform(bestTime))"
        gamemode = GameMode.Items
        addClassicBall()
    }
    
    // 添加经典小球
    func addClassicBall(){
        var initX = UInt32(self.frame.width - 20)
        //var initSpeed = speedRotate * self.frame.height * CGFloat(2)
        var initSpeed: CGFloat = 4
        var ball: Ball = Ball(center: CGPoint(x: CGFloat(arc4random()%initX+10), y: self.frame.height), speed: initSpeed)
        self.addChild(ball)
        ball.setPhysicsBody()
    }
    
    // 添加道具小球
    func addItemsBall(){
        var random = arc4random()%3
        var initX = UInt32(self.frame.width - 20)
        var initSpeed = speedRotate * self.frame.height * CGFloat(2)
        var ball: Ball
        switch random {
        case 0:
            ball = AllCleanBall(center: CGPoint(x: CGFloat(arc4random()%initX+10), y: self.frame.height), speed: initSpeed)
        case 1:
            ball = LongBarBall(center: CGPoint(x: CGFloat(arc4random()%initX+10), y: self.frame.height), speed: initSpeed)
        default:
            ball = SlowBall(center: CGPoint(x: CGFloat(arc4random()%initX+10), y: self.frame.height), speed: initSpeed)
        }
        self.addChild(ball)
        ball.setPhysicsBody()
    }
    
    // 游戏结束
    func gameOver(){
        if gameStart {
            gameStart = false
            checkTheTime()
            lbl_bestTime.text = "Best:\(timeTransform(bestTime))"
            gameViewController.waterWaveView.waterRiseUp()
            self.physicsWorld.gravity = CGVectorMake(0, 0)
            var children = self.children
            for child in children {
                var ball = child as? Ball
                if ball != nil {
                    ball!.physicsBody?.velocity = CGVectorMake(0, 0)
                }
            }
        }
    }
    
// -------触摸动作-------------------------------------------------------------------------------------

    // 检测触摸动作来移动 Bar
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            // 获取触摸位置
            var touchLocation = touch.locationInNode(self)
            var previousLocation = touch.previousLocationInNode(self)
            // 获取 Bar 结点
            var barNode = self.childNodeWithName("bar") as? SKSpriteNode
            // 计算 Bar 将要移动的位置
            if barNode != nil && gameStart{
                var barNodeX = barNode!.position.x + (touchLocation.x - previousLocation.x)
                var barNodeY = barNode!.position.y + (touchLocation.y - previousLocation.y)
                // 限制 Bar 的移动范围
                barNodeX = max(barNodeX, bar.size.width / 2)
                barNodeX = min(barNodeX, self.size.width - bar.size.width / 2)
                barNodeY = min(barNodeY, self.size.height - bar.size.height * 2)
                barNodeY = max(barNodeY, waveHeight)
                bar.position = CGPointMake(barNodeX, barNodeY)
            }
        }
    }
    
//-------碰撞处理--------------------------------------------------------------------------------------
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        // 始终把类别码小的物体赋给 firstBody，快速排序
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        // 处理球和水底的碰撞
        if (firstBody.categoryBitMask == ballCategory || firstBody.categoryBitMask == CleanBallCategory || firstBody.categoryBitMask == LongBallCategory || firstBody.categoryBitMask == SlowBallCategory) && secondBody.categoryBitMask == waterCategory && gameStart{
            gameOver()
            firstBody.node?.removeFromParent()
        }
        // 处理小球和小球之间的碰撞
        else if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == ballCategory && gameStart{
            var firstBall = firstBody.node as! Ball
            var secondBall = secondBody.node as! Ball
            if gamemode == GameMode.Normal || gamemode == GameMode.Items{
                firstBall.knockTimes++
                secondBall.knockTimes++
                if firstBall.knockTimes > 3 {
                    firstBall.removeFromParent()
                }
                if secondBall.knockTimes > 3 {
                    secondBall.removeFromParent()
                }
            }
            firstBall.knockBall()
            secondBall.knockBall()
        }
            // 碰撞消失小球
        else if firstBody.categoryBitMask == CleanBallCategory && secondBody.categoryBitMask == ballCategory && gameStart {
            var cleanball = firstBody.node as! AllCleanBall
            var ball = secondBody.node as! Ball
            if cleanball.CleanSkill {
                secondBody.node?.removeFromParent()
            }
            ball.knockBall()
        }
        else if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == CleanBallCategory && gameStart {
            var cleanball = secondBody.node as! AllCleanBall
            var ball = firstBody.node as! Ball
            if cleanball.CleanSkill {
                firstBody.node?.removeFromParent()
            }
            ball.knockBall()
        }
        // 处理小球碰撞效果
        else if firstBody.categoryBitMask == ballCategory && gameStart{
            var ball = firstBody.node as? Ball
            ball?.knockBall()
        }
        else if secondBody.categoryBitMask == ballCategory && gameStart{
            var ball = secondBody.node as? Ball
            ball?.knockBall()
        }
        // 道具小球处理
        else if firstBody.categoryBitMask == CleanBallCategory && secondBody.categoryBitMask == barCategory && gameStart{
            var cleanball = firstBody.node as! AllCleanBall
            if !cleanball.CleanSkill {
                cleanball.CleanSkill = true
            }
        }
        else if firstBody.categoryBitMask == LongBallCategory && secondBody.categoryBitMask == barCategory && gameStart{
            self.bar.barBecomeLong()
            firstBody.node?.removeFromParent()
        }
        else if firstBody.categoryBitMask == SlowBallCategory && secondBody.categoryBitMask == barCategory && gameStart{
            var children = self.children
            for child in children {
                var ball = child as? Ball
                if ball != nil {
                    ball!.physicsBody?.velocity = CGVectorMake(ball!.physicsBody!.velocity.dx / 4, 0)
                }
            }
            firstBody.node?.removeFromParent()
        }
    }
    
    //---------时间处理----------------
    
    override func update(currentTime: CFTimeInterval) {
        if gameStart {
            var timeSinceLast: CFTimeInterval = currentTime - lastUpdateInterval
            lastUpdateInterval = currentTime
            if timeSinceLast > 1 {
                timeSinceLast = 1/60
                lastUpdateInterval = currentTime
            }
            nowTime++
            changeTheLabel(nowTime)
            update(timeSinceLastUptade: timeSinceLast)
            
            // 限制小球速度
            var ball = self.childNodeWithName("ball") as? Ball
            if ball != nil {
                ball!.setTheBall()
                var speed = sqrt(ball!.physicsBody!.velocity.dx * ball!.physicsBody!.velocity.dx + ball!.physicsBody!.velocity.dy * ball!.physicsBody!.velocity.dy)
                if speed > 600{
                    println("speed limit mode begin")
                    ball!.physicsBody?.linearDamping = 0.4
                }else {
                    ball!.physicsBody?.linearDamping = 0
                }
            }
        }
    }
    
    // 小球出现时间
    func update(#timeSinceLastUptade: CFTimeInterval){
        if gamemode == GameMode.Items {
            self.lastItemsInterval += timeSinceLastUptade
            if lastItemsInterval > NSTimeInterval(ItemsAppearRandomTime) + NSTimeInterval(ItemsAppearTimePart) {
                lastItemsInterval = 0
                ItemsAppearTimePart = 9
                addItemsBall()
            }
            bar.barBackShort()
        }
        self.lastBallInterval += timeSinceLastUptade
        if lastBallInterval > 2.5 {
            lastBallInterval = 0
            addClassicBall()
        }
    }
    
    // 当前时间标签变化动画
    func changeTheLabel(time: Int){
        if nowTime > bestTime {
            lbl_bestTime.hidden = true
            lbl_currentTime.runAction(SKAction.scaleTo(2, duration: 1.0))
        }
        lbl_currentTime.text = timeTransform(time)
    }
    
    // 比较当前时间和最高时间并存档
    func checkTheTime(){
        if nowTime > bestTime {
            bestTime = nowTime
            gameViewController.isBest = true
            switch gamemode! {
            case .Classic:
                fileManager.writeFileOf(Mode: bestTimeMode.Classic, WithTime: bestTime)
            case .Normal:
                fileManager.writeFileOf(Mode: bestTimeMode.Normal, WithTime: bestTime)
            case .Items:
                fileManager.writeFileOf(Mode: bestTimeMode.Items, WithTime: bestTime)
            }
        }
    }
    
    // 将时间（毫秒）转换为00:00格式
    func timeTransform(time: Int) -> String{
        var str = ""
        var second:Int = time / 60
        var midSecond:Int = time % 60
        if second < 10 {
            str = "0" + String(second) + "\""
        }
        else {
            str = String(second) + "\""
        }
        if midSecond < 10 {
            str += "0" + String(midSecond)
        }
        else {
            str += String(midSecond)
        }
        return str
    }
    
    // 配置文字
    func initLabel(){
        lbl_currentTime = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
        lbl_currentTime.hidden = false
        lbl_currentTime.fontSize = saveCurrentTime.font.pointSize
        lbl_currentTime.position = CGPointMake(saveCurrentTime.center.x, self.frame.height - saveCurrentTime.center.y)
        lbl_currentTime.text = "00\"00"
        lbl_bestTime = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
        lbl_bestTime.hidden = false
        lbl_bestTime.fontSize = saveBestTime.font.pointSize
        lbl_bestTime.position = CGPointMake(saveBestTime.center.x, self.frame.height - saveBestTime.center.y)
        lbl_bestTime.text = "Best:00\"00"
        self.addChild(lbl_currentTime)
        self.addChild(lbl_bestTime)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
