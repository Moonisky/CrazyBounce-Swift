//
//  ViewController.swift
//  CrazyBounce-OS
//
//  Created by Semper_Idem on 15/11/2.
//  Copyright © 2015年 益行人-星夜暮晨. All rights reserved.
//

import AppKit
import SpriteKit

class GameSceneViewController: NSViewController, WaterWaveDelegate {
    
    // MARK: IBOutlet
    
    /// 水波视图
    var waterWaveView: WaterWaveView!
    /// 游戏初始视图
    @IBOutlet private weak var gameBeginView: NSView!
    /// 游戏视图
    @IBOutlet private weak var gameView: SKView!
    /// 游戏结束视图
    @IBOutlet private weak var gameEndView: NSView!
    @IBOutlet private weak var lblGamemode: NSTextField!
    /// 游戏LOGO
    @IBOutlet private weak var imgLogo: NSImageView!
    /// 游戏开始按钮
    @IBOutlet private weak var btnGameBegin: NSButton!
    /// 新高分视图
    @IBOutlet private weak var imgNewHighScore: NSImageView!
    /// 最佳成绩标签
    @IBOutlet private weak var lblBestTime: NSTextField!
    /// 当前成绩标签
    @IBOutlet private weak var lblCurrentTime: NSTextField!
    /// 当前游戏模式标签
    @IBOutlet private weak var lblCurrentMode: NSTextField!
    /// 当前游戏提示标签
    @IBOutlet private weak var lblTips: NSTextField!
    
    // MARK: 属性
    private enum GameState {
        case Begin
        case Gaming
        case Over
    }
    /// 当前游戏状态
    private var currentState = GameState.Begin
    /// 游戏场景
    private var gameScene: GameScene!
    /// 判断游戏是否结束，结束为true
    private var gameISOver = true
    /// 当前游戏模式
    private var currentGameMode = GameMode.Normal
    
    // MARK: IBAction
    @IBAction private func btnBeginPressed(sender: NSButton) {
        waterWaveView.riseUp()
    }
    
    @IBAction func btnRestartPressed(sender: NSButton) {
        waterWaveView.dropDown()
        waterWaveView.hidden = false
        gameEndView.hidden = true
        gameView.hidden = false
        // 启动游戏界面
        currentState = .Gaming
        gameScene.addWater()
        // 设定模式显示标签
        lblGamemode.hidden = false
        self.view.sortSubviewsUsingFunction(siblingViewWithComparator, context: nil)
        let modeNumber = arc4random_uniform(3)
        switch modeNumber {
        case 1:
            currentGameMode = .Classic
        case 2:
            currentGameMode = .Normal
        default:
            currentGameMode = .Items
        }
        lblGamemode.cell?.title = currentGameMode.rawValue
    }
    
    override func loadView() {
        super.loadView()
        initGameBeginView()
        
        // 初始化水波
        waterWaveView = WaterWaveView(frame: self.view.bounds, color: NSColor(red: 16/255, green: 169/255, blue: 240/255, alpha: 1))
        print(self.view.bounds)
        waterWaveView.setCurrentProgress(0.2)
        waterWaveView.setWaveRiseSpeed(0.4)
        waterWaveView.delegate = self
        waterWaveView.startAnimation()
        self.view.addSubview(waterWaveView)
    }
    
    // MARK: UI初始化
    
    /// 初始化游戏开始视图
    private func initGameBeginView() {
        // 设置背景
        let layer1 = CALayer()
        layer1.backgroundColor = NSColor(red: 166 / 255, green: 216 / 255, blue: 238 / 255, alpha: 1).CGColor
        self.gameBeginView.wantsLayer = true
        self.gameBeginView.layer = layer1
        
        let layer3 = CALayer()
        layer3.backgroundColor = NSColor(red: 16/255, green: 169/255, blue: 240/255, alpha: 1).CGColor
        self.gameEndView.wantsLayer = true
        self.gameEndView.layer = layer3
    }
    
    /// 初始化游戏视图
    private func initGameView() {
        // 游戏场景
        gameScene = GameScene(size: self.gameView.bounds.size)
        gameScene.scaleMode = .AspectFill
        gameScene.gameViewController = self
        gameScene.labelSetting = (30, CGPointMake(gameView.frame.width / 2, 65), 18, CGPointMake(gameView.frame.width / 2, 30))
        gameScene.waveHeight = 0.2 * gameView.frame.height
        gameView.ignoresSiblingOrder = true
        gameView.presentScene(gameScene)
    }
    
    // MARK: Delegate
    func checkWaterDropOver() {
        print("drop over")
        switch currentState {
        case .Begin:
            break
        case .Gaming:
            // 加载结束，启动游戏
            lblGamemode.hidden = true
            gameScene.gamemode = currentGameMode
            gameScene.startGame()
        case .Over:
            break
        }
    }
    
    func checkWaterRiseOver() {
        print("rise over")
        switch currentState {
        case .Begin:
            // 开始界面水波上升结束，启动游戏界面
            currentState = .Gaming
            gameBeginView.hidden = true
            gameView.hidden = false
            initGameView()
            waterWaveView.dropDown()
            // 设定模式显示标签
            lblGamemode.hidden = false
            self.view.sortSubviewsUsingFunction(siblingViewWithComparator, context: nil)
            let modeNumber = arc4random_uniform(3)
            switch modeNumber {
            case 1:
                currentGameMode = .Classic
            case 2:
                currentGameMode = .Normal
            default:
                currentGameMode = .Items
            }
            lblGamemode.cell?.title = currentGameMode.rawValue
        case .Gaming:
            // 游戏结束
            currentState = .Over
            gameView.hidden = true
            gameEndView.hidden = false
            waterWaveView.hidden = true
            // 设置结束数据
            lblCurrentTime.cell?.title = gameScene.nowTime.timeTransformToString()
            lblBestTime.cell?.title = gameScene.bestTime.timeTransformToString()
            lblCurrentMode.cell?.title = currentGameMode.rawValue
            lblTips.cell?.title = Tips[Int(UInt(arc4random()%33))]!
            if gameScene.nowTime > gameScene.bestTime {
                imgNewHighScore.hidden = false
            } else {
                imgNewHighScore.hidden = true
            }
            gameScene.nowTime = 0
            gameScene.bestTime = 0
            gameScene.removeAllChildren()
            gameScene.removeAllActions()
        case .Over:
            break
        }
    }
    
    // MARK: Helper Method
    
    /// 游戏结束
    private func gameOver() {
        gameISOver = true
        currentState = .Over
        self.gameView.hidden = true
        self.gameEndView.hidden = false
    }
}

