//
//  GameOverViewController.swift
//  CrazyBounce
//
//  Created by Semper Idem on 14-12-29.
//  Copyright (c) 2014年 益行人-星夜暮晨. All rights reserved.
//

import UIKit

protocol viewPassValueDelegate {
    func passValue(currentTime: String, bestTime: String, gamemode: GameMode, best: Bool)
}

class GameOverViewController: UIViewController, viewPassValueDelegate {
    
    @IBOutlet private var lbl_CurrentTime: UILabel!
    @IBOutlet private var lbl_BestTime: UILabel!
    @IBOutlet private weak var lbl_gamemode: UILabel!
    @IBOutlet private weak var lbl_Catalog: UILabel!
    @IBOutlet private weak var img_HighScore: UIImageView!
    
    var delegate:viewPassValueDelegate!
    
    @IBAction func gameRestart(sender: UIButton) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: 16/255, green: 169/255, blue: 240/255, alpha: 1)
        img_HighScore.hidden = true
        
        lbl_Catalog.text = Tips[Int(UInt(arc4random()%33))]
    }
    
    func passValue(currentTime: String, bestTime: String, gamemode: GameMode, best: Bool) {
        println("currentTime: \(currentTime), bestTime: \(bestTime)")
        lbl_CurrentTime.text = currentTime
        lbl_BestTime.text = bestTime
        if best {
            img_HighScore.hidden = false
        }
        lbl_gamemode.text = gamemode.rawValue
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
