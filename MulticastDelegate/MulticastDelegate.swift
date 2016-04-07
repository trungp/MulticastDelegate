//
//  MulticastCallback.swift
//  MulticastDelegate
//
//  Created by TrungP1 on 4/7/16.
//  Copyright © 2016 TrungP1. All rights reserved.
//

/**
 * It provides a way for multiple delegates to be called, each on its own delegate queue.
 * There are some versions for Objective-C on github. And this is the version for Swift.
 */

import Foundation

func ==(lhs: WeakNode, rhs: WeakNode) -> Bool {
    return lhs.callback === rhs.callback
}

infix operator ~> {}

func ~> <T> (inout left: MulticastDelegate<T>?, right: ((T) -> Void)?) {
    if let left = left, right = right {
        left.performClosure(right)
    }
}

infix operator += {}
func += <T> (inout left: MulticastDelegate<T>?, right: T?) {
    if let left = left, right = right {
        left.addCallback(right)
    }
}

func -= <T> (inout left: MulticastDelegate<T>?, right: T?) {
    if let left = left, right = right {
        left.removeCallback(right)
    }
}

class MulticastDelegate<T>: NSObject {
    
    private var nodes: [WeakNode]?
    
    override init() {
        super.init()
        nodes = [WeakNode]()
    }
    
    func numberOfNodes() -> Int {
        return nodes?.count ?? 0
    }
    
    func addCallback(callback: T?, queue: dispatch_queue_t? = nil) {
        // Default is main queue
        let queue: dispatch_queue_t = {
            guard let q = queue else { return dispatch_get_main_queue() }
            return q
        }()
        
        if var nodes = nodes, let callback = callback {
            let node = WeakNode(callback as? AnyObject, queue: queue)
            nodes.append(node)
            self.nodes = nodes
        }
    }
    
    func removeCallback(callback: T?) {
        if let nodes = nodes, let cb1 = callback as? AnyObject {
            self.nodes = nodes.filter { node in
                
                if let cb = node.callback where cb === cb1 {
                    return false
                }
                return true
            }
        }
    }
    
    func performClosure(closure: ((T) -> Void)?) {
        if let nodes = nodes, closure = closure {
            nodes.forEach { node in
                if let cb = node.callback as? T {
                    let queue: dispatch_queue_t = {
                        guard let q = node.queue else { return dispatch_get_main_queue() }
                        return q
                    }()
                    dispatch_async(queue, {
                        closure(cb)
                    })
                }
            }
        }
    }
}
