//
//  VisionTextDelegate.swift
//  DashPOC
//
//  Created by Mario Bragg on 10/28/17.
//  Copyright © 2017 Xevo. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import VideoToolbox

class VisionTextDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    private let session = AVCaptureSession()
    weak var previewView: CameraView!
    
    weak var viewController: TextViewController?
    var requests = [VNRequest]()
    //let objectTrackDelegate = VisionObjectTrackDelegate()
    
    var pixelBuffer : CVPixelBuffer?
    var requestOptions:[VNImageOption : Any] = [:]
    
    let visionDispatchQueue = DispatchQueue(label: "com.xevo.visionDispatchQueue", qos: .userInitiated/*, attributes: .concurrent*/)
    let ocrDispatchQueue = DispatchQueue(label: "com.xevo.ocrDispatchQueue", qos: .userInitiated/*, attributes: .concurrent*/)
    var pixBuffImage: UIImage?
    var ciImage: CIImage?
    var uiImage: UIImage?
    var currentSearchString = ""
    var ocrPerforming = false
    var ocrMatchFound = false
    
    lazy var textRequest: VNDetectTextRectanglesRequest = {
        let textRequest = VNDetectTextRectanglesRequest(completionHandler: self.handleTextIdentification)
        textRequest.reportCharacterBoxes = true
        return textRequest
    }()
    
    init(controller: TextViewController, view: CameraView) {
        super.init()
        
        viewController = controller
        previewView = view
        //objectTrackDelegate.viewController = viewController
        requests = [self.textRequest]
        setupCamera()
    }
    
    func startSession() {
        session.startRunning()
        //processBuffer()
    }
    
    func stopSession() {
        session.stopRunning()
    }

    func processBuffer() {
        
        visionDispatchQueue.async {
            
            if (self.pixelBuffer != nil)
            {
                guard let pixBuffImage = UIImage(pixelBuffer: self.pixelBuffer!)
                    else {
                        fatalError("no image from video")
                }
                
                self.pixBuffImage = pixBuffImage
                self.ciImage = CIImage(cvPixelBuffer: self.pixelBuffer!)
                self.uiImage = pixBuffImage
                
                guard let image = self.uiImage else {
                    return
                }
                
                let imageRequestHandler = VNImageRequestHandler(cgImage: (image.cgImage)!, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: self.requestOptions)
                
                do {
                    try imageRequestHandler.perform(self.requests)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        
        if let camData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics:camData]
            self.requestOptions = [.cameraIntrinsics:camData]
        }
        
        self.pixelBuffer = pixBuffer
        self.processBuffer()
    }
    
    
    //MARK - Handle Vision Requests
    
    //var trackingEnabled = false
    //var ocrDispatchgroup = DispatchGroup()
    func handleTextIdentification (request: VNRequest, error: Error?) {
        
        guard let observations = request.results as? [VNTextObservation]
            else { print("unexpected result type from VNTextObservation")
                return
        }
        guard observations.first != nil else {
            return
        }
        
        /////////////////
        //if (!trackingEnabled)
        //{
        //    trackingEnabled = true
        //let box = observations[0]
        //print(box.boundingBox)
        //self.objectTrackDelegate.lastObservation = VNDetectedObjectObservation(boundingBox: (box.boundingBox))
        //self.objectTrackDelegate.trackRequest(pixBuffer: self.pixelBuffer!)
        //return
        //}
        
        //self.objectTrackDelegate.trackRequest(pixBuffer: self.pixelBuffer!)
        //return
        /////////////////
        
        let rotatedImage = self.imageRotatedByDegrees(oldImage: self.uiImage!, deg: 90)
        self.drawTextBoxes(observations: observations)
        
        self.ocrDispatchQueue.async {
            
                if (self.currentSearchString != "" && !self.ocrPerforming && !self.ocrMatchFound)
                {
                    self.ocrPerforming = true
    
                    if observations.count > 0 {
                        
                        //self.performImageRecognition(image: rotatedImage, rect: CGRect(origin: .zero, size: rotatedImage.size))
    
                        //let box = observations[0]
                        for box in observations {

                            let croppedImageOrigFrame = CGRect(origin: .zero, size: (rotatedImage.size))
                            let croppedImageCropSize = self.transformRect(fromRect: box.boundingBox, toViewRect: croppedImageOrigFrame)
                            let cropped = rotatedImage.crop(toRect: croppedImageCropSize)

                            let scaledImage = self.scaleImage(image: cropped!, maxDimension: 640)
                            self.performImageRecognition(image: scaledImage, rect: croppedImageCropSize)
                        }
                    }
                }
            }
    }
    
    func performImageRecognition(image: UIImage, rect: CGRect) {
        
        let tesseract = G8Tesseract()
        tesseract.language = "eng"
        tesseract.engineMode = .tesseractCubeCombined
        //tesseract.pageSegmentationMode = .auto
        tesseract.pageSegmentationMode = .singleWord
        tesseract.maximumRecognitionTime = 60.0
        tesseract.image = image.g8_blackAndWhite()
        tesseract.recognize()
        
        print("OCR: \(tesseract.recognizedText)")
        let text = tesseract.recognizedText.lowercased()
        
        if (text.range(of: self.currentSearchString.lowercased()) != nil)
        {
            self.ocrMatchFound = true
            DispatchQueue.main.async {
                self.viewController?.setTextLink(text: self.currentSearchString)
            }
        }
        else
        {
            self.ocrMatchFound = false
        }
        
        self.ocrPerforming = false
    }
    
    func drawTextBoxes(observations: [VNTextObservation]) {
        
        DispatchQueue.main.async {
            
            self.viewController?.view.layer.sublayers?.removeSubrange(1...)
            
            for box in observations {
                
                guard let chars = box.characterBoxes else {
                    print("no char values found")
                    return
                }
                
                if (self.viewController?.showSentBoxes)!
                {
                    let layer = self.createBoxView(withColor: UIColor.red)
                    layer.frame = self.transformRect(fromRect: box.boundingBox, toViewRect: (self.viewController?.view)!)
                    self.viewController?.view.layer.addSublayer(layer)
                }
                
                if (self.viewController?.showCharBoxes)!
                {
                    for char in chars
                    {
                        let charLayer = self.createBoxView(withColor: UIColor.green)
                        charLayer.frame = self.transformRect(fromRect: char.boundingBox, toViewRect: (self.viewController?.view)!)
                        self.viewController?.view.layer.addSublayer(charLayer)
                    }
                }
            }
        }
    }
    
    func createBoxView(withColor : UIColor) -> CALayer {
        
        let layer = CALayer()
        layer.borderColor = withColor.cgColor
        layer.borderWidth = 2
        return layer
    }
    
    //Convert Vision Frame to UIKit Frame
    func transformRect(fromRect: CGRect , toViewRect: UIView) -> CGRect {
        
        var toRect = CGRect()
        toRect.size.width = fromRect.size.width * toViewRect.frame.size.width
        toRect.size.height = fromRect.size.height * toViewRect.frame.size.height
        toRect.origin.y =  (toViewRect.frame.height) - (toViewRect.frame.height * fromRect.origin.y )
        toRect.origin.y  = toRect.origin.y -  toRect.size.height
        toRect.origin.x =  fromRect.origin.x * toViewRect.frame.size.width
        
        return toRect
    }
    
    func transformRect(fromRect: CGRect , toViewRect: CGRect) -> CGRect {
        
        var toRect = CGRect()
        toRect.size.width = fromRect.size.width * toViewRect.size.width
        toRect.size.height = fromRect.size.height * toViewRect.size.height
        toRect.origin.y =  (toViewRect.height) - (toViewRect.height * fromRect.origin.y )
        toRect.origin.y  = toRect.origin.y -  toRect.size.height
        toRect.origin.x =  fromRect.origin.x * toViewRect.size.width
        
        return toRect
    }
    
    func imageRotatedByDegrees(oldImage: UIImage, deg degrees: CGFloat) -> UIImage {
        
        //Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: oldImage.size.width, height: oldImage.size.height))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        
        //Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        
        //Rotate the image context
        bitmap.rotate(by: (degrees * CGFloat.pi / 180))
        
        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(oldImage.cgImage!, in: CGRect(x: -oldImage.size.width / 2, y: -oldImage.size.height / 2, width: oldImage.size.width, height: oldImage.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        var scaleFactor:CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.draw(in: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
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
        //        session.startRunning()
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

extension UIImage
{
    /**
     Creates a new UIImage from a CVPixelBuffer.
     NOTE: This only works for RGB pixel buffers, not for grayscale.
     */
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, nil, &cgImage)
        
        if let cgImage = cgImage {
            self.init(cgImage: cgImage)
        } else {
            return nil
        }
    }
    
    func crop(toRect: CGRect) -> UIImage? {
        
        let cgImage :CGImage! = self.cgImage
        if (cgImage == nil) {return nil}
        
        let croppedCGImage: CGImage! = cgImage.cropping(to: toRect)
        if (croppedCGImage == nil) {return nil}
        
        return UIImage(cgImage: croppedCGImage)
    }
}

