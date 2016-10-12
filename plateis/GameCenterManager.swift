//
//  GameCenterManager.swift
//  plateis
//
//  Created by Markus Sprunck on 11.10.16.
//  Copyright © 2016 Markus Sprunck. All rights reserved.
//


import GameKit

class GameCenterManager {
    
    // Stores the score
    public static var score: Int = 0
    
    public static func submitScore() {
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
    
    public static func calculateScore(models: [Model] ) {
        var numberModels = 0
        GameCenterManager.score = 0
        for model in models {
             if model.isComplete() {
                print("    calculateScore nodes=\(model.getActiveNodesCount()) hints=\(model.hints)")
                GameCenterManager.score +=  model.getActiveNodesCount()
                GameCenterManager.score -= model.hints
                numberModels += 1
            }
        }
        print("Score=\(GameCenterManager.score) of models \(numberModels)")
    }
    

}
