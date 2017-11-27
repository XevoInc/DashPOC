//
//  VisionFrameAnalyzer.swift
//  DashPOC2
//
//  Created by Mario Bragg on 11/24/17.
//  Copyright © 2017 Xevo. All rights reserved.
//

import UIKit

class VisionFrameAnalyzer: NSObject {
    
    private var frameQueue: QueueRect?
    private let frameHistoryBufferMax = 5
    private let frameDeviation: CGFloat = 0.15
    
    // MARK: - Singleton
    
    static let sharedAnalyzer = VisionFrameAnalyzer()
    
    override init() {
        super.init()
        
        frameQueue = QueueRect()
    }
    
    // MARK: - Public
    
    func frameIsValid(_ frame: CGRect) -> Bool {
        
        if (frameQueue?.count == frameHistoryBufferMax) {
            
            //            if (!frameXisValid(frame: frame)) {
            //                print("\(frame) X is not valid")
            //                return false
            //            }
            
            //            if (!frameYisValid(frame: frame)) {
            //                print("\(frame) Y is not valid")
            //                return false
            //            }
            
            if (!frameWidthIsValid(frame: frame)) {
                print("\(frame) Width is not valid")
                return false
            }
            
            if (!frameHeightIsValid(frame: frame)) {
                print("\(frame) Height is not valid")
                return false
            }
            
            _ = frameQueue?.dequeue()
        }
        
        frameQueue?.enqueue(frame)
        //print("AverageX = \((frameQueue?.averageX)!)")
        return frameQueue?.count == frameHistoryBufferMax
    }
    
    func reset() {
        frameQueue?.reset()
    }
    
    // MARK: - Private
    
    private func frameXisValid(frame: CGRect) -> Bool {
        
        let dev = (frameQueue?.averageX)! * frameDeviation
        let minX = (frameQueue?.averageX)! - dev
        let maxX = (frameQueue?.averageX)! + dev
        return (frame.origin.x >= minX && frame.origin.x <= maxX)
    }
    
    private func frameYisValid(frame: CGRect) -> Bool {
        
        let dev = (frameQueue?.averageY)! * frameDeviation
        let minY = (frameQueue?.averageY)! - dev
        let maxY = (frameQueue?.averageY)! + dev
        return (frame.origin.y >= minY && frame.origin.y <= maxY)
    }
    
    private func frameWidthIsValid(frame: CGRect) -> Bool {
        
        let dev = (frameQueue?.averageWidth)! * frameDeviation
        let minWidth = (frameQueue?.averageWidth)! - dev
        let maxWidth = (frameQueue?.averageWidth)! + dev
        return (frame.width >= minWidth && frame.width <= maxWidth)
    }
    
    private func frameHeightIsValid(frame: CGRect) -> Bool {
        
        let dev = (frameQueue?.averageHeight)! * frameDeviation
        let minHeight = (frameQueue?.averageHeight)! - dev
        let maxHeight = (frameQueue?.averageHeight)! + dev
        return (frame.height >= minHeight && frame.height <= maxHeight)
    }
}
