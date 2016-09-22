//
//  Scaling.swift
//  plateis
//
//  Created by Markus Sprunck on 10/09/16.
//  Copyright © 2016 Markus Sprunck. All rights reserved.
//

import SpriteKit


class Scales {
    
    fileprivate static var initReady = false
    
    internal static var width : CGFloat = 320.0

    internal static var height : CGFloat = 568.0

    internal static func setSize(_ size : CGSize) {
        
        
        if !Scales.initReady {
     
            Scales.size = size
            
            // Set size of screen
            width =  min(size.width, size.height)
            height = max(size.width, size.height)
            
            // iPhone 5s size is 320.0 x 568.0
            let scaleFactorX = width / 320.0
            let scaleFactorY = height / 568.0
            let aspectRatio = height  / width
            let scaleFactor = min( scaleFactorX, scaleFactorY)
            print("size aspectRatio=\(aspectRatio) width=\(width) height=\(height) scaleFactorX=\(scaleFactorX) scaleFactorY=\(scaleFactorY)" )
            
            // Scale 
            Scales.lineWidth *= scaleFactor
            
            Scales.scaleNodes = (aspectRatio < 1.5) ? 0.04 : 0.06
            
            Scales.top *= scaleFactor
            Scales.bottom *= scaleFactor
            Scales.left *= scaleFactor
            Scales.right *= scaleFactor
            
            Scales.scaleStars *= scaleFactor
            Scales.fontSizeLabel *= scaleFactor
  
            Scales.fontSizeButton *= scaleFactor
            Scales.buttonHeight *= scaleFactor
            Scales.buttonWidth *= scaleFactor
            
            Scales.bannerTop *= scaleFactor
            Scales.bannerBottom *= scaleFactor
            
            Scales.starDistance *= scaleFactor
            
            Scales.initReady = true
        }
        
    }
    
    // Not scaled size
    internal static var size : CGSize = CGSize()
 
    // Borders
    internal static var top : CGFloat = 15
    internal static var bottom : CGFloat = buttonHeight + 10
    internal static var left : CGFloat = 10
    internal static var right : CGFloat = 10
    
    // Labels
    internal static var scaleStars : CGFloat = 0.45
    internal static var fontSizeLabel : CGFloat = 20
    
    // Buttons
    internal static var fontSizeButton : CGFloat = 20
    internal static var buttonHeight : CGFloat = 34
    internal static var buttonWidth : CGFloat = 95
    
    // Distance between grafic and contol elements
    internal static var bannerTop : CGFloat = 30
    internal static var bannerBottom : CGFloat = 20
    
    // Size of nodes in game view
    internal static var scaleNodes : CGFloat = 0.06
    
    // Lines
    internal static var lineWidth : CGFloat = 2.0
    
    // Stars 
    internal static var starDistance : CGFloat = 30

 
}
