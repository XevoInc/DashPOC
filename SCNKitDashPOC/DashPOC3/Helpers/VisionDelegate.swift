//
//  VisionDelegate.swift
//  DashPOC2
//
//  Created by Mario Bragg on 11/24/17.
//  Copyright © 2017 Xevo. All rights reserved.
//

import UIKit
import Vision

protocol VisionUIDelegate: AnyObject {
    func updateUI(box: VNRectangleObservation)
}

class VisionDelegate: NSObject {
    
    weak var visionUIDelegate: VisionUIDelegate?
    
    lazy var findRectangleRequest: VNDetectRectanglesRequest = {
        
        let recRequest = VNDetectRectanglesRequest(completionHandler: self.handleRectangleDetect)
        
        //iPad screen 7.75 x 5.75 (.74) frame 9.5 x 6.75 (.71)
        recRequest.minimumAspectRatio = 0.73
        recRequest.maximumAspectRatio = 0.75
        recRequest.maximumObservations = 1
        return recRequest
    }()
    
    override init() {
        super.init()
    }
    
    // MARK: - Vision Request
    
    func performRequest(pixelBuffer: CVImageBuffer, requestOptions: [VNImageOption : Any]) {
        
        let orientation: UIDeviceOrientation = UIDevice.current.orientation
        
        if (orientation != .faceUp && orientation != .faceDown)
        {
            let cvOrientation = orientationTranslationMap[orientation]
            
            let recRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: cvOrientation!, options: requestOptions)
            //let recRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: requestOptions)
            
            do {
                try recRequestHandler.perform([self.findRectangleRequest])
            } catch {
                NSLog(error.localizedDescription)
            }
        }
    }
    
    private let orientationTranslationMap: [UIDeviceOrientation : CGImagePropertyOrientation] = [
        .portrait           : CGImagePropertyOrientation(rawValue: 6)!, // rightMirrored
        .portraitUpsideDown : CGImagePropertyOrientation(rawValue: 4)!, // leftMirrored
        .landscapeLeft      : CGImagePropertyOrientation(rawValue: 1)!, // upMirrored
        .landscapeRight     : CGImagePropertyOrientation(rawValue: 3)!, // downMirrored
        .unknown            : CGImagePropertyOrientation(rawValue: 6)!  // rightMirrored
        ]
    
    // MARK: - Vision Response Handler
    
    var count = 0
    var lastTime: Date = Date()
    func handleRectangleDetect(request: VNRequest, error: Error?) {
        
        //DispatchQueue.main.async {
            
            self.count += 1
            if (Date().timeIntervalSince(self.lastTime) >= 1)
            {
                print("time: \(Date().timeIntervalSince(self.lastTime)) count: \(self.count)")
                self.lastTime = Date()
                self.count = 0
            }
            
            guard let observation = request.results?.first as? VNRectangleObservation
                else { //NSLog("unexpected result type from VNDetectRectanglesRequest")
                    return
            }
            
            self.visionUIDelegate?.updateUI(box: observation)
        //}
    }
}
