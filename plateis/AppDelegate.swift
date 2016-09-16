//
//  AppDelegate.swift
//  plateis
//
//  Created by Markus Sprunck on 23/07/16.
//  Copyright © 2016 Markus Sprunck. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        storeModel()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        storeModel()
    }
    
    func storeModel() {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let viewController : DataViewController = storyboard.instantiateViewController(withIdentifier: "PlateisId") as! DataViewController
        viewController.modelController.savePageModels()
    }
  
}

