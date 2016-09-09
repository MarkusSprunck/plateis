//
//  Node.swift
//  PLATEIS
//
//  Created by Markus Sprunck on 09/07/16.
//  Copyright © 2016 Markus Sprunck. All rights reserved.
//

import UIKit

public class Node : NSObject, NSCoding {
    
    var x:Int!

    var y:Int!
    
    var active:Bool!
    
    public struct PropertyKey {
        static let xKey = "x"
        static let yKey = "y"
        static let activeKey = "active"
    }

    required convenience public init(coder aDecoder: NSCoder) {
        let x = aDecoder.decodeObjectForKey(PropertyKey.xKey) as! Int
        let y = aDecoder.decodeObjectForKey(PropertyKey.yKey) as! Int
        let active = aDecoder.decodeObjectForKey(PropertyKey.activeKey) as! Bool
        
        self.init(x: x, y: y, active: active)
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(x, forKey: PropertyKey.xKey)
        aCoder.encodeObject(y, forKey: PropertyKey.yKey)
        aCoder.encodeObject(active, forKey: PropertyKey.activeKey)
    }
    
    public init(x:Int, y:Int, active:Bool) {
        self.x = x
        self.y = y
        self.active = active
    }
    
    public func setActive(active : Bool) {
        self.active = active
    }
    
    public func isActive() -> Bool {
        return  self.active
    }
    
}
