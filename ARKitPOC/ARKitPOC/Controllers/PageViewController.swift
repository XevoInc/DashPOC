//
//  PageViewController.swift
//  DashPOC
//
//  Created by Mario Bragg on 11/11/17.
//  Copyright © 2017 Xevo. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController/*, UIPageViewControllerDataSource*/ {

    private var customControllers = [UIViewController]()
    private var pageControl = UIPageControl(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //dataSource = self
        
        let mlViewController =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MLViewController") as! MLViewController
        mlViewController.pageController = self
        let arViewController =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
        arViewController.pageController = self
        
        customControllers = [mlViewController, arViewController]
        
        setViewControllers([mlViewController], direction: .forward, animated: false, completion: nil)
        
        registerSettingsBundle()
        setupPageControl()
        NotificationCenter.default.addObserver(self, selector: #selector(defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    private func currentControllerIndex() -> Int {
        
        let controller = self.viewControllers![0]
        let index = self.customControllers.index(of: controller)
        return index!
    }
    
    private func setupPageControl() {
        
        pageControl.numberOfPages = customControllers.count
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = UIColor.init(red: 255.0/255.0, green: 68.0/255.0, blue: 85.0/255.0, alpha: 0.5)
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.35)
        
        let leading = NSLayoutConstraint(item: pageControl, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: pageControl, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: pageControl, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 10)
        
        view.insertSubview(pageControl, at: 0)
        view.bringSubview(toFront: pageControl)
        view.addConstraints([leading, trailing, bottom])
    }
    
    private func registerSettingsBundle() {
        let appDefaults = [String:AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
    
    @objc func defaultsChanged() {
        //Make any needed changes
    }
    
    @IBAction func moveToML() {
        let mlController = customControllers[0]
        setViewControllers([mlController], direction: .reverse, animated: true, completion: nil)
        pageControl.currentPage = 0
    }
    
    @IBAction func moveToAR() {
        
        let arController = customControllers[1]
        setViewControllers([arController], direction: .forward, animated: true, completion: nil)
        pageControl.currentPage = 1
    }
    
//    // MARK: - UIPageViewControllerDataSource
//
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//
//        let index = currentControllerIndex()
//        if (index == self.customControllers.count - 1)
//        {
//            return nil
//        }
//
//        return self.customControllers[index + 1]
//    }
//
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//
//        let index = currentControllerIndex()
//        if (index == 0)
//        {
//            return nil
//        }
//
//        return self.customControllers[index - 1]
//    }
}
