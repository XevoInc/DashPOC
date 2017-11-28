//
//  ViewController.swift
//  DashPOC3
//
//  Created by Mario Bragg on 11/27/17.
//  Copyright © 2017 Xevo. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class ViewController: UIViewController, ARSCNViewDelegate, VisionUIDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    private let dispatchQueueML = DispatchQueue(label: "dispatchQueue")
    private let visionDelegate = VisionDelegate()
    private let visionSequenceHandler = VNSequenceRequestHandler()
    private var imageSet = false
    private var imageNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        visionDelegate.visionUIDelegate = self
        
        sceneView.delegate = self
        //sceneView.showsStatistics = true
        
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(gestureRecognize:)))
        view.addGestureRecognizer(tapGesture)
        
        // Begin Loop to Update CoreML
        //loopCoreMLUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneView.frame = self.view.bounds
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }

    @objc func handleTap(gestureRecognize: UITapGestureRecognizer) {
        
        self.sceneView.layer.sublayers?.removeSubrange(0...)
        
        if (self.imageSet)
        {
            self.imageSet = false
            imageNode?.removeFromParentNode()
            imageNode = nil
        }
        else
        {
            self.imageSet = true
            
            // HIT TEST : REAL WORLD
            // Get Screen Centre
            let screenCentre : CGPoint = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY)
            
            let arHitTestResults : [ARHitTestResult] = sceneView.hitTest(screenCentre, types: [.featurePoint]) // Alternatively, we could use '.existingPlaneUsingExtent' for more grounded hit-test-points.
            
            if let closestResult = arHitTestResults.first {
                // Get Coordinates of HitTest
                let transform : matrix_float4x4 = closestResult.worldTransform
                let worldCoord : SCNVector3 = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
                
                let box = SCNBox(width: 0.20, height: 0.15, length: 0.001, chamferRadius: 0)
                let material = SCNMaterial()
                material.diffuse.contents = UIImage(named: "bmw@3x.JPG")
                box.materials = [material]
                imageNode = SCNNode(geometry: box)
                imageNode?.opacity = 0.9
                
                //imageNode?.position = SCNVector3(0, 0, -0.5)
                sceneView.scene.rootNode.addChildNode(imageNode!)
                imageNode?.position = worldCoord
                print(worldCoord)
            }
        }
    }
    
//    func loopCoreMLUpdate() {
//        // Continuously run CoreML whenever it's ready. (Preventing 'hiccups' in Frame Rate)
//
//        dispatchQueueML.async {
//
//            // 1. Run Update.
//            self.updateCoreML()
//
//            // 2. Loop this function.
//            self.loopCoreMLUpdate()
//        }
//    }
//
//    func updateCoreML() {
//
//        let pixelBuffer : CVPixelBuffer? = (sceneView.session.currentFrame?.capturedImage)
//        if pixelBuffer == nil { return }
//
//        self.visionDelegate.performRequest(pixelBuffer: pixelBuffer!, requestOptions: [:])
//    }
    
    // MARK: - ARSCNViewDelegate
    var lastRectObservation: VNRectangleObservation?
    var lastFrame: CGRect?
    
    func updateUI(box: VNRectangleObservation) {

        DispatchQueue.main.async {
            
            self.sceneView.layer.sublayers?.removeSubrange(0...)
            
            if (self.imageSet) {return}
            
            let xCoord = box.topLeft.x * self.sceneView.frame.size.width
            let yCoord = (1 - box.topLeft.y) * self.sceneView.frame.size.height
            let width = (box.topRight.x - box.bottomLeft.x) * self.sceneView.frame.size.width
            let height = (box.topLeft.y - box.bottomLeft.y) * self.sceneView.frame.size.height
            
            let frame = CGRect(x: xCoord, y: yCoord, width: width, height: height)
            
            //print("box width: \(box.topRight.x - box.topLeft.x)")
            //print("width: \(width) height: \(height)")
            
            let layer = CALayer()
            layer.frame = frame
            layer.borderWidth = 1.0
            layer.borderColor = UIColor.blue.cgColor
            
            self.sceneView.layer.addSublayer(layer)
            
            self.lastRectObservation = box
            self.lastFrame = frame
        }
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        if (!self.imageSet)
        {
            let pixelBuffer : CVPixelBuffer? = (sceneView.session.currentFrame?.capturedImage)
            if pixelBuffer == nil { return }
            
            self.visionDelegate.performRequest(pixelBuffer: pixelBuffer!, requestOptions: [:])
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

