//
//  ModelController.swift
//  PLATEIS
//
//  Copyright (c) 2016-2017 Markus Sprunck. All rights reserved.
//

import Foundation
import UIKit

class ModelController: NSObject {
    
    let FILE_NAME_DEFAULT_MODEL = UserDefaults.standard.bool(forKey: "expertMode") ? "ModelDefault" : "ModelDefaultEasy"
    
    var allModels: [Model] = []
    
    var pageModels: [Model] = []
    
    enum WorldKeys : String {
        case random01 = "World I", random02 = "World II", random03 = "World III", random04 = "World IV", random05 = "World V",random06 = "World VI", random07 = "World VII", random08 = "World VIII", random09 = "World IX", random10 = "World X"
        static let allValues = [random01, random02, random03, random04, random05, random06, random07, random08, random09, random10]
    }
    
    private var currentWorld : String = WorldKeys.random01.rawValue
    
    private var indexOfNextFreeLevel = 0
    
    private let MAX_NUMBER_OF_ROWS = 10
    
    private let MAX_NUMBER_OF_COLUMNS = 7
    
    override init() {
        super.init()
        loadModel()
    }
    
    
    func loadModel() {
        if let models = loadPageModels() {
            print("Load stored model \(models.count)")
            allModels = models
        } else {
            let filepath = Bundle.main.path(forResource: FILE_NAME_DEFAULT_MODEL, ofType: "binary")
            print("Load \(String(describing: filepath))")
            
            if filepath != nil {
                allModels = (NSKeyedUnarchiver.unarchiveObject(withFile: filepath!) as? [Model])!
                print("Load \(allModels.count) default worlds from filepath=\(filepath ?? "not defined")")
            }
        }
        
        selectModel(WorldKeys.random01.rawValue)
    }
    
    func findNextFreeLevel() {
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
    
    func getIndexOfNextFreeLevel() -> Int {
        return self.indexOfNextFreeLevel
    }
    
    func getCurrentWorld() -> String {
        return self.currentWorld
    }
    
    func selectModel(_ world : String) {
        print ("Select '\(world)'" )
        currentWorld = world
        pageModels.removeAll()
        for model in allModels {
            if model.world == world {
                pageModels.append(model)
            }
        }
    }
    
    func savePageModels() {
        let isSuccessfulSave:Bool!
        
        if UserDefaults.standard.bool(forKey: "expertMode") {
            isSuccessfulSave  = NSKeyedArchiver.archiveRootObject(allModels, toFile: Model.ArchiveURL.path)
        } else {
            isSuccessfulSave  = NSKeyedArchiver.archiveRootObject(allModels, toFile: Model.ArchiveURLEasy.path)
        }
        
        if !isSuccessfulSave {
            print("   Failed to save models...")
        } else {
            print("   Succeeded to save models")
        }
    }
    
    private func loadPageModels() -> [Model]? {
        if UserDefaults.standard.bool(forKey: "expertMode") {
            print("Load page model:\n\(Model.ArchiveURL.path)")
            return NSKeyedUnarchiver.unarchiveObject(withFile: Model.ArchiveURL.path) as? [Model]
        } else {
            print("Load page model:\n\(Model.ArchiveURLEasy.path)")
            return NSKeyedUnarchiver.unarchiveObject(withFile: Model.ArchiveURLEasy.path) as? [Model]
        }
    }
    
    
    func createModelRandomLevel(_ world : String, start_number : Int) {
        for index in 1...16 {
            let model = createModel(world,  name: String(index))
            let range = lround( 2.0 + Double(start_number) + sqrt( Double(index * 3 ) ) )
            for _ in 1...range  {
                model.getNode(getRandomIndex(model)).setActive(true)
            }
            allModels.append(model)
        }
    }
    
    private func getRandomIndex(_ model : Model) -> Int {
        var dice:Int = 0
        repeat {
            dice = Int(arc4random_uniform(70)) ;
        }  while model.getNode(dice).isActive()
        return dice
    }
    
    
    private func createModel(_ world: String, name: String) -> Model{
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
    
    private func copyActiveSettings(_ fromModel: Model, toModel: Model) {
        var index : Int = 0
        while index < MAX_NUMBER_OF_COLUMNS * MAX_NUMBER_OF_ROWS {
            toModel.getNode(index).setActive( fromModel.getNode(index).isActive() )
            index = index + 1
        }
    }
    
}

