//
//  CameraView.swift
//  DashPOC
//
//  Created by Mario Bragg on 11/6/17.
//  Copyright © 2017 Xevo. All rights reserved.
//

import UIKit
import AVFoundation

class CameraView: UIView {

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
        }
        
        return layer
    }
    
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
    
    // MARK: UIView
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
