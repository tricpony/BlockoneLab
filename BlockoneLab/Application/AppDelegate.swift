//
//  AppDelegate.swift
//  BlockoneLab
//
//  Created by aarthur on 8/29/18.
//  Copyright © 2018 Gigabit LLC. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let sb: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootVC = sb.instantiateInitialViewController()
        
        self.window?.rootViewController = rootVC
        
        return true
    }
    
    // MARK: - Bundle Info
    
    func appDisplayName() -> String {
        let infoDictionary = Bundle.main.infoDictionary
        return infoDictionary!["CFBundleDisplayName"] as! String
    }
    
    func appID() -> String {
        let infoDictionary = Bundle.main.infoDictionary
        return infoDictionary!["CFBundleIdentifier"] as! String
    }
    
}

