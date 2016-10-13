//
//  ModelSolver.swift
//  PLATEIS
//
//  Created by Markus Sprunck on 12/08/16.
//  Copyright © 2016 Markus Sprunck. All rights reserved.
//

// import Foundation
import UIKit

class ModelSolver {
    
    fileprivate static let VERBOSE = false
    
    // Number of steps for simulated annealing
    fileprivate static let STEPS = 25
    
    // Number of iterations per step and node
    fileprivate static let ITERATIONS = 50
    
    // Start temperature for simulated annealing
    fileprivate static let START_TEMPERATURE : Float = 2000.0
    
    // Select all active nodes from model
    fileprivate class func getActiveNodes(_ model : Model) -> [Node] {
        var activeNodes : [Node] = []
        for node in model.nodes {
            if node.isActive() {
                activeNodes.append(node)
            }
        }
        return activeNodes
    }
    
    // Find the shortest path between active nodes
    class func run(_ model : Model) -> ([Node], Float) {
        
        var activeNodes : [Node] = ModelSolver.getActiveNodes(model)
        
        print("Level \(model.getName())")
        if VERBOSE {
            print("step   better    worse rejected    const      cost   temperature")
            print("")
        }
        
        var currentCost = Model.getDistance(activeNodes)
        var bestCost    = currentCost
        
        for step in 1...STEPS {
            var status_const = 0
            var status_better = 0
            var status_worse = 0
            var status_rejected = 0
            
            let currenTemperature = START_TEMPERATURE / Float(step*step*step)
            
            for _ in 1...ITERATIONS*activeNodes.count {
                
                // swap two random nodes
                let firstIndex : Int = Int(arc4random_uniform(UInt32(activeNodes.count)))
                var secondIndex : Int = firstIndex
                repeat {
                    secondIndex = Int(arc4random_uniform(UInt32(activeNodes.count)))
                } while firstIndex == secondIndex
                (activeNodes[secondIndex], activeNodes[firstIndex] ) = (activeNodes[firstIndex], activeNodes[secondIndex] )
                
                // calculate cost
                let currentCostOLD = currentCost;
                currentCost = Model.getDistance(activeNodes)
                let temp = (bestCost - currentCost) / currenTemperature
                
                // decide if this change will be accepted
                if (currentCost > bestCost) {
                    if (temp > -15.0 && exp(temp) > Float(arc4random()) / Float(UINT32_MAX)) {
                        bestCost = currentCost
                        status_worse += 1
                    } else {
                        (activeNodes[firstIndex], activeNodes[secondIndex] ) = (activeNodes[secondIndex], activeNodes[firstIndex] )
                        status_rejected += 1;
                        currentCost = currentCostOLD
                    }
                } else if (currentCost < bestCost) {
                    bestCost = currentCost
                    status_better += 1
                } else {
                    status_const += 1;
                }
            }
            
            // log state of current step
            if VERBOSE {
                print("\(String(format: "%02d", step))     \(String(format: "%6d", status_better))   \(String(format: "%6d", status_worse))   \(String(format: "%6d", status_rejected))   \(String(format: "%6d", status_const))   \(bestCost)   \(currenTemperature)")
            }
        }
        
        return (activeNodes, bestCost)
    }
    
}
