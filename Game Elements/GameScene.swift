//
//  GameScene.swift
//  CrazyBounce
//
//  Created by Semper Idem on 14-12-7.
//  Copyright (c) 2014年 益行人-星夜暮晨. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: 属性
    
    /// 速度比例，用以适配各设备上的初始速度
    private let speedRotate: CGFloat = 4 / 768
    /// 最近小球出现的时间，这个时间用以决定是否添加新的小球，以秒为单位
    private var lastBallInterval: NSTimeInterval = 0
    /// 上次游戏刷新的时间，以秒为单位
    private var lastUpdateInterval: NSTimeInterval = 0
    /// 最近道具小球出现的时间，以秒为单位
    private var lastItemsInterval: NSTimeInterval = 0
    /// 道具小球随机出现的时间，以秒为单位
    private var ItemsAppearRandomTime: NSTimeInterval {
        return NSTimeInterval(arc4random()%9)
    }
    /// 道具小球出现时间段，以秒为单位
    private var ItemsAppearTimePart = 0
    /// 检测游戏是否已经开始，如果游戏已经开始，那么此属性将为 true
    private var gameStart: Bool = false
    
    /// 滑块
    private var bar: Bar!
    /// Sprite 标签节点，用以记录当前时间
    private var lbl_currentTime: SKLabelNode!
    /// Sprite 标签节点，用以记录最佳时间
    private var lbl_bestTime: SKLabelNode!
    /// 文件管理器
    private var fileManager = FileManager()
    
    /// 当前游戏时间，以毫秒为单位
    var nowTime = 0
    /// 最佳游戏时间，以毫秒为单位
    var bestTime = 0

    /// 设定的当前波浪高度
    var waveHeight: CGFloat = 0
    /// 当前游戏模式
    var gamemode:GameMode!
    /// 传递进来的标签设置，分别是当前时间文本大小，当前时间位置，最佳时间文本大小，最佳时间位置
    var labelSetting: (currentSize: CGFloat, currentCenter: CGPoint, bestSize: CGFloat, bestCenter: CGPoint)!
    /// 关联的视图控制器
    #if os(iOS)
    weak var gameViewController: GameViewController!
    #elseif os(OSX)
    weak var gameViewController: GameSceneViewController!
    #endif
    
    // MARK: 初始化
    
    override init(size: CGSize) {
        super.init(size: size)
        
        // 游戏场景设置
        self.backgroundColor = SKColor(red: 166/255, green: 216/255, blue: 238/255, alpha: 1)
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)      // 设置静态物理实体
        self.physicsBody?.friction = 0      // 取消摩擦
        self.physicsWorld.gravity = CGVectorMake(0, -1)      // 取消重力
        self.physicsBody?.angularDamping = 0  // 取消空气阻力
        self.physicsWorld.contactDelegate = self
        
        // 添加水底
        let waterRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 1)
        let water = SKNode()
        water.physicsBody = SKPhysicsBody(edgeLoopFromRect: waterRect)
        self.addChild(water)
        water.physicsBody?.categoryBitMask = waterCategory
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: 游戏配置
    
    /// 启动游戏
    func startGame() {
        gameStart = true
        print("游戏开始")
        initLabel()
        fileManager.loadFile()
        
        // 添加 Bar
        bar = Bar(imageName: "BarImage")
        bar.position = CGPointMake(self.frame.width / 2, self.frame.height / 2)
        bar.setPhysicsBody()
        self.addChild(bar)
        
        guard let gamemode = gamemode else { print("游戏启动失败");return }
        switch gamemode {
        case .Classic :
            startGameModeClassic()
        case .Normal:
            startGameModeNormal()
        case .Items:
            startGameModeItems()
        }
        addClassicBall()
    }
    
    /// 启动经典模式
    private func startGameModeClassic() {
        print("start classic game mode")
        bestTime = fileManager.bestTimeClassic
        lbl_bestTime.text = "Classic Best:\(bestTime.timeTransformToString())"
    }
    
    /// 启动普通模式
    private func startGameModeNormal() {
        print("start normal game mode")
        bestTime = fileManager.bestTimeNormal
        lbl_bestTime.text = "Normal Best:\(bestTime.timeTransformToString())"
    }
    
    /// 启动道具模式
    private func startGameModeItems() {
        print("start items game mode")
        bestTime = fileManager.bestTimeIdems
        lbl_bestTime.text = "Items Best:\(bestTime.timeTransformToString())"
    }
    
    /// 添加经典小球
    private func addClassicBall() {
        let initX = UInt32(self.frame.width - 20)
        //var initSpeed = speedRotate * self.frame.height * CGFloat(2)
        let initSpeed: CGFloat = 4
        guard let ball: NormalBall = NormalBall(center: CGPoint(x: CGFloat(arc4random()%initX+10), y: self.frame.height), speed: initSpeed) else { gameExit();return }
        self.addChild(ball)
        ball.setPhysicsBody()
    }
    
    /// 添加道具小球
    private func addItemsBall(){
        let random = arc4random()%3
        let initX = UInt32(self.frame.width - 20)
        let initSpeed = speedRotate * self.frame.height * CGFloat(2)
        let ball: Ball?
        switch random {
        case 0:
            ball = AllCleanBall(center: CGPoint(x: CGFloat(arc4random()%initX+10), y: self.frame.height), speed: initSpeed)
        case 1:
            ball = LongBarBall(center: CGPoint(x: CGFloat(arc4random()%initX+10), y: self.frame.height), speed: initSpeed)
        default:
            ball = SlowBall(center: CGPoint(x: CGFloat(arc4random()%initX+10), y: self.frame.height), speed: initSpeed)
        }
        if ball == nil {
            gameExit()
            return
        }
        self.addChild(ball!)
        ball!.setPhysicsBody()
    }
    
    /// 游戏结束
    private func gameOver() {
        if gameStart {
            gameStart = false
            checkTheTime()
            lbl_bestTime.text = "Best:\(bestTime.timeTransformToString())"
            gameViewController.waterWaveView.riseUp()
            self.physicsWorld.gravity = CGVectorMake(0, 0)
            let children = self.children
            for child in children where child is Ball {
                child.physicsBody?.velocity = CGVectorMake(0, 0)
            }
        }
    }
    
    /// 游戏退出，只有出错才调用
    private func gameExit() {
        #if os(iOS)
        gameViewController.dismissViewControllerAnimated(true, completion: nil)
        gameViewController.performSegueWithIdentifier("gameBack", sender: self)
        #endif
    }
    
    // MARK: Touch Action

    // 检测触摸动作来移动 Bar
    #if os(iOS)
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: AnyObject in touches {
            // 获取触摸位置
            let touchLocation = touch.locationInNode(self)
            let previousLocation = touch.previousLocationInNode(self)
            // 获取 Bar 结点
            guard let barNode = self.childNodeWithName("bar") as? SKSpriteNode where gameStart else { return }
            // 计算 Bar 将要移动的位置
            var barNodeX = barNode.position.x + (touchLocation.x - previousLocation.x)
            var barNodeY = barNode.position.y + (touchLocation.y - previousLocation.y)
            // 限制 Bar 的移动范围
            barNodeX = max(barNodeX, bar.size.width / 2)
            barNodeX = min(barNodeX, self.size.width - bar.size.width / 2)
            barNodeY = min(barNodeY, self.size.height - bar.size.height * 2)
            barNodeY = max(barNodeY, waveHeight)
            bar.position = CGPointMake(barNodeX, barNodeY)
        }
    }
    #elseif os(OSX)
    override func mouseDragged(theEvent: NSEvent) {
        // 获取鼠标点击位置
        let location = theEvent.locationInNode(self)
        // 计算 Bar 将要移动的位置
        var barNodeX =  location.x
        var barNodeY =  location.y
        // 限制 Bar 的移动范围
        barNodeX = max(barNodeX, bar.size.width / 2)
        barNodeX = min(barNodeX, self.size.width - bar.size.width / 2)
        barNodeY = min(barNodeY, self.size.height - bar.size.height * 2)
        barNodeY = max(barNodeY, waveHeight)
        bar.position = CGPointMake(barNodeX, barNodeY)
    }
    #endif
    
    // MARK: 碰撞处理
    
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
        if (firstBody.categoryBitMask == ballCategory || firstBody.categoryBitMask == CleanBallCategory || firstBody.categoryBitMask == LongBallCategory || firstBody.categoryBitMask == SlowBallCategory) && secondBody.categoryBitMask == waterCategory && gameStart {
            gameOver()
            firstBody.node?.removeFromParent()
        }
        // 处理小球和小球之间的碰撞
        else if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == ballCategory && gameStart {
            guard let firstBall = firstBody.node as? Ball else { return }
            guard let secondBall = secondBody.node as? Ball else { return }
            if gamemode == GameMode.Normal || gamemode == GameMode.Items {
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
            guard let ball = secondBody.node as? NormalBall else { return }
            ball.knockBall()
        }
        else if firstBody.categoryBitMask == ballCategory && secondBody.categoryBitMask == CleanBallCategory && gameStart {
            guard let ball = firstBody.node as? NormalBall else { return }
            ball.knockBall()
        }
        // 处理小球碰撞效果
        else if firstBody.categoryBitMask == ballCategory && gameStart{
            guard let ball = firstBody.node as? Ball else { return }
            ball.knockBall()
        }
        else if secondBody.categoryBitMask == ballCategory && gameStart{
            guard let ball = secondBody.node as? Ball else { return }
            ball.knockBall()
        }
        // 道具小球处理
        else if firstBody.categoryBitMask == CleanBallCategory && secondBody.categoryBitMask == barCategory && gameStart{
            guard let cleanball = firstBody.node as? AllCleanBall else { return }
            if cleanball.ballTime == -1 {
                cleanball.ballTime = 0
            }
        }
        else if firstBody.categoryBitMask == LongBallCategory && secondBody.categoryBitMask == barCategory && gameStart{
            self.bar.barBecomeLong()
            firstBody.node?.removeFromParent()
        }
        else if firstBody.categoryBitMask == SlowBallCategory && secondBody.categoryBitMask == barCategory && gameStart{
            let children = self.children
            for child in children where child is Ball {
                child.physicsBody?.velocity = CGVectorMake(child.physicsBody!.velocity.dx / 4, 0)
            }
            firstBody.node?.removeFromParent()
        }
    }
    
    // MARK: 时间处理
    
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
            guard let ball = self.childNodeWithName("ball") as? Ball else { return }
            ball.setTheBall()
            guard let body = ball.physicsBody else { return }
            let speed = sqrt(body.velocity.dx * body.velocity.dx + body.velocity.dy * body.velocity.dy)
            if speed > 600{
                print("speed limit mode begin")
                body.linearDamping = 0.4
            }else {
                body.linearDamping = 0
            }
        }
    }
    
    /// 小球出现时间
    private func update(timeSinceLastUptade timeSinceLastUptade: CFTimeInterval){
        if gamemode == GameMode.Items {
            self.lastItemsInterval += timeSinceLastUptade
            if lastItemsInterval > ItemsAppearRandomTime + NSTimeInterval(ItemsAppearTimePart) {
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
    
    // MARK: Helper Method
    
    /// 当前时间标签变化动画
    private func changeTheLabel(time: Int){
        if nowTime > bestTime {
            lbl_bestTime.hidden = true
            lbl_currentTime.runAction(SKAction.scaleTo(2, duration: 1.0))
        }
        lbl_currentTime.text = time.timeTransformToString()
    }
    
    /// 比较当前时间和最高时间并存档
    private func checkTheTime(){
        if nowTime > bestTime {
            switch gamemode! {
            case .Classic:
                fileManager.writeFileOfMode(.Classic, WithTime: nowTime)
            case .Normal:
                fileManager.writeFileOfMode(.Normal, WithTime: nowTime)
            case .Items:
                fileManager.writeFileOfMode(.Items, WithTime: nowTime)
            }
        }
    }
    
    /// 配置文字
    private func initLabel(){
        lbl_currentTime = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
        lbl_currentTime.hidden = false
        lbl_currentTime.fontSize = labelSetting.0
        lbl_currentTime.position = CGPointMake(labelSetting.1.x, self.frame.height - labelSetting.1.y)
        lbl_currentTime.text = "00\"00"
        lbl_bestTime = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
        lbl_bestTime.hidden = false
        lbl_bestTime.fontSize = labelSetting.2
        lbl_bestTime.position = CGPointMake(labelSetting.3.x, self.frame.height - labelSetting.3.y)
        lbl_bestTime.text = "Best:00\"00"
        self.addChild(lbl_currentTime)
        self.addChild(lbl_bestTime)
    }
}