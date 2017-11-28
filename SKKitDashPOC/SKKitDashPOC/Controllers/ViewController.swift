//
//  ViewController.swift
//  SKKitDashPOC
//
//  Created by Mario Bragg on 11/28/17.
//  Copyright © 2017 Xevo. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit

class ViewController: UIViewController, ARSKViewDelegate {
    
    @IBOutlet var sceneView: ARSKView!
    
    private var dashLoaded = false
    private var dashNode : SKSpriteNode?
    private var cinemaFrame: ARFrame?
    private var frameView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
        
        frameView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 400, height: 300)))
        frameView?.backgroundColor = UIColor.clear
        frameView?.layer.borderWidth = 1.0
        frameView?.layer.borderColor = UIColor.red.cgColor
        frameView?.center = sceneView.center
        
        sceneView.addSubview(frameView!)
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
        frameView?.center = sceneView.center
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (!self.dashLoaded) {
            self.createDashAnchor()
            self.frameView?.removeFromSuperview()
        }
        
        // Get first touch
        guard let touch = touches.first else {
            return
        }

        // Get location in the scene
        let location = touch.location(in: self.sceneView.scene!)
        
        // Get the nodes at the clicked location
        let clicked = self.sceneView.scene!.nodes(at: location)
        
        // Get the first clicked node
        if let node = clicked.first {
            
            if let name = node.name {
                
                if (name == "gas") {
                    launchURL(name: node.name!)
                }
                else if (name == "oil") {
                    launchURL(name: node.name!)
                }
                else if (name == "belt") {
                    launchURL(name: node.name!)
                }
            }
        }
        else
        {
            return
        }
    }
    
    func launchURL(name: String) {
        
        let string: NSString = "https://search.yahoo.com/search?p=brakes&fr=yfp-hrmob&fr2=p%3Afp%2Cm%3Asb&.tsrc=yfp-hrmob&fp=1&toggle=1&cop=mss&ei=UTF-8"
        let finalString = string.replacingOccurrences(of: "brakes", with: name)
        let url = URL(string: finalString)
        print("\(url!)")
        
        if #available(iOS 10, *) {
            UIApplication.shared.open(url!, options: [:], completionHandler: {
                (success) in
            })
        } else {
            UIApplication.shared.openURL(url!)
        }
    }
    
    // MARK: - ARSKViewDelegate
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        
        if (!self.dashLoaded) {
            
            //Create dash noce
            dashNode = SKSpriteNode(imageNamed: "bmw@3x.JPG")
            dashNode?.alpha = 0.8
            
            let gas = SKShapeNode(circleOfRadius: 9 )
            gas.position = CGPoint(x: -71, y: -10)
            gas.strokeColor = SKColor.clear
            gas.glowWidth = 1.0
            gas.fillColor = SKColor.clear
            gas.name = "gas"
            dashNode?.addChild(gas)
            
            let oil = SKShapeNode(circleOfRadius: 9 )
            oil.position = CGPoint(x: 67, y: -9)
            oil.strokeColor = SKColor.clear
            oil.glowWidth = 1.0
            oil.fillColor = SKColor.clear
            oil.name = "oil"
            dashNode?.addChild(oil)
            
            let seatBelt = SKShapeNode(rectOf: CGSize(width: 4, height: 6))
            seatBelt.position = CGPoint(x: 63, y: -24)
            seatBelt.strokeColor = SKColor.clear
            seatBelt.glowWidth = 1.0
            seatBelt.fillColor = SKColor.clear
            seatBelt.name = "seatbelt"
            dashNode?.addChild(seatBelt)
            
            self.dashLoaded = true
            return dashNode
        }
        
        return nil
    }
    
    func createDashAnchor(){
        
        guard let sceneView = self.view as? ARSKView else {
            return
        }

        // Create anchor using the camera's current position
        if let currentFrame = sceneView.session.currentFrame {

            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.7
            let transform = simd_mul(currentFrame.camera.transform, translation)

            // Add a new anchor to the session
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
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
