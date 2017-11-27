//
//  Queue.swift
//  Vision Text Detection Demo
//
//  Created by Mario Bragg on 11/21/17.
//  Copyright © 2017 Hanjie Liu. All rights reserved.
//

import UIKit

public struct Queue<T> {
    
    fileprivate var array = [T]()
    
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    public var count: Int {
        return array.count
    }
    
    public mutating func enqueue(_ element: T) {
        array.append(element)
    }
    
    public mutating func dequeue() -> T? {
        if isEmpty {
            return nil
        } else {
            return array.removeFirst()
        }
    }
    
    public var front: T? {
        return array.first
    }
}

public struct QueueInt {
    
    fileprivate var array = [Int]()
    
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    public var count: Int {
        return array.count
    }
    
    public mutating func enqueue(_ element: Int) {
        array.append(element)
    }
    
    public mutating func dequeue() -> Int? {
        if isEmpty {
            return nil
        } else {
            return array.removeFirst()
        }
    }
    
    public var front: Int? {
        return array.first
    }
    
    public var sum: Int {
        return array.reduce(0, +)
    }
    
    public var average: Int {
        return sum/count
    }
}

public struct QueueRect {
    
    fileprivate var array = [CGRect]()
    
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    public var count: Int {
        return array.count
    }
    
    public mutating func enqueue(_ element: CGRect) {
        array.append(element)
    }
    
    public mutating func dequeue() -> CGRect? {
        if isEmpty {
            return nil
        } else {
            return array.removeFirst()
        }
    }
    
    public mutating func reset() {
        array.removeAll()
    }
    
    public var front: CGRect? {
        return array.first
    }
    
    public var sumX: CGFloat {
        return array.reduce(0, { $0 + $1.origin.x })
    }
    
    public var sumY: CGFloat {
        return array.reduce(0, { $0 + $1.origin.y })
    }
    
    public var sumWidth: CGFloat {
        return array.reduce(0, { $0 + $1.width })
    }
    
    public var sumHeight: CGFloat {
        return array.reduce(0, { $0 + $1.height })
    }

    public var averageX: CGFloat {
        return sumX/CGFloat(count)
    }
    
    public var averageY: CGFloat {
        return sumY/CGFloat(count)
    }
    
    public var averageWidth: CGFloat {
        return sumWidth/CGFloat(count)
    }
    
    public var averageHeight: CGFloat {
        return sumHeight/CGFloat(count)
    }
}



