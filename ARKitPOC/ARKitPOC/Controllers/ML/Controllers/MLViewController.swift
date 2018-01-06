//
//  MLViewController.swift
//  DashPOC
//
//  Created by Mario Bragg on 10/27/17.
//  Copyright © 2017 Xevo. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import PDFKit

class MLViewController: UIViewController {
    
    @IBOutlet weak var previewView: CameraView!
    @IBOutlet weak var indicatorView: IndicatorView!
    @IBOutlet weak var nextArrowView: UIView!
    
    var visionMLDelegate:VisionMLDelegate?
    weak var pageController: PageViewController?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visionMLDelegate = VisionMLDelegate(controller: self, view: previewView!)
        
        self.indicatorView.layer.borderWidth = 1.0
        self.indicatorView.layer.borderColor = UIColor.init(red: 255.0/255.0, green: 68.0/255.0, blue: 85.0/255.0, alpha: 0.5).cgColor
        
        let width = self.nextArrowView.bounds.size.width
        self.nextArrowView.layer.cornerRadius = width / 2.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.visionMLDelegate?.startMLRequestLoop()
        
        previewView.session?.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.visionMLDelegate?.stopMLRequestLoop()
        
        previewView.session?.stopRunning()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
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
            
            //resetView()
        }
    }
    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        
        layer.videoOrientation = orientation
        previewView.videoPreviewLayer.frame = self.view.bounds
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        let location = touches.first?.location(in: self.indicatorView)
        let inBounds = self.indicatorView.bounds.contains(location!)
        if (inBounds && self.indicatorView.alpha > 0)
        {
            self.oilSelected()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func nextPageSelected(sender: UIButton) {
        self.pageController?.moveToAR()
    }
    
    func oilSelected() {
        
        let alertController = UIAlertController(title: nil, message: "OIL LOW explanation from:", preferredStyle: .actionSheet)
        
        let videoAction = UIAlertAction(title: "Video", style: .default) { action in
            self.dismiss(animated: true, completion: {
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.launchURL()
            })
        }
        alertController.addAction(videoAction)
        
        let pdfAction = UIAlertAction(title: "Owner's Manual", style: .default) { action in
            self.dismiss(animated: true, completion: {
            })
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.openPDF()
            })
        }
        alertController.addAction(pdfAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            self.dismiss(animated: true, completion: {
            })
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true) {
        }
    }
    
    private func launchURL() {
        
        //let string: NSString = "https://www.youtube.com/watch?v=OjfceD8jibY"
        let string = UserDefaults.standard.object(forKey: "OIL_URL")
        let url = URL(string: string as! String)
        print("\(url!)")

        if #available(iOS 10, *) {
            UIApplication.shared.open(url!, options: [:], completionHandler: {
                (success) in
            })
        } else {
            UIApplication.shared.openURL(url!)
        }
    }
    
    func openPDF() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navController = storyboard.instantiateViewController(withIdentifier: "PDFNavController") as! UINavigationController
        self.present(navController, animated: true) {
        }

    }
    
//    private func resetView() {
//
//        self.previewView.layer.sublayers?.removeSubrange(1...)
//        //frameAnalyzer.reset()
//        //self.overlayView.isHidden = true
//        //self.startTracking = false
//
//        //self.dashOverlay.frame = self.overlayView.bounds
//    }
    
}

class IndicatorView: UIView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        if (self.alpha > 0 && self.bounds.contains(point))
        {
            return self
        }

        return super.hitTest(point, with: event)
    }
}

