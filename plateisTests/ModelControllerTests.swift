//
//  ModelTests.swift
//  PLATEISTests
//
//  Created by Markus Sprunck on 07/07/16.
//  Copyright © 2016 Markus Sprunck. All rights reserved.
//

import XCTest
@testable import PLATEIS

class ModelControllerTests: XCTestCase {
    
    let generate = false
    
    func test_Generate_Default_Models_and_Calculate_Best() {
        
        if generate {
        
            // Delete old config file
            let locToSave = "/Users/markus/git/plateis/plateis/ModelDefault.binary"
            let filepath = NSBundle.mainBundle().pathForResource("ModelDefault", ofType: "binary")

            do {
                let fileManager = NSFileManager.defaultManager()
            
                try fileManager.removeItemAtPath(locToSave)
                print("Delete locToSave=\(locToSave)")
            
                if filepath != nil {
                    try fileManager.removeItemAtPath(filepath!)
                    print("Delete locToSave=\(filepath)")
                }
            }
            catch let error as NSError {
                print("\(error)")
            }
        
            let modelController : ModelController = ModelController()
            modelController.allModels.removeAll()
        
            print("Create default worlds")
            var start_number : Int = 5
            for world in ModelController.WorldKeys.allValues {
                print("Create default world \(world.rawValue)")
                modelController.createModelRandomLevel(world.rawValue, start_number: start_number)
                start_number += 2
            }
        
            for model in modelController.allModels {
                var newSelected : [Node]
                var newBest : Float
                (newSelected, newBest)  = ModelSolver.run( model)
                model.nodesSelectedBest = newSelected
                print("Find best for world=\(model.world) model=\(model.name) best=\(newBest)")
            }
        
            // when
            print("locToSave=\(locToSave)")
            NSKeyedArchiver.archiveRootObject(modelController.allModels, toFile: locToSave)
            let data = NSKeyedUnarchiver.unarchiveObjectWithFile(locToSave) as? [Model]
        
        
            // then
            XCTAssertNotNil(data)
            XCTAssertEqual(data!.count, 160)
        }
        
    }
    
    func test_Calculate_Best() {
        
        let modelController : ModelController = ModelController()
        for trial in 1...100 {
            print("Calculate_Best trial=\(trial)")
            for model in modelController.allModels {
                var newSelected : [Node]
                var newBest : Float
                (newSelected, newBest)  = ModelSolver.run( model )
          
                if model.getDistanceBest() > newBest {
                    print("   found a better solution for world=\(model.world) model=\(model.name) old=\(model.getDistanceBest()) new=\(newBest)")
                    model.nodesSelectedBest = newSelected
                
                    let locToSave = "/Users/markus/git/plateis/plateis/ModelDefault.binary"
                    NSKeyedArchiver.archiveRootObject(modelController.allModels, toFile: locToSave)
                    NSKeyedUnarchiver.unarchiveObjectWithFile(locToSave) as? [Model]
                }
            }
        }
    }

}
