//
//  TextViewController.swift
//  DashPOC
//
//  Created by Mario Bragg on 11/9/17.
//  Copyright © 2017 Xevo. All rights reserved.
//

import UIKit

class TextViewController: UIViewController {

    @IBOutlet weak var previewView: CameraView!
    @IBOutlet weak var charButton: UIButton!
    @IBOutlet weak var sentButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var textLinkButton: UIButton!
    
    var visionTextDelegate: VisionTextDelegate?
    var showCharBoxes = true
    var showSentBoxes = true
    var searchString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visionTextDelegate = VisionTextDelegate(controller: self, view: previewView)
        
        self.charButton.layer.cornerRadius = 15
        self.sentButton.layer.cornerRadius = 15
        self.textButton.layer.cornerRadius = 15
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.visionTextDelegate?.startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.visionTextDelegate?.stopSession()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    @IBAction func charButtonPressed(sender: UIButton) {
        self.showCharBoxes = !self.showCharBoxes
    }
    
    @IBAction func sentButtonPressed(sender: UIButton) {
        self.showSentBoxes = !self.showSentBoxes
    }
    
    func setTextLink(text: String) {
        
        if (text == self.searchString)
        {
            DispatchQueue.main.async {
                
                self.textLinkButton.isHidden = false
                self.textLinkButton.setTitle(text, for: .normal)
            }
        }
    }
    
    @IBAction func textLinkButtonPressed(sender: UIButton) {
        
        let string: NSString = "https://search.yahoo.com/search?p=brakes&fr=yfp-hrmob&fr2=p%3Afp%2Cm%3Asb&.tsrc=yfp-hrmob&fp=1&toggle=1&cop=mss&ei=UTF-8"
        let finalString = string.replacingOccurrences(of: "brakes", with: self.searchString)
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
    
    @IBAction func textButtonPressed(sender: UIButton) {
        
        let alertController = UIAlertController(title: nil, message: "Enter string to search", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Search", style: .default, handler: {
            alert -> Void in
            
            let textField = alertController.textFields![0] as UITextField
            
            if (textField.text == nil || textField.text == "")
            {
                self.searchString = ""
                self.visionTextDelegate?.currentSearchString = ""
            }
            else
            {
                self.searchString = textField.text!
                self.visionTextDelegate?.currentSearchString = textField.text!
            }
            
            self.visionTextDelegate?.ocrMatchFound = false
            self.textLinkButton.isHidden = true
            self.textLinkButton.setTitle("", for: .normal)
            
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            alert -> Void in
            
            self.searchString = ""
            self.visionTextDelegate?.currentSearchString = ""
        }))
        
        alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
            
            textField.keyboardType = UIKeyboardType.alphabet
            textField.placeholder = "Search Text"
        })
        
        self.present(alertController, animated: true) {
        }
    }

}
