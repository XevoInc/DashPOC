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
    
    // MARK: - Init
    
    init(controller: MLViewController, view: CameraView) {
        super.init()
        
        guard let mlModel = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Machine Learning Model missing!")
        }
        
        viewController = controller
        previewView = view
        setupCamera()
        
        // Set up Vision-CoreML Request
        let classificationRequest = VNCoreMLRequest(model: mlModel, completionHandler: classificationCompleteHandler)
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
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
        
        // Get Camera Image as RGB
        let pixbuff : CVPixelBuffer? = self.pixelBuffer
        
        if pixbuff == nil { return }
        let ciImage = CIImage(cvPixelBuffer: pixbuff!)
        
        // Prepare CoreML/Vision Request
        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        // let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage!, orientation: myOrientation, options: [:])
        // Alternatively; we can convert the above to an RGB CGImage and use that. Also UIInterfaceOrientation can inform orientation values.
        
        startDate = Date()
        
        do {
            try imageRequestHandler.perform(self.visionRequests)
        } catch {
            print(error)
        }
    }
    
    func classificationCompleteHandler(request: VNRequest, error: Error?) {
        
        if error != nil {
            print("Error: \((error?.localizedDescription)!)")
            return
        }
        
        guard let observations = request.results else {
            print("No results")
            return
        }
        
        endDate = Date()
        print("process: \((endDate?.timeIntervalSince(startDate!))!)")
        
        let classifications = observations[0...1]
            .flatMap({ $0 as? VNClassificationObservation })
            .map({ "\($0.identifier) \(String(format:"- %.2f", $0.confidence))" })
            .joined(separator: "\n")
        
        
        DispatchQueue.main.async {
            
            print(classifications)
            print("--")
            
            var debugText = ""
            debugText += classifications
            self.viewController?.textView.text = debugText
            
            // Store the latest prediction
            var objectName = "…"
            objectName = classifications.components(separatedBy: "-")[0]
            objectName = objectName.components(separatedBy: ",")[0]
            self.lastPrediction = objectName
        }
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

