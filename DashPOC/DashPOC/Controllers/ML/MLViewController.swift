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

class MLViewController: UIViewController {

    @IBOutlet weak var previewView: CameraView!
    @IBOutlet weak var textView: UITextView!
    var visionMLDelegate:VisionMLDelegate?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visionMLDelegate = VisionMLDelegate(controller: self, view: previewView!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.visionMLDelegate?.startMLRequestLoop()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.visionMLDelegate?.stopMLRequestLoop()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
}
