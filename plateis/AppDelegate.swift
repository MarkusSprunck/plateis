//
//  AppDelegate.swift
//  PLATEIS
//
//  Copyright (c) 2016-2017 Markus Sprunck. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    internal var window: UIWindow?
    
    func applicationWillResignActive(_ application: UIApplication) {
        storeModel()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        storeModel()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        storeModel()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // nothing to do here
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        storeModel()
    }
    
    func storeModel() {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let viewController : DataViewController
        viewController = storyboard.instantiateViewController(withIdentifier: "PlateisId") as! DataViewController
        viewController.modelController.savePageModels()
    }
    
}

