//
//  WeakNode.swift
//  MulticastDelegate
//
//  Created by TrungP1 on 4/7/16.
//  Copyright © 2016 TrungP1. All rights reserved.
//

import Foundation

struct WeakNode: Equatable {
    
    var queue: dispatch_queue_t?
    weak var callback: AnyObject?
    
    init(_ cb: AnyObject?, queue q: dispatch_queue_t?) {
        self.callback = cb
        self.queue = q
    }
}