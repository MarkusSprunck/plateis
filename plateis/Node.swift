//
//  Node.swift
//  PLATEIS
//
//  Copyright (c) 2016 Markus Sprunck. All rights reserved.
//

import UIKit

open class Node : NSObject, NSCoding {
    
    var x:Int!
    
    var y:Int!
    
    var active:Bool!
    
    public struct PropertyKey {
        static let xKey = "x"
        static let yKey = "y"
        static let activeKey = "active"
    }
    
    required convenience public init(coder aDecoder: NSCoder) {
        let x = aDecoder.decodeObject(forKey: PropertyKey.xKey) as! Int
        let y = aDecoder.decodeObject(forKey: PropertyKey.yKey) as! Int
        let active = aDecoder.decodeObject(forKey: PropertyKey.activeKey) as! Bool
        
        self.init(x: x, y: y, active: active)
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(x, forKey: PropertyKey.xKey)
        aCoder.encode(y, forKey: PropertyKey.yKey)
        aCoder.encode(active, forKey: PropertyKey.activeKey)
    }
    
    public init(x:Int, y:Int, active:Bool) {
        self.x = x
        self.y = y
        self.active = active
    }
    
    open func setActive(_ active : Bool) {
        self.active = active
    }
    
    open func isActive() -> Bool {
        return  self.active
    }
    
}
