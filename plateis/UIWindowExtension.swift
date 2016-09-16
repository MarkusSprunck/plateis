//
//  UIWindowExtension.swift
//  plateis
//
//  Created by Markus Sprunck on 16/09/16.
//  Copyright © 2016 Markus Sprunck. All rights reserved.
//

import UIKit

public extension UIWindow {
    
    func capture() -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.frame.size, self.isOpaque, UIScreen.main.scale)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
