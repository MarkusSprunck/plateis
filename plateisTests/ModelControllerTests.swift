//
//  ModelControllerTests.swift
//  PLATEISTests
//
//  Copyright (c) 2016 Markus Sprunck. All rights reserved.
//

import XCTest
@testable import PLATEIS

class ModelControllerTests: XCTestCase {
    
    
    let locToSave = "/Users/markus/git/plateis/plateis/ModelDefaultEasy.binary"
    
    let filepath = Bundle.main.path(forResource: "ModelDefaultEasy", ofType: "binary")

    let GENERATE_MODEL = false
    
    func test_Generate_Default_Models_and_Calculate_Best() {
        
        if GENERATE_MODEL {
        
            // Delete old config file
            do {
                let fileManager = FileManager.default
            
                try fileManager.removeItem(atPath: locToSave)
                print("Delete locToSave=\(locToSave)")
            
                if filepath != nil {
                    try fileManager.removeItem(atPath: filepath!)
                    print("Delete locToSave=\(filepath ?? "")")
                }
            }
            catch let error as NSError {
                print("\(error)")
            }
        
            let modelController : ModelController = ModelController()
            modelController.allModels.removeAll()
        
            print("Create default worlds")
            var start_number : Int = 0
            for world in ModelController.WorldKeys.allValues {
                print("Create default world \(world.rawValue)")
                modelController.createModelRandomLevel(world.rawValue, start_number: start_number)
                start_number += 1
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
            let data = NSKeyedUnarchiver.unarchiveObject(withFile: locToSave) as? [Model]
        
        
            // then
            XCTAssertNotNil(data)
            XCTAssertEqual(data!.count, 160)
        }
        
    }
    
    
    // Reset simulator before run of this test so that the new default model will be opened
    func test_Calculate_Best() {
        
        UserDefaults.standard.set(false, forKey: "expertMode")
        UserDefaults.standard.synchronize()
        
        let modelController : ModelController = ModelController()
        for trial in 1...1 {
            print("calculate best trial=\(trial)")
            for model in modelController.allModels {
                var newSelected : [Node]
                var newBest : Float
                (newSelected, newBest)  = ModelSolver.run( model )
          
                if model.getDistanceBest() > newBest {
                    print("   found a better solution for world=\(model.world) model=\(model.name) old=\(model.getDistanceBest()) new=\(newBest)")
                    model.nodesSelectedBest = newSelected
                   
                }
            }
        }
        print("Save best")
        NSKeyedArchiver.archiveRootObject(modelController.allModels, toFile: locToSave)
        
        let objects = NSKeyedUnarchiver.unarchiveObject(withFile: locToSave) as? [Model]
        assert(objects != nil)
        
    }

}
