//
//  Node.swift
//  PLATEIS
//
//  Copyright (c) 2016-2017 Markus Sprunck. All rights reserved.
//

import UIKit

class Node : NSObject, NSCoding {
    
    internal var x:Int!
    
    internal var y:Int!
    
    internal var active:Bool!
    
    struct PropertyKey {
        static let xKey = "x"
        static let yKey = "y"
        static let activeKey = "active"
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(x, forKey: PropertyKey.xKey)
        aCoder.encode(y, forKey: PropertyKey.yKey)
        aCoder.encode(active, forKey: PropertyKey.activeKey)
    }
    
    func setActive(_ active : Bool) {
        self.active = active
    }
    
    func isActive() -> Bool {
        return  self.active
    }
    
    required convenience  init(coder aDecoder: NSCoder) {
        let x = aDecoder.decodeObject(forKey: PropertyKey.xKey) as! Int
        let y = aDecoder.decodeObject(forKey: PropertyKey.yKey) as! Int
        let active = aDecoder.decodeObject(forKey: PropertyKey.activeKey) as! Bool
        
        self.init(x: x, y: y, active: active)
    }
    
    init(x:Int, y:Int, active:Bool) {
        self.x = x
        self.y = y
        self.active = active
    }
    
    
}
