//
//  Model.swift
//  PLATEIS
//
//  Created by Markus Sprunck on 09/07/16.
//  Copyright © 2016 Markus Sprunck. All rights reserved.
//

import Foundation
import UIKit

public class Model : NSObject, NSCoding {
    
    var nodes : [Node] = []
    var nodesSelected : [Node] = []
    var nodesSelectedBest : [Node] = []
    var name : String
    var world : String
    var rows: Int
    var cols: Int
    var startTime: Double = 0
    var endTime: Double = 0
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    public static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("model")
    
    // MARK: Types
    public struct PropertyKey {
        static let worldKey = "world"
        static let nameKey = "name"
        static let nodesKey = "nodes"
        static let nodesSelectedKey = "nodesSelected"
        static let nodesSelectedBestKey = "nodesSelectedBest"
        static let rowsKey = "rows"
        static let colsKey = "cols"
    }
    
    // MARK: NSCoding
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(world, forKey: PropertyKey.worldKey)
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(nodes, forKey: PropertyKey.nodesKey)
        aCoder.encodeObject(nodesSelected, forKey: PropertyKey.nodesSelectedKey)
        aCoder.encodeObject(nodesSelectedBest, forKey: PropertyKey.nodesSelectedBestKey)
        aCoder.encodeInteger(rows, forKey: PropertyKey.rowsKey)
        aCoder.encodeInteger(cols, forKey: PropertyKey.colsKey)
    }

    public init?(nodes : [Node], nodesSelected : [Node], nodesSelectedBest : [Node], name : String, rows: Int, cols: Int, world : String) {
        // Initialize stored properties.
        self.nodes = nodes
        self.nodesSelected = nodesSelected
        self.nodesSelectedBest = nodesSelectedBest
        self.name = name
        self.world = world
        self.rows = rows
        self.cols = cols
    }
    
    required convenience public init?(coder aDecoder: NSCoder) {
        let nodes = aDecoder.decodeObjectForKey(PropertyKey.nodesKey) as! [Node]
        let nodesSelected = aDecoder.decodeObjectForKey(PropertyKey.nodesSelectedKey) as! [Node]
        let nodesSelectedBest = aDecoder.decodeObjectForKey( PropertyKey.nodesSelectedBestKey) as! [Node]
        let name = aDecoder.decodeObjectForKey( PropertyKey.nameKey) as! String
        let world = aDecoder.decodeObjectForKey( PropertyKey.worldKey) as! String
        let rows : Int = aDecoder.decodeIntegerForKey( PropertyKey.rowsKey)
        let cols : Int = aDecoder.decodeIntegerForKey( PropertyKey.colsKey)
    
        // Must call designated initializer.
        self.init(nodes: nodes, nodesSelected: nodesSelected, nodesSelectedBest: nodesSelectedBest, name: name, rows: rows, cols: cols, world: world)
    }
    
    public init(world: String, name : String, rows: Int, cols: Int) {
        self.world = world
        self.name = name
        self.rows = rows
        self.cols = cols
    }
    
    public func getName() -> String {
        return name
    }
    
    public func getRows() -> Int {
        return rows
    }
    
    public func getCols() -> Int {
        return cols
    }
    
    public func addNode(node:Node) {
        nodes.append(node)
    }
    
    public func selectNode(node:Node) {
        if !isSelected(node) {
            nodesSelected.append(node)
        }
        
        if nodesSelected.count == 1 {
            startTime = CFAbsoluteTimeGetCurrent() as Double
        } else if  nodesSelected.count == getActiveNodesCount() {
            endTime = CFAbsoluteTimeGetCurrent() as Double
        }
    }
    
    public func getDuration() -> Int {
        return  Int(endTime - startTime)
    }
    
    public func isSelected(node:Node) -> Bool {
        return  nodesSelected.contains(node)
    }
    
    public func isSelectedLast(node:Node) -> Bool {
        return  ((nodesSelected.count - 1)  == nodesSelected.indexOf(node)!)
    }
    
    public func undoLastSelected() {
        if nodesSelected.count == 1 {
             startTime = CFAbsoluteTimeGetCurrent() as Double
        }
        
        if !nodesSelected.isEmpty {
            nodesSelected.removeLast()
        }
    }
    
    public func undoAllSelected() {
        if !nodesSelected.isEmpty {
            nodesSelected.removeAll()
            startTime = CFAbsoluteTimeGetCurrent() as Double
        }
    }

    public func getNode(index : Int) -> Node {
        return nodes[index]
    }
    
    public func getNodeSelected(index : Int) -> Node {
        return nodesSelected[index]
    }
    
    public class func getDistance(selected : [Node]) -> Float {
        //if isReady() {
        var distance : Double = 0.0
        let numberOfSelected = selected.count
        if (numberOfSelected > 2) {
            for index in 0..<numberOfSelected {
                let first:Node = selected[index]
                let secondIndex = (index < numberOfSelected  - 1 ) ? index + 1 : 0
                let second:Node = selected[secondIndex]
                distance +=  sqrt( pow(Double(second.x - first.x), 2) + pow(Double(second.y - first.y), 2) )
            }
        }
        return Float(distance)
    }
    
    public func getDistanceBest() -> Float {
        return (self.nodesSelectedBest.isEmpty) ? Float.infinity : Model.getDistance(self.nodesSelectedBest)
    }
    
    public func getActiveNodesCount() -> Int {
        var activeCount = 0
        for object in nodes {
            if (object.isActive()) {
                activeCount += 1
            }
        }
        return activeCount
    }
    
    public func getSelectedCount() -> Int {
        return nodesSelected.count
    }
    
    public func getIndexOfSelected(node:Node) -> Int {
        return nodesSelected.indexOf(node)!
    }
    
    public func count() -> Int {
        return nodes.count
    }
    
    public func isReady() -> Bool {
        return ( getSelectedCount() == getActiveNodesCount() )
    }
    
    public func isComplete() -> Bool {
        return ( (Model.getDistance(self.nodesSelected) - getDistanceBest() <= (0.001)) && isReady() )
    }
    
    public func isIncomplete() -> Bool {
        return ( (Model.getDistance(self.nodesSelected) - getDistanceBest() > (0.001)) && isReady() )
    }
    
}
