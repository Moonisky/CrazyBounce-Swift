//
//  FileManager.swift
//  CrazyBounce
//
//  Created by Semper Idem on 14-12-29.
//  Copyright (c) 2014年 益行人-星夜暮晨. All rights reserved.
//

import UIKit

enum bestTimeMode {
    case Classic
    case Normal
    case Items
}

class FileManager{
    var bestTimeClassic = 0
    var bestTimeNormal = 0
    var bestTimeIdems = 0
    
    var filename:String!
    
    init(){
        filename = filePath("time.plist") as String
    }
    
    func loadFile(){
        if NSFileManager.defaultManager().fileExistsAtPath(filename) {
            var data = NSArray(contentsOfFile: filename)!
            bestTimeClassic = data.objectAtIndex(0) as! Int
            bestTimeNormal = data.objectAtIndex(1) as! Int
            bestTimeIdems = data.objectAtIndex(2) as! Int
        }
        println("file load over, the data is Classic:\(bestTimeClassic), Normal: \(bestTimeNormal), Items: \(bestTimeIdems)")
    }
    
    func writeFileOf(#Mode: bestTimeMode, WithTime time: Int){
        var data = NSMutableArray()
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
    
    //文件路径函数
    private func filePath(fileName: NSString) -> NSString {
        var path:NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        var docPath:NSString = path.objectAtIndex(0) as! NSString
        var filePath = docPath.stringByAppendingPathComponent(fileName as String)
        return filePath
    }
    
}
