//
//  PDFViewController.swift
//  ARKitPOC
//
//  Created by Mario Bragg on 1/4/18.
//  Copyright © 2018 Xevo. All rights reserved.
//

import UIKit
import PDFKit

class PDFViewController: UIViewController {
    
    var pdfView: PDFView?

    override func viewDidLoad() {
        super.viewDidLoad()

        pdfView = PDFView(frame: self.view.bounds)
        
        let url = Bundle.main.url(forResource: "manual", withExtension: "pdf")
        pdfView?.document = PDFDocument(url: url!)
        pdfView?.autoScales = true
        pdfView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.view.addSubview(pdfView!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Grab 10th page, returns optional if out of bounds
        if let page10 = pdfView?.document?.page(at: 257) {
            pdfView?.go(to: page10)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.layoutIfNeeded()
        self.pdfView?.layoutIfNeeded()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func donePressed(sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true) {
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
