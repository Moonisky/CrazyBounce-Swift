//
//  RankingListVieController.swift
//  CrazyBounce
//
//  Created by Semper_Idem on 15/11/3.
//  Copyright © 2015年 益行人-星夜暮晨. All rights reserved.
//

import Cocoa

class RankingListVieController: NSViewController {
    
    @IBAction func segmentControlChanged(sender: NSSegmentedControl) {
        
    }
    
    /// 排行榜数据
    private var tableData: [[String: Int]]!
    /// 当前的模式
    private var currentMode = mode.Classic
    private enum mode: Int {
        case Classic = 0
        case Normal = 1
        case Idem = 2
    }
    
    @IBOutlet weak var tableView: NSTableView!
    
    override func loadView() {
        super.loadView()
        
        // 读取数据
        let fileManager = FileManager()
        fileManager.loadFile()
        tableData = [fileManager.bestTimeClassic, fileManager.bestTimeNormal, fileManager.bestTimeIdems]
    }
    
}

extension RankingListVieController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if let data = tableData {
            return data[currentMode.rawValue].count
        }
        return 0
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        var cellData = [(String, Int)]()
        let currentData = tableData[currentMode.rawValue]
        currentData.forEach { cellData.append(($0, $1)) }
        if tableColumn?.identifier == "gameTime" {
            return "\(cellData[row].1)"
        }
        if tableColumn?.identifier == "gameDate" {
            return cellData[row].0
        }
        return nil
    }
}
