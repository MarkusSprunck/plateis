//
//  Scales.swift
//  PLATEIS
//
//  Copyright (c) 2016-2017 Markus Sprunck. All rights reserved.
//
//
//  The class provides scaled values to render the grafic on all possible devices
// 

import SpriteKit

class Scales {
    
    private static var initReady = false
    
    static func setSize(size : CGSize) {
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
    static var width : CGFloat = 320.0
    static var height : CGFloat = 568.0
    
    // Center of large circle of nodes in level scene
    static var centerLarge : CGPoint = CGPoint(x: 0.0, y: 0.0)
    static var radiusLevel : CGFloat = 0.0
    static var radiusLargeX : CGFloat = 0.0
    static var radiusLargeY : CGFloat = 0.0
    
    // Borders
    static var top : CGFloat = 15
    static var bottom : CGFloat = buttonHeight + 10
    static var left : CGFloat = 10
    static var right : CGFloat = 10
    
    // Labels
    static var scaleStars : CGFloat = 0.45
    static var fontSizeLabel : CGFloat = 20
    
    // Buttons
    static var fontSizeButton : CGFloat = 20
    static var buttonHeight : CGFloat = 34
    static var buttonWidth : CGFloat = 95
    
    // Distance between grafic and contol elements
    static var bannerTop : CGFloat = 30
    static var bannerBottom : CGFloat = 20
    
    // Size of nodes in game view
    static var scaleNodes : CGFloat = 0.06
    
    // Lines
    static var lineWidth : CGFloat = 2.0
    
    // Stars
    static var starDistance : CGFloat = 30
    
}
