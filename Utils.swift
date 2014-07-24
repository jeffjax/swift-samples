//
//  Utils.swift
//  swift-samples
//
//  Created by Jeff Jackson on 7/23/14.
//  Copyright (c) 2014 Esri. All rights reserved.
//

import Foundation

// Execute some code after a delay on the main queue.
//
func dispatch_after_delay(delay: NSTimeInterval, block: dispatch_block_t) {
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
    dispatch_after(time, dispatch_get_main_queue(), block)
}
