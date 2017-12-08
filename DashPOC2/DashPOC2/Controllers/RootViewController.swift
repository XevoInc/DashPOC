//
//  ViewController.swift
//  DashPOC2
//
//  Created by Mario Bragg on 11/24/17.
//  Copyright © 2017 Xevo. All rights reserved.
//

import UIKit

import UIKit
import Vision
import AVFoundation

class RootViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, VisionUIDelegate {
    
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var dashOverlay: UIImageView!
    @IBOutlet weak var touchOverlay: UIView!
    @IBOutlet weak var gasView: UIView!
    @IBOutlet weak var oilView: UIView!
    @IBOutlet weak var seatBeltView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    private let session = AVCaptureSession()
    private let visionSequenceHandler = VNSequenceRequestHandler()
    private let visionDelegate = VisionDelegate()
    private let frameAnalyzer = VisionFrameAnalyzer.sharedAnalyzer
    
    var startTracking = false
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.dashOverlay.image = UIImage(named: "bmw@3x.JPG")
        //self.dashOverlay.contentMode = .scaleAspectFill
        self.visionDelegate.visionUIDelegate = self
        
        self.setupCamera()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(tapGesture:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let connection =  self.previewView.videoPreviewLayer.connection  {
            
            let orientation: UIDeviceOrientation = UIDevice.current.orientation
            let previewLayerConnection : AVCaptureConnection = connection
            
            if previewLayerConnection.isVideoOrientationSupported {
                
                switch (orientation) {
                case .portrait: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    break
                case .landscapeRight: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                    break
                case .landscapeLeft: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                    break
                case .portraitUpsideDown: updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                    break
                default: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    break
                }
            }
            
            resetView()
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        
        layer.videoOrientation = orientation
        previewView.videoPreviewLayer.frame = self.view.bounds
    }
    
    private func resetView() {
        
        self.previewView.layer.sublayers?.removeSubrange(1...)
        frameAnalyzer.reset()
        //self.overlayView.isHidden = true
        self.startTracking = false
        
        //self.dashOverlay.frame = self.overlayView.bounds
    }
    
    @objc private func handleTap(tapGesture: UITapGestureRecognizer) {
        
        if (!startTracking) {
            self.startTracking = true
        }
        else {
            //self.componentSelected(tapGesture: tapGesture)
            self.startTracking = false
            self.imageView.isHidden = true
        }
    }
    
    func componentSelected(tapGesture: UITapGestureRecognizer) {
        
        let touch = tapGesture.location(in: self.view)
        let point = touchOverlay.convert(touch, from: self.view)
        print("\(point)")
        print("\(gasView.frame)")
        
    }
    
    // MARK: - VisionUIDelegate
    
    func updateUI(box: VNRectangleObservation) {
        
        self.previewView.layer.sublayers?.removeSubrange(1...)
        
        let xCoord = box.topLeft.x * previewView.frame.size.width
        let yCoord = (1 - box.topLeft.y) * previewView.frame.size.height
        let width = (box.topRight.x - box.bottomLeft.x) * previewView.frame.size.width
        let height = (box.topLeft.y - box.bottomLeft.y) * previewView.frame.size.height
        
        let frame = CGRect(x: xCoord, y: yCoord, width: width, height: height)
        
        if (self.startTracking && !frameAnalyzer.frameIsValid(frame)) {
            return
        }
        
        //print("box width: \(box.topRight.x - box.topLeft.x)")
        //print("width: \(width) height: \(height)")
        
        let layer = CALayer()
        layer.frame = frame
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.blue.cgColor
        
        previewView.layer.addSublayer(layer)
        
        if (self.startTracking)
        {
            //self.overlayView.isHidden = false
            //self.overlayView.frame = CGRect(x: 0, y: 0, width: layer.frame.width, height: layer.frame.height)
            //self.overlayView.center = CGPoint(x: layer.frame.midX, y: layer.frame.midY)
            
            self.imageView.isHidden = false
            self.imageView.frame = CGRect(x: 0, y: 0, width: layer.frame.width, height: layer.frame.height)
            self.imageView.center = CGPoint(x: layer.frame.midX, y: layer.frame.midY)
            
        }
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        var requestOptions:[VNImageOption : Any] = [:]
        
        if let camData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics:camData]
        }
        
        self.visionDelegate.performRequest(pixelBuffer: pixelBuffer, requestOptions: requestOptions)
    }
    
    // MARK: - Camera Setup
    
    func setupCamera() {
        
        self.previewView.session = session
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
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "buffer queue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil))
        videoOutput.alwaysDiscardsLateVideoFrames = true
        //videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        previewView.videoPreviewLayer.videoGravity = .resize
        session.startRunning()
        
    }
    
    private func auth() -> Bool {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authorizationStatus {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                    if granted {
                        DispatchQueue.main.async {
                            self.previewView.setNeedsDisplay()
                        }
                    }
                })
                return true
            case .authorized:
                return true
            case .denied, .restricted:
                return false
        }
    }
}
