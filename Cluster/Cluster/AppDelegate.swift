//
//  AppDelegate.swift
//  Cluster
//
//  Created by Mario Bragg on 11/30/17.
//  Copyright © 2017 Xevo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print("\(documentsPath)")
        
        setDefaultsFromSettingsBundle()
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        var viewController: ViewController?
        
        if (screenWidth == 1366 && screenHeight == 1024 ||
            screenWidth == 1024 && screenHeight == 1366)
        {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Cluster_129", bundle: nil)
            viewController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController
            viewController?.devicePrefix = "12_"
        }
        else
        {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Cluster_105", bundle: nil)
            viewController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController
            viewController?.devicePrefix = "10_"
        }
        
        self.window?.rootViewController = viewController
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func setDefaultsFromSettingsBundle() {
        
        //Read PreferenceSpecifiers from Root.plist in Settings.Bundle
        if let settingsURL = Bundle.main.url(forResource: "Root", withExtension: "plist", subdirectory: "Settings.bundle"),
            let settingsPlist = NSDictionary(contentsOf: settingsURL),
            let preferences = settingsPlist["PreferenceSpecifiers"] as? [NSDictionary] {
            
            for prefSpecification in preferences {
                
                if let key = prefSpecification["Key"] as? String, let value = prefSpecification["DefaultValue"] {
                    
                    //If key doesn't exists in userDefaults then register it, else keep original value
                    if UserDefaults.standard.value(forKey: key) == nil {
                        
                        UserDefaults.standard.set(value, forKey: key)
                        NSLog("registerDefaultsFromSettingsBundle: Set following to UserDefaults - (key: \(key), value: \(value), type: \(type(of: value)))")
                    }
                }
            }
        } else {
            NSLog("registerDefaultsFromSettingsBundle: Could not find Settings.bundle")
        }
    }

}

