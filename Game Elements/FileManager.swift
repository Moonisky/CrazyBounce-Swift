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
    var bestTimeClassic = [String: Int]()
    /// 正常模式最佳时间
    var bestTimeNormal = [String: Int]()
    /// 道具模式最佳时间
    var bestTimeIdems = [String: Int]()
    
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
            
            if let classic = data.objectAtIndex(0) as? [String: Int] {
                bestTimeClassic = classic
            }
            if let normal = data.objectAtIndex(1) as? [String: Int] {
                bestTimeNormal = normal
            }
            if let idem = data.objectAtIndex(2) as? [String: Int] {
                bestTimeIdems = idem
            }
        } else {
            NSMutableArray(capacity: 3).writeToFile(filename, atomically: true)
        }
        print("file load over, the best time in Classic Mode is:\(bestTimeClassic.values.sort().first), in Normal Mode is: \(bestTimeNormal.values.sort().first), in Items Mode is: \(bestTimeIdems.values.sort().first)")
    }
    
    func writeFileOfMode(Mode: GameMode, WithTime time: Int) {
        guard let data = NSMutableArray(contentsOfFile: filename) else { return }
        let date = NSDate().toString(format: "yyyy-MM-dd HH:mm:ss")
        switch Mode {
        case .Classic:
            guard var classic = data.objectAtIndex(0) as? [String: Int] else {
                data.replaceObjectAtIndex(0, withObject: [date: time])
                data.writeToFile(filename, atomically: true)
                return
            }
            classic.updateValue(time, forKey: date)
            data.replaceObjectAtIndex(0, withObject: classic)
        case .Normal:
            guard var normal = data.objectAtIndex(1) as? [String: Int] else {
                data.replaceObjectAtIndex(1, withObject: [date: time])
                data.writeToFile(filename, atomically: true)
                return
            }
            normal.updateValue(time, forKey: date)
            data.replaceObjectAtIndex(1, withObject: normal)
        case .Items:
            guard var item = data.objectAtIndex(2) as? [String: Int] else {
                data.replaceObjectAtIndex(2, withObject: [date: time])
                data.writeToFile(filename, atomically: true)
                return
            }
            item.updateValue(time, forKey: date)
            data.replaceObjectAtIndex(2, withObject: item)
        }
    }
    
    /// 文件路径函数
    private func getFilePathWithFileName(filename: String) -> String {
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        guard let fileURL = NSURL(string: path) else { return path }
        return fileURL.URLByAppendingPathComponent(filename).absoluteString
    }
}
