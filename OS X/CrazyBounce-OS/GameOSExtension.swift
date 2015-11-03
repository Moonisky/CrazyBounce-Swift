//
//  GameOSExtension.swift
//  CrazyBounce
//
//  Created by Semper_Idem on 15/11/3.
//  Copyright © 2015年 益行人-星夜暮晨. All rights reserved.
//

import Cocoa

func siblingViewWithComparator(view1: NSView, view2: NSView, context: UnsafeMutablePointer<Void>) -> NSComparisonResult {
    if view1 is NSTextField {
        return .OrderedDescending
    } else if view2 is NSTextField {
        return .OrderedAscending
    }
    return .OrderedSame
}
