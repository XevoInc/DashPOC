//
//  PageViewController.swift
//  DashPOC
//
//  Created by Mario Bragg on 11/11/17.
//  Copyright © 2017 Xevo. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource {

    var customControllers = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        
        let mlViewController =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MLViewController") as! MLViewController
        let textViewController =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TextViewController") as! TextViewController
        customControllers = [mlViewController, textViewController]
        
        setViewControllers([mlViewController], direction: .forward, animated: false, completion: nil)
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func currentControllerIndex() -> Int {
        
        let controller = self.viewControllers![0]
        let index = self.customControllers.index(of: controller)
        return index!
    }
    
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let index = currentControllerIndex()
        if (index == self.customControllers.count - 1)
        {
            return nil
        }
        
        return self.customControllers[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let index = currentControllerIndex()
        if (index == 0)
        {
            return nil
        }
        
        return self.customControllers[index - 1]
    }

}
