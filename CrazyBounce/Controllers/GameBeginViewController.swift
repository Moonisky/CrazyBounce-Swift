//
//  GameBeginViewController.swift
//  CrazyBounce
//
//  Created by Semper Idem on 14-12-7.
//  Copyright (c) 2014年 益行人-星夜暮晨. All rights reserved.
//

import UIKit

/// 游戏开始界面控制器
class gameBeginViewController: UIViewController, waterViewDelegate {
    
    // MARK: 属性
    
    /// 水波视图
    private var waterWaveView: waterView!
    /// 游戏开始按钮
    @IBOutlet private weak var btn_gameBegin: UIButton!
    /// LOGO图片
    @IBOutlet private weak var img_logo: UIImageView!
    
    // MARK: 动作
    
    /// 点击游戏开始按钮触发，触发水波上升效果
    @IBAction private func GameBegin(sender: UIButton) {
        waterWaveView.riseUp()
        view.sendSubviewToBack(img_logo)
        view.sendSubviewToBack(btn_gameBegin)
    }
    
    // MARK: 控制器生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let waveHeight = CGFloat(120) / 568 * self.view.frame.height
        waterWaveView = waterView(frame: view.bounds, color: UIColor(red: 16/255, green: 169/255, blue: 240/255, alpha: 1), waveHeight: Float(waveHeight))
        waterWaveView.delegate = self
        
        self.view.insertSubview(waterWaveView, atIndex: 0)
    }
    
    // MARK: waterViewDelegate
    
    func checkWaterRiseOver() {
        self.dismissViewControllerAnimated(true, completion: nil)
        performSegueWithIdentifier("gameStart", sender: self)
    }
    
    // 强制隐藏状态栏
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
