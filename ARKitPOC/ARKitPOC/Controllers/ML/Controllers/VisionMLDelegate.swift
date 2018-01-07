
//
//  VisionMLDelegate.swift
//  DashPOC
//
//  Created by Mario Bragg on 10/27/17.
//  Copyright © 2017 Xevo. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class VisionMLDelegate:NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private let session = AVCaptureSession()
    weak var previewView: CameraView!
    
    weak var viewController: MLViewController?
    
    var visionRequests = [VNRequest]()
    let mlDispatchQueue = DispatchQueue(label: "com.xevo.mlDispatchQueue")
    var lastPrediction = "…"
    var runMLLoop = false
    
    var pixelBuffer : CVPixelBuffer?
    var requestOptions:[VNImageOption : Any] = [:]
    
    var nmsThreshold: Float?
    static var labels: [Any]?
    
    // MARK: - Init
    
    init(controller: MLViewController, view: CameraView) {
        super.init()
        
        let mlmodel = DaskClassifier()
        let userDefined: [String: String] = mlmodel.model.modelDescription.metadata[MLModelMetadataKey.creatorDefinedKey]! as! [String : String]
        VisionMLDelegate.labels = userDefined["classes"]!.components(separatedBy: ",")
        nmsThreshold = Float(userDefined["non_maximum_suppression_threshold"]!) ?? 0.5
        
        guard let mlModel = try? VNCoreMLModel(for: DaskClassifier().model) else {
            fatalError("Machine Learning Model missing!")
        }
        
        viewController = controller
        previewView = view
        setupCamera()
        
        // Set up Vision-CoreML Request
        let classificationRequest = VNCoreMLRequest(model: mlModel, completionHandler: classificationCompleteHandler)
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.scaleFill
        visionRequests = [classificationRequest]
        
        // Begin Loop to Update CoreML
        //startMLRequestLoop()
    }
    
    
    // MARK: - CoreML Vision Handling
    
    var lastTime: Date = Date()
    var count = 0
    var startDate: Date?
    var endDate: Date?
    
    // Continuously loop through CoreML requests. Video refresh frame updates are too fast at 60 fps
    // Also better than timer based as it will start a new request as soon as the old request finishes
    func startMLRequestLoop() {
        
        session.startRunning()
        self.runMLLoop = true
        self.mlRunLoop()
    }
    
    func stopMLRequestLoop()  {
        self.runMLLoop = false
        session.stopRunning()
    }
    
    func mlRunLoop() {
        
        if (!self.runMLLoop) {return}
        
        count += 1
        if (Date().timeIntervalSince(lastTime) >= 1)
        {
            print("time: \(Date().timeIntervalSince(lastTime)) count: \(count)")
            lastTime = Date()
            count = 0
        }
        
        mlDispatchQueue.async {
            
            self.updateCoreML()
            self.mlRunLoop()
        }
    }
    
    func updateCoreML() {
        
        if (self.pixelBuffer == nil) { return }
        
        let pixbuff : CVPixelBuffer? = self.pixelBuffer
        let orientation: UIDeviceOrientation = UIDevice.current.orientation
        
        //if (orientation != .faceUp && orientation != .faceDown)
        //{
            let cvOrientation = orientationTranslationMap[orientation]
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixbuff!, orientation: cvOrientation!, options: [:])
            
            startDate = Date()
            
            do {
                try imageRequestHandler.perform(self.visionRequests)
            } catch {
                print(error)
            }
        //}
    }
    
    private let orientationTranslationMap: [UIDeviceOrientation : CGImagePropertyOrientation] = [
        .portrait           : CGImagePropertyOrientation(rawValue: 6)!, // rightMirrored
        .portraitUpsideDown : CGImagePropertyOrientation(rawValue: 4)!, // leftMirrored
        .landscapeLeft      : CGImagePropertyOrientation(rawValue: 1)!, // upMirrored
        .landscapeRight     : CGImagePropertyOrientation(rawValue: 3)!, // downMirrored
        .faceUp             : CGImagePropertyOrientation(rawValue: 6)!, // rightMirrored
        .faceDown           : CGImagePropertyOrientation(rawValue: 6)!, // rightMirrored
        .unknown            : CGImagePropertyOrientation(rawValue: 6)!  // rightMirrored
    ]
    
    func classificationCompleteHandler(request: VNRequest, error: Error?) {
        
        if error != nil {
            print("Error: \((error?.localizedDescription)!)")
            return
        }
        
        endDate = Date()
        //print("process: \((endDate?.timeIntervalSince(startDate!))!)")
        
        let results = request.results as! [VNCoreMLFeatureValueObservation]
        
        let coordinates = results[0].featureValue.multiArrayValue!
        let confidence = results[1].featureValue.multiArrayValue!
        
        let confidenceThreshold = 0.25
        var unorderedPredictions = [Prediction]()
        let numBoundingBoxes = confidence.shape[0].intValue
        let numClasses = confidence.shape[1].intValue
        let confidencePointer = UnsafeMutablePointer<Double>(OpaquePointer(confidence.dataPointer))
        let coordinatesPointer = UnsafeMutablePointer<Double>(OpaquePointer(coordinates.dataPointer))
        
        for b in 0..<numBoundingBoxes {
            
            var maxConfidence = 0.0
            var maxIndex = 0
            
            for c in 0..<numClasses {
                let conf = confidencePointer[b * numClasses + c]
                if conf > maxConfidence {
                    maxConfidence = conf
                    maxIndex = c
                }
            }
            
            if maxConfidence > confidenceThreshold {
                
                let x = coordinatesPointer[b * 4]
                let y = coordinatesPointer[b * 4 + 1]
                let w = coordinatesPointer[b * 4 + 2]
                let h = coordinatesPointer[b * 4 + 3]
                
                let rect = CGRect(x: CGFloat(x - w/2), y: CGFloat(y - h/2),
                                  width: CGFloat(w), height: CGFloat(h))
                
                let prediction = Prediction(labelIndex: maxIndex,
                                            confidence: Float(maxConfidence),
                                            boundingBox: rect)
                unorderedPredictions.append(prediction)
            }
        }
        
        // Array to store final predictions (after post-processing)
        var predictions: [Prediction] = []
        let orderedPredictions = unorderedPredictions.sorted { $0.confidence > $1.confidence }
        var keep = [Bool](repeating: true, count: orderedPredictions.count)
        for i in 0..<orderedPredictions.count {
            if keep[i] {
                predictions.append(orderedPredictions[i])
                let bbox1 = orderedPredictions[i].boundingBox
                for j in (i+1)..<orderedPredictions.count {
                    if keep[j] {
                        let bbox2 = orderedPredictions[j].boundingBox
                        if IoU(bbox1, bbox2) > nmsThreshold! {
                            keep[j] = false
                        }
                    }
                }
            }
        }
        
        if (predictions.count > 0)
        {
            for pred in predictions {
                //print(pred)
                
                DispatchQueue.main.async {
                    
                    if (pred.confidence > 0.1)
                    {
                        self.viewController?.indicatorView.alpha = 1.0
                        
                        let x = pred.boundingBox.origin.x * self.previewView.frame.size.width
                        let y = pred.boundingBox.origin.y * self.previewView.frame.size.height
                        
                        var width: CGFloat = 0.0
                        var height: CGFloat = 0.0
                        
                        if (UIDevice.current.orientation == UIDeviceOrientation.portrait || UIDevice.current.orientation == UIDeviceOrientation.portraitUpsideDown)
                        {
                            height = pred.boundingBox.size.width * self.previewView.frame.size.width
                            width = pred.boundingBox.size.width * self.previewView.frame.size.height
                        }
                        else if (UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight)
                        {
                            width = pred.boundingBox.size.width * self.previewView.frame.size.width
                            height = pred.boundingBox.size.width * self.previewView.frame.size.height
                        }
                        
                        let rect = CGRect(x: x, y: y, width: width, height: height)
                        print(rect)
                        
                        UIView.animate(withDuration: 0.05, animations: {
                            
                            self.viewController?.indicatorView.center = CGPoint(x: x + width/2, y: y + height/2)
                            self.viewController?.indicatorView.frame.size = CGSize(width: width, height: height)
                            
                        }, completion: { (complete) in
                            
                        })
                    }
                }
            }
        }
        else
        {
            DispatchQueue.main.async {
                self.viewController?.indicatorView.alpha = 0.0
            }
        }
    }
    
    struct Prediction {
        let labelIndex: Int
        let confidence: Float
        let boundingBox: CGRect
        
//        var label: String  {
//            get {
//                return VisionMLDelegate.labels![labelIndex] as! String
//            }
//        }
    }
    
    public func IoU(_ a: CGRect, _ b: CGRect) -> Float {
        let intersection = a.intersection(b)
        let union = a.union(b)
        return Float((intersection.width * intersection.height) / (union.width * union.height))
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        
        if let camData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            self.requestOptions = [.cameraIntrinsics:camData]
        }
        
        self.pixelBuffer = pixBuffer
    }
    
    // MARK: - Camera Setup
    
    func setupCamera() {
        
        previewView.session = session
        let availableCameraDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        var activeDevice: AVCaptureDevice?
        
        for device in availableCameraDevices.devices as [AVCaptureDevice]{
            if device.position == .back {
                activeDevice = device
                break
            }
        }
        
        do {
            let camInput = try AVCaptureDeviceInput(device: activeDevice!)
            
            if session.canAddInput(camInput) {
                session.addInput(camInput)
            }
        } catch {
            print("no camera")
        }
        session.sessionPreset = .high
        guard auth() else {return}
        
        let videoOutput = AVCaptureVideoDataOutput()
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Camera Buffer Queue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil))
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        
        previewView.videoPreviewLayer.videoGravity = .resize
        //session.startRunning()
    }
    
    func startSession() {
        session.startRunning()
    }
    
    func stopSession() {
        session.stopRunning()
    }
    
    private func auth() -> Bool{
        
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        
        switch authorizationStatus
        {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted:Bool) -> Void in
                
                if granted {
                    DispatchQueue.main.async {
                        self.previewView.setNeedsDisplay()
                    }
                }
            })
            return true
        case .authorized:
            return true
        case .denied, .restricted: return false
        }
    }
}

