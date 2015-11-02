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
    @IBOutlet weak var gameView: SKView!
    /// 游戏结束视图
    @IBOutlet weak var gameEndView: NSView!
    /// 游戏LOGO
    @IBOutlet private weak var imgLogo: NSImageView!
    /// 游戏开始按钮
    @IBOutlet private weak var btnGameBegin: NSButton!
    /// 模式显示
    @IBOutlet weak var lblGamemode: NSTextField!
    /// 新高分视图
    @IBOutlet weak var imgNewHighScore: NSImageView!
    /// 最佳成绩标签
    @IBOutlet weak var lblBestTime: NSTextField!
    /// 当前成绩标签
    @IBOutlet weak var lblCurrentTime: NSTextField!
    /// 当前游戏模式标签
    @IBOutlet weak var lblCurrentMode: NSTextField!
    /// 当前游戏提示标签
    @IBOutlet weak var lblTips: NSTextField!
    
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
        waterWaveView.riseUp()
    }
    
    override func loadView() {
        super.loadView()
        initGameBeginView()
        
        // 初始化水波
        waterWaveView = WaterWaveView(frame: self.view.bounds, color: NSColor(red: 16/255, green: 169/255, blue: 240/255, alpha: 1))
        print(self.view.bounds)
        waterWaveView.setCurrentProgress(0.2)
        waterWaveView.delegate = self
        waterWaveView.startAnimation()
        self.view.addSubview(waterWaveView)
    }
    
    // MARK: UI初始化
    
    /// 初始化游戏开始视图
    private func initGameBeginView() {
        // 设置背景
        let layer = CALayer()
        layer.backgroundColor = NSColor(red: 166 / 255, green: 216 / 255, blue: 238 / 255, alpha: 1).CGColor
        self.gameBeginView.wantsLayer = true
        self.gameBeginView.layer = layer
    }
    
    /// 初始化游戏视图
    private func initGameView() {
        // 设置背景
        let layer = CALayer()
        layer.backgroundColor = NSColor(red: 166 / 255, green: 216 / 255, blue: 238 / 255, alpha: 1).CGColor
        self.gameView.wantsLayer = true
        self.gameView.layer = layer
        
        // 游戏场景
        gameView.ignoresSiblingOrder = true
        gameScene = GameScene(size: self.gameView.bounds.size)
        gameScene.scaleMode = .AspectFill
        gameScene.gameViewController = self
        gameScene.gamemode = currentGameMode
        gameView.presentScene(gameScene)
        
        // 水面下降
        waterWaveView.dropDown()
    }
    
    /// 初始化结束视图
    private func initGameEndView() {
        // 设置背景
        let layer = CALayer()
        layer.backgroundColor = NSColor(red: 166 / 255, green: 216 / 255, blue: 238 / 255, alpha: 1).CGColor
        self.gameEndView.wantsLayer = true
        self.gameEndView.layer = layer
    }
    
    // MARK: Delegate
    func checkWaterDropOver() {
        print("drop over")
        waterWaveView.riseUp()
    }
    
    func checkWaterRiseOver() {
        print("rise over")
        waterWaveView.dropDown()
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

