//
//  Model.swift
//  PLATEIS
//
//  Copyright (c) 2016-2017 Markus Sprunck. All rights reserved.
//

import Foundation
import UIKit

class Model : NSObject, NSCoding {
 
    var name : String
   
    var world : String
    
    var nodes : [Node] = []
    
    var nodesSelected : [Node] = []
    
    var nodesSelectedBest : [Node] = []
    
    var rows: Int
    
    var cols: Int
    
    var hints : Int = 0
    
    // Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("model")
    static let ArchiveURLEasy = DocumentsDirectory.appendingPathComponent("modelEasy")
    
    // Types
    struct PropertyKey {
        static let worldKey = "world"
        static let nameKey = "name"
        static let nodesKey = "nodes"
        static let nodesSelectedKey = "nodesSelected"
        static let nodesSelectedBestKey = "nodesSelectedBest"
        static let rowsKey = "rows"
        static let colsKey = "cols"
        static let hintsKey = "hints"
    }
    
    // NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(world, forKey: PropertyKey.worldKey)
        aCoder.encode(name, forKey: PropertyKey.nameKey)
        aCoder.encode(nodes, forKey: PropertyKey.nodesKey)
        aCoder.encode(nodesSelected, forKey: PropertyKey.nodesSelectedKey)
        aCoder.encode(nodesSelectedBest, forKey: PropertyKey.nodesSelectedBestKey)
        aCoder.encode(rows, forKey: PropertyKey.rowsKey)
        aCoder.encode(cols, forKey: PropertyKey.colsKey)
        aCoder.encode(hints, forKey: PropertyKey.hintsKey)
    }
    
    func getName() -> String {
        return name
    }
    
    func getRows() -> Int {
        return rows
    }
    
    func getCols() -> Int {
        return cols
    }
    
    func addNode(_ node:Node) {
        nodes.append(node)
    }
    
    func selectNode(_ node:Node) {
        if !isSelected(node) {
            nodesSelected.append(node)
        }
    }
    
    func isSelected(_ node:Node) -> Bool {
        return  nodesSelected.contains(node)
    }
    
    func isSelectedLast(_ node:Node) -> Bool {
        return  ((nodesSelected.count - 1)  == nodesSelected.index(of: node)!)
    }
    
    func undoLastSelected() {
        if !nodesSelected.isEmpty {
            nodesSelected.removeLast()
        }
    }
    
    func undoAllSelected() {
        if !nodesSelected.isEmpty {
            nodesSelected.removeAll()
        }
    }
    
    func getNode(_ index : Int) -> Node {
        return nodes[index]
    }
    
    func getNodeSelected(_ index : Int) -> Node {
        return nodesSelected[index]
    }
    
    class func getDistance(_ selected : [Node]) -> Float {
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
    
    func getDistanceBest() -> Float {
        return (self.nodesSelectedBest.isEmpty) ? Float.infinity : Model.getDistance(self.nodesSelectedBest)
    }
    
    func getActiveNodesCount() -> Int {
        var activeCount = 0
        for object in nodes {
            if (object.isActive()) {
                activeCount += 1
            }
        }
        return activeCount
    }
    
    func getSelectedCount() -> Int {
        return nodesSelected.count
    }
    
    func getIndexOfSelected(_ node:Node) -> Int {
        return nodesSelected.index(of: node)!
    }
    
    func count() -> Int {
        return nodes.count
    }
    
    func isReady() -> Bool {
        return ( getSelectedCount() == getActiveNodesCount() )
    }
    
    func isComplete() -> Bool {
        return ( (Model.getDistance(self.nodesSelected) - getDistanceBest() <= (0.001)) && isReady() )
    }
    
    func isIncomplete() -> Bool {
        return ( (Model.getDistance(self.nodesSelected) - getDistanceBest() > (0.001)) && isReady() )
    }
    
    init?(nodes : [Node], nodesSelected : [Node], nodesSelectedBest : [Node], name : String, rows: Int, cols: Int, world : String, hints : Int) {
        self.nodes = nodes
        self.nodesSelected = nodesSelected
        self.nodesSelectedBest = nodesSelectedBest
        self.name = name
        self.world = world
        self.rows = rows
        self.cols = cols
        self.hints = hints
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let nodes = aDecoder.decodeObject(forKey: PropertyKey.nodesKey) as! [Node]
        let nodesSelected = aDecoder.decodeObject(forKey: PropertyKey.nodesSelectedKey) as! [Node]
        let nodesSelectedBest = aDecoder.decodeObject( forKey: PropertyKey.nodesSelectedBestKey) as! [Node]
        let name = aDecoder.decodeObject( forKey: PropertyKey.nameKey) as! String
        let world = aDecoder.decodeObject( forKey: PropertyKey.worldKey) as! String
        let rows : Int = aDecoder.decodeInteger( forKey: PropertyKey.rowsKey)
        let cols : Int = aDecoder.decodeInteger( forKey: PropertyKey.colsKey)
        let hints : Int = aDecoder.decodeInteger( forKey: PropertyKey.hintsKey)
        
        // Must call designated initializer.
        self.init(nodes: nodes, nodesSelected: nodesSelected, nodesSelectedBest: nodesSelectedBest, name: name, rows: rows, cols: cols, world: world, hints: hints)
    }
    
    init(world: String, name : String, rows: Int, cols: Int) {
        self.world = world
        self.name = name
        self.rows = rows
        self.cols = cols
    }
    
}
