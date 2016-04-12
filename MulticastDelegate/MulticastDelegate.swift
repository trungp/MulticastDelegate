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

// Operator to compare two weakNodes
func ==(lhs: WeakNode, rhs: WeakNode) -> Bool {
    return lhs.callback === rhs.callback
}

infix operator ~> {}

// Operator to perform closure on delegate
func ~> <T> (inout left: MulticastDelegate<T>?, right: ((T) -> Void)?) {
    if let left = left, right = right {
        left.performClosure(right)
    }
}

infix operator += {}
// Operator to add delegate to multicast object
func += <T> (inout left: MulticastDelegate<T>?, right: T?) {
    if let left = left, right = right {
        left.addCallback(right)
    }
}

// Operator to remove delegate from multicast object
func -= <T> (inout left: MulticastDelegate<T>?, right: T?) {
    if let left = left, right = right {
        left.removeCallback(right)
    }
}

// This class provide the way to perform selector or notify to multiple object.
// Basically, it works like observer pattern, send message to all observer which registered with the multicast object.
// The multicast object hold the observer inside as weak storage so make sure you are not lose the object without any reason.
public class MulticastDelegate<T>: NSObject {
    
    private var nodes: [WeakNode]?
    
    public override init() {
        super.init()
        nodes = [WeakNode]()
    }
    
    /**
     Ask to know number of nodes or delegates are in multicast object whhich are ready to perform selector.
     
     - Returns Int: Number of delegates in multicast object.
    */
    public func numberOfNodes() -> Int {
        return nodes?.count ?? 0
    }
    
    /**
     Add callback to perform selector on later.
     
     - Parameter callback: The callback to perform selector in the future.
     - Parameter queue: The queue to perform the callback on. Default is main queue
    */
    public func addCallback(callback: T?, queue: dispatch_queue_t? = nil) {
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
    
    public func removeCallback(callback: T?) {
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
