//
//  GameCenterManager.swift
//  PLATEIS
//
//  Copyright (c) 2016-2017 Markus Sprunck. All rights reserved.
//
//
//  The class helps to handle Game Center
// 

import GameKit

class GameCenterManager {
    
    private static var score: Int = 0
    
    static func calculateScore(models: [Model] ) {
        var numberModels = 0
        GameCenterManager.score = 0
        for model in models {
            if model.isComplete() {
                print("    calculateScore nodes=\(model.getActiveNodesCount()) hints=\(model.hints)")
                GameCenterManager.score +=  model.getActiveNodesCount()
                GameCenterManager.score -= (model.getActiveNodesCount() >= model.hints) ? model.hints : model.getActiveNodesCount()
                numberModels += 1
            }
        }
        print("Score=\(GameCenterManager.score) of models \(numberModels)")
    }
    
    static func submitScore() {
        let leaderboardID = "leaderboardID"
        let sScore = GKScore(leaderboardIdentifier: leaderboardID)
        sScore.value = Int64(GameCenterManager.score)
        
        GKScore.report([sScore]) {(error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Score \(GameCenterManager.score) submitted")
            }
        }
    }
    
}
