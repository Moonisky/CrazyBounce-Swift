//
//  GameViewController.swift
//  CrazyBounce
//
//  Created by Semper Idem on 14-12-7.
//  Copyright (c) 2014年 益行人-星夜暮晨. All rights reserved.
//

import UIKit
import SpriteKit

/// 游戏界面控制器
class GameViewController: UIViewController, waterViewDelegate {
    
    // MARK: 属性
    
    /// 标签-当前游戏时间
    @IBOutlet private weak var lbl_currentTime: UILabel!
    /// 标签-最佳游戏时间
    @IBOutlet private weak var lbl_bestTime: UILabel!
    /// 标签-当前游戏模式
    @IBOutlet private weak var lbl_GameMode: UILabel!
    
    /// 游戏场景
    private var gameScene: GameScene!
    /// 页面传值委托，用以和游戏结束界面传值
    private var delegate: viewPassValueDelegate!
    /// 判断游戏是否结束，结束为True
    private var gameIsOver = false
    /// 当前游戏模式
    private var gamemode = GameMode.Normal
    /// 波浪高度
    private var waveHeight: CGFloat = 120 / 568
    
    /// 水波界面
    var waterWaveView: waterView!
    /// 判断当前成绩是否是最佳成绩
    var isBest = false
    
    // MARK: Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if !gameIsOver {
            gameIsOver = true
            // 添加游戏场景
            let skView = self.view as! SKView
            skView.ignoresSiblingOrder = true
            gameScene = GameScene(size: skView.bounds.size)
            gameScene.scaleMode = .AspectFill
            gameScene.gameViewController = self
            gameScene.gamemode = gamemode
            skView.presentScene(gameScene)
            
            // 添加水面
            waveHeight = 120/568
            waveHeight = CGFloat(waveHeight) * self.view.frame.height
            waterWaveView = waterView(frame: view.bounds, color: UIColor(red: 16/255, green: 169/255, blue: 240/255, alpha: 1), waveHeight: Float(waveHeight))
            waterWaveView.delegate = self
            waterWaveView.dropDown()
            view.addSubview(waterWaveView)
            view.bringSubviewToFront(lbl_GameMode)
        }
    }
    
    // MARK: 控制器生命周期
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        gameIsOver = false
        lbl_GameMode.hidden = false
        let modeNumber = arc4random_uniform(3)
        switch modeNumber {
        case 1:
            gamemode = .Classic
        case 2:
            gamemode = .Normal
        default:
            gamemode = .Items
        }
        lbl_GameMode.text = gamemode.rawValue
    }
    
    override func viewWillDisappear(animated: Bool) {
        gameScene.removeAllChildren()
        waterWaveView.removeFromSuperview()
    }
    
    // MARK: 检测水波
    
    func checkWaterDropOver() {
        print("water drop down over")
        gameScene.labelSetting = (lbl_currentTime.font.pointSize, lbl_currentTime.center, lbl_bestTime.font.pointSize, lbl_bestTime.center)
        gameScene.startGame()
        gameScene.waveHeight = waveHeight
        lbl_GameMode.hidden = true
        isBest = false
    }
    
    func checkWaterRiseOver() {
        print("water rise up over")
        gameOver()
    }
    
    // MARK: 游戏结束
    
    private func gameOver(){
        guard let gameOverViewController = self.storyboard?.instantiateViewControllerWithIdentifier("gameOverView") else { return }
        delegate = gameOverViewController as! GameOverViewController
        self.presentViewController(gameOverViewController, animated: false, completion: nil)
        delegate!.passValue(gameScene.nowTime.timeTransformToString(), bestTime: gameScene.bestTime.timeTransformToString(), gamemode: gamemode, best: self.isBest)
        gameIsOver = true
    }
    
    // MARK: 游戏场景配置
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.AllButUpsideDown
        } else {
            return UIInterfaceOrientationMask.All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}