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
        //sceneView.showsFPS = true
        //sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
            scene.scaleMode = .resizeFill
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
                
                if (name == "oil") {
                    launchURL(name: node.name!)
                }
//                else if (name == "gas") {
//                    launchURL(name: node.name!)
//                }
//                else if (name == "belt") {
//                    launchURL(name: node.name!)
//                }
            }
        }
        else
        {
            return
        }
    }
    
    func launchURL(name: String) {
        
        let string: NSString = "https://www.youtube.com/watch?v=OjfceD8jibY"
        //let finalString = string.replacingOccurrences(of: "brakes", with: name)
        let url = URL(string: string as String)
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
            dashNode = SKSpriteNode(imageNamed: "cluster_on_small")
            dashNode?.alpha = 1.0
            dashNode?.name = "cluster"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                
                self.dashNode?.texture = SKTexture(imageNamed: "cluster_on_oil_small")
//                let oilNode = SKSpriteNode(imageNamed: "ic_indicator_oil_on_small")
//                oilNode.alpha = 1.0
//                oilNode.name = "cluster_oil_on"
//                oilNode.position = CGPoint(x: -38, y: -30)
//                self.dashNode?.addChild(oilNode)
            })
            
            
//            let gas = SKShapeNode(circleOfRadius: 9 )
//            gas.position = CGPoint(x: -71, y: -10)
//            gas.strokeColor = SKColor.green
//            gas.glowWidth = 3.0
//            gas.fillColor = SKColor.green
//            gas.name = "gas"
//            dashNode?.addChild(gas)
//
//            let oil = SKShapeNode(circleOfRadius: 9 )
//            oil.position = CGPoint(x: 67, y: -9)
//            oil.strokeColor = SKColor.green
//            oil.glowWidth = 3.0
//            oil.fillColor = SKColor.green
//            oil.name = "oil"
//            dashNode?.addChild(oil)
//
            let oil = SKShapeNode(rectOf: CGSize(width: 38, height: 38))
            oil.position = CGPoint(x: -38, y: -37)
            oil.strokeColor = SKColor.clear
            oil.glowWidth = 1.0
            oil.fillColor = SKColor.clear
            oil.name = "oil"
            dashNode?.addChild(oil)
            
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
