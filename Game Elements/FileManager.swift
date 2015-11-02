//
//  FileManager.swift
//  CrazyBounce
//
//  Created by Semper Idem on 14-12-29.
//  Copyright (c) 2014年 益行人-星夜暮晨. All rights reserved.
//

import Foundation

/// 文件管理器
class FileManager {
    
    // MARK: 属性
    
    /// 经典模式最佳时间
    var bestTimeClassic = 0
    /// 正常模式最佳时间
    var bestTimeNormal = 0
    /// 道具模式最佳时间
    var bestTimeIdems = 0
    
    /// 当前文件名称
    private var filename:String!
    
    // MARK: 初始化
    
    init() {
        filename = getFilePathWithFileName("time.plist")
    }
    
    // MARK: 读写方法
    
    func loadFile() {
        if NSFileManager.defaultManager().fileExistsAtPath(filename) {
            guard let data = NSArray(contentsOfFile: filename) else { return }
            bestTimeClassic = data.objectAtIndex(0) as! Int
            bestTimeNormal = data.objectAtIndex(1) as! Int
            bestTimeIdems = data.objectAtIndex(2) as! Int
        }
        print("file load over, the data is Classic:\(bestTimeClassic), Normal: \(bestTimeNormal), Items: \(bestTimeIdems)")
    }
    
    func writeFileOfMode(Mode: GameMode, WithTime time: Int){
        let data = NSMutableArray()
        switch Mode {
        case .Classic:
            bestTimeClassic = time
        case .Normal:
            bestTimeNormal = time
        case .Items:
            bestTimeIdems = time
        }
        data.addObject(bestTimeClassic)
        data.addObject(bestTimeNormal)
        data.addObject(bestTimeIdems)
        data.writeToFile(filename, atomically: true)
    }
    
    /// 文件路径函数
    private func getFilePathWithFileName(filename: String) -> String {
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        guard let fileURL = NSURL(string: path) else { return path }
        return fileURL.URLByAppendingPathComponent(filename).absoluteString
    }
}
