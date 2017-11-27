//
//  VisionObjectTrackDelegate.swift
//  DashPOC
//
//  Created by Mario Bragg on 11/7/17.
//  Copyright © 2017 Xevo. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

class VisionObjectTrackDelegate {

    weak var viewController: MLViewController?
    private let visionSequenceHandler = VNSequenceRequestHandler()
    var lastObservation: VNDetectedObjectObservation?
    
    func trackRequest(pixBuffer: CVPixelBuffer) {
        
        guard let lastObs = self.lastObservation else {
            return
        }
        
        let request = VNTrackObjectRequest(detectedObjectObservation: lastObs, completionHandler: self.handleVisionRequestUpdate)
        request.trackingLevel = .accurate
        
        do {
            try self.visionSequenceHandler.perform([request], on: pixBuffer)
        } catch {
            print("Throws: \(error)")
        }
    }
    
    private func handleVisionRequestUpdate(_ request: VNRequest, error: Error?) {
        
        // Dispatch to the main queue because we are touching non-atomic, non-thread safe properties of the view controller
        DispatchQueue.main.async {
            
            // make sure we have an actual result
            guard let newObservation = request.results?.first as? VNDetectedObjectObservation else { return }
            
            // prepare for next loop
            self.lastObservation = newObservation
            print(newObservation.confidence)
            
            // check the confidence level before updating the UI
            guard newObservation.confidence >= 0.3 else {
                // hide the rectangle when we lose accuracy so the user knows something is wrong
                //self.highlightView?.frame = .zero
                return
            }
            
            // calculate view rect
            var transformedRect = newObservation.boundingBox
            print(transformedRect)
            transformedRect.origin.y = 1 - transformedRect.origin.y
            let cameraLayer = self.viewController?.previewView.layer as! AVCaptureVideoPreviewLayer
            let convertedRect = cameraLayer.layerRectConverted(fromMetadataOutputRect: transformedRect)
            print(convertedRect)
            
            // move the highlight view
            //self.highlightView?.frame = convertedRect
            
            //self.drawBoundingBox(rect: convertedRect)
            self.drawBoundingBox(observation: newObservation)
        }
    }
    
    func drawBoundingBox(rect: CGRect) {
        
        self.viewController?.view.layer.sublayers?.removeSubrange(1...)
        
        let layer = self.createBoxView(withColor: UIColor.blue)
        layer.frame = self.transformRect(fromRect: rect, toViewRect: (self.viewController?.view)!)
        self.viewController?.view.layer.addSublayer(layer)
    }
    
    func drawBoundingBox(observation: VNDetectedObjectObservation) {
        
        self.viewController?.view.layer.sublayers?.removeSubrange(1...)
        
        let layer = self.createBoxView(withColor: UIColor.blue)
        layer.frame = self.transformRect(fromRect: observation.boundingBox, toViewRect: (self.viewController?.view)!)
        self.viewController?.view.layer.addSublayer(layer)
    }
    
    func transformRect(fromRect: CGRect , toViewRect: UIView) -> CGRect {
        
        var toRect = CGRect()
        toRect.size.width = fromRect.size.width * toViewRect.frame.size.width
        toRect.size.height = fromRect.size.height * toViewRect.frame.size.height
        toRect.origin.y =  (toViewRect.frame.height) - (toViewRect.frame.height * fromRect.origin.y )
        toRect.origin.y  = toRect.origin.y -  toRect.size.height
        toRect.origin.x =  fromRect.origin.x * toViewRect.frame.size.width
        
        return toRect
    }
    
    func createBoxView(withColor : UIColor) -> CALayer {
        
        let layer = CALayer()
        layer.borderColor = withColor.cgColor
        layer.borderWidth = 2
        return layer
    }
}
