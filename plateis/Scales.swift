//
//  Scaling.swift
//  PLATEIS
//
//  Created by Markus Sprunck on 10/09/16.
//  Copyright © 2016 Markus Sprunck. All rights reserved.
//

import SpriteKit

///
/// The class provides scaled values to render the grafic on all possible devices
///
class Scales {
    
    fileprivate static var initReady = false
    
    internal static func setSize(size : CGSize) {
        if !Scales.initReady {
            
            // Set size of screen
            width =  min(size.width, size.height)
            height = max(size.width, size.height)
            
            // iPhone 5s size
            let scaleX = width / 320.0
            let scaleY = height / 568.0
            let aspect = height  / width
            let scaleFactor = min( scaleX, scaleY)
            print("size aspect=\(aspect) width=\(width) height=\(height) scaleX=\(scaleX) scaleY=\(scaleY)")
            
            // Scale
            Scales.lineWidth *= scaleFactor
            Scales.scaleNodes = (aspect < 1.5) ? 0.04 : 0.06
            
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
            
            Scales.radiusLevel = Scales.width * 0.07
            Scales.radiusLargeX = (Scales.width -  Scales.left - Scales.right ) * 0.5 - radiusLevel
            Scales.radiusLargeY = (Scales.height -  Scales.top - Scales.bottom - Scales.bannerTop*2 - Scales.bannerBottom*2 ) * 0.5 - radiusLevel
            Scales.centerLarge  = CGPoint(x: Scales.width * 0.5 , y:radiusLargeY + Scales.bottom + Scales.bannerBottom*2 + radiusLevel)
            
            Scales.initReady = true
        }
    }
  
    // Default aspect ratio
    internal static var width : CGFloat = 320.0
    internal static var height : CGFloat = 568.0
    
    // Center of large circle of nodes in level scene
    internal static var centerLarge : CGPoint = CGPoint(x: 0.0, y: 0.0)
    internal static var radiusLevel : CGFloat = 0.0
    internal static var radiusLargeX : CGFloat = 0.0
    internal static var radiusLargeY : CGFloat = 0.0
    
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
