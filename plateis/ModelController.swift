//
//  ModelController.swift
//  PLATEIS
//
//  Created by Markus Sprunck on 07/07/16.
//  Copyright © 2016 Markus Sprunck. All rights reserved.
//

import Foundation
import UIKit

class ModelController: NSObject {
    
    internal var allModels: [Model] = []

    internal var pageModels: [Model] = []
    
    public enum WorldKeys : String {
        case random01 = "World I", random02 = "World II", random03 = "World III", random04 = "World IV", random05 = "World V",random06 = "World VI", random07 = "World VII", random08 = "World VIII", random09 = "World IX", random10 = "World X"
        static let allValues = [random01, random02, random03, random04, random05, random06, random07, random08, random09, random10]
    }
    
    fileprivate var currentWorld : String = WorldKeys.random01.rawValue
    
    fileprivate var indexOfNextFreeLevel = 0
    
    fileprivate let MAX_NUMBER_OF_ROWS = 10
    
    fileprivate let MAX_NUMBER_OF_COLUMNS = 7

    override init() {
        super.init()
        
        if let savedMeals = loadPageModels() {
            print("Load stored worlds")
            allModels += savedMeals
        } else {
            let filepath = Bundle.main.path(forResource: "ModelDefault", ofType: "binary")
            if filepath != nil {
                allModels = (NSKeyedUnarchiver.unarchiveObject(withFile: filepath!) as? [Model])!
                print("Load \(allModels.count) default worlds from filepath=\(filepath ?? "not defined")")
            } else {
                print("File not found")
                var start_number : Int = 5
                for world in ModelController.WorldKeys.allValues {
                    print("Create default world \(world.rawValue)")
                    self.createModelRandomLevel(world.rawValue, start_number: start_number)
                    start_number += 2
                }
                
                for model in self.allModels {
                    var newSelected : [Node]
                    var newBest : Float
                    (newSelected, newBest)  = ModelSolver.run( model)
                    model.nodesSelectedBest = newSelected
                    print("Find best for world=\(model.world) model=\(model.name) best=\(newBest)")
                }

            }
        }
       
        selectModel(WorldKeys.random01.rawValue)
    }
    
    internal func findNextFreeLevel() {
        indexOfNextFreeLevel = 0
        let indexMax = pageModels.count
        var index = 0
        while index < indexMax {
            let model = pageModels[index]
            if model.isComplete() && indexOfNextFreeLevel == index{
                indexOfNextFreeLevel = index + 1
            }
            index += 1
        }
    }
    
    internal func getIndexOfNextFreeLevel() -> Int {
        return self.indexOfNextFreeLevel
    }
    
    internal func getCurrentWorld() -> String {
        return self.currentWorld
    }

    internal func selectModel(_ world : String) {
        print ("Select '\(world)'" )
        currentWorld = world
        pageModels.removeAll()
        for model in allModels {
            if model.world == world {
                pageModels.append(model)
            }
        }
    }
    
    internal func savePageModels() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(allModels, toFile: Model.ArchiveURL.path)
        if !isSuccessfulSave {
            print("   Failed to save models...")
        } else {
            print("   Succeeded to save models")
        }
    }
    
    fileprivate func loadPageModels() -> [Model]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Model.ArchiveURL.path) as? [Model]
    }
    
    
    internal func createModelRandomLevel(_ world : String, start_number : Int) {
        for index in 1...16 {
            let model = createModel(world,  name: String(index))
            for _ in 1...(start_number + index)  {
                model.getNode(getRandomIndex(model)).setActive(true)
            }
            allModels.append(model)
        }
    }
    
    fileprivate func getRandomIndex(_ model : Model) -> Int {
        var dice:Int = 0
        repeat {
            dice = Int(arc4random_uniform(70)) ;
        }  while model.getNode(dice).isActive()
        return dice
    }
    
  
    fileprivate func createModel(_ world: String, name: String) -> Model{
        let model1 = Model(world: world, name: name, rows: MAX_NUMBER_OF_ROWS, cols: MAX_NUMBER_OF_COLUMNS)
        var rowIndex : Int = 0
        while  ((rowIndex) <= MAX_NUMBER_OF_COLUMNS - 1) {
            var colIndex : Int = 0
            while  ((colIndex ) <= MAX_NUMBER_OF_ROWS - 1 ) {
                model1.addNode(Node(x:rowIndex, y:colIndex, active: false))
                colIndex = colIndex + 1
            }
            rowIndex = rowIndex + 1
        }
        return model1
    }
    
    fileprivate func copyActiveSettings(_ fromModel: Model, toModel: Model) {
        var index : Int = 0
        while index < MAX_NUMBER_OF_COLUMNS * MAX_NUMBER_OF_ROWS {
            toModel.getNode(index).setActive( fromModel.getNode(index).isActive() )
            index = index + 1
        }
    }

}

