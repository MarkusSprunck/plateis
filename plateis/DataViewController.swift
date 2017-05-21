//
//  DataViewController.swift
//  PLATEIS
//
//  Copyright (c) 2016-2017 Markus Sprunck. All rights reserved.
//
//
//  The class is the central view controller which managages all scenes
//

import UIKit
import SpriteKit
import StoreKit
import Foundation
import GameKit

class DataViewController: UIViewController , GKGameCenterControllerDelegate {
    
    // Stores if the user has Game Center enabled
    var gcEnabled = Bool()
    
    // Stores the default leaderboardID
    var gcDefaultLeaderBoard = String()
    
    // Create just one instance of model controller
    var modelController : ModelController {
        get {
            if DataViewController._modelController == nil {
                DataViewController._modelController = ModelController()
            }
            return DataViewController._modelController!
        }
    }
    
    var sceneLevel: LevelScene!
    
    var sceneGame:  GameScene!
    
    private static var  _modelController : ModelController? = nil
    
    private var sceneStart: StartScene!
    
    private var indexOfActiveModel : Int = 0;
    
    private var isInSwipe:Bool = false
    
    private var products : [SKProduct] = []
    
    private var skview: SKView!
    
    private var timeLastScroll = NSDate().timeIntervalSince1970
    
    private func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1 Show login if player is not logged in
                self.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2 Player is already euthenticated & logged in, load game center
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler:
                    { (leaderboardIdentifer: String?, error: Error?) -> Void in
                        if error != nil {
                            print("\(error.debugDescription)")
                        } else {
                            self.gcDefaultLeaderBoard = leaderboardIdentifer!
                        }
                }
                )
            } else {
                // 3 Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated, disabling game center")
            }
        }
    }
    
    private  func addPan() {
        let panGesture = UIPanGestureRecognizer(target: self, action:(#selector(DataViewController.handlePanGesture(_:))))
        self.view.addGestureRecognizer(panGesture)
    }
    
    func actionStart() {
        sceneStart.hide()
        sceneGame.hideElements()
        skview.presentScene(sceneLevel)
        sceneLevel.showButtons()
        modelController.findNextFreeLevel()
        sceneLevel.setSelectedModel(modelController.getIndexOfNextFreeLevel())
        rotateToNextModel()
        sceneLevel.updateScene()
        authenticateLocalPlayer()
    }
    
    func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: view)
        panGesture.setTranslation(CGPoint.zero, in: view)
        if panGesture.state == UIGestureRecognizerState.changed && sceneGame.isGameVisible() {
            
            // it must be significant translation
            if abs(translation.x) < 10 {
                return
            }
            
            // manage a waiting time to avoid to skip levels
            let timeCurrentScroll = NSDate().timeIntervalSince1970
            if timeCurrentScroll - timeLastScroll < 0.25 {
                return
            }
            timeLastScroll = timeCurrentScroll
            
            // calculate index of new level
            var index : Int = Int(sceneGame.getModelName())! - 1
            if (translation.x < 0) {
                index = min(index + 1, 15)
                print("next     level...\(index)  \(translation.x)  \(panGesture.numberOfTouches)")
                
            }
            if translation.x > 0  {
                index = max(index - 1, 0)
                print("previous level...\(index)  \(translation.x)  \(panGesture.numberOfTouches)")
            }
            
            // change level
            modelController.findNextFreeLevel()
            actionOpenGame(index)
            return
        }
        
        if panGesture.state == UIGestureRecognizerState.changed && panGesture.numberOfTouches == 1 {
            
            let point: CGPoint = panGesture.location(in: self.view)
            let center = Scales.centerLarge
            let deltaX1 = point.x - center.x
            let deltaY1 = point.y - center.y
            let m1      = deltaY1 / deltaX1
            
            let deltaX2 = deltaX1 - translation.x
            let deltaY2 = deltaY1 - translation.y
            let m2      = deltaY2 / deltaX2
            
            let centerDistance = sqrt(deltaX1*deltaX1 + deltaY1*deltaY1)
            if centerDistance < 60 {
                return
            }
            
            let deltaGamma:CGFloat = atan( (m1 - m2) / (1 + m1 * m2) )
            if  deltaGamma.isNaN {
                return
            }
            sceneLevel.setGamma((sceneLevel.getGamma() + deltaGamma).truncatingRemainder(dividingBy: (3.1425*2.0)))
            sceneLevel.updateScene()
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func actionOpenGame(_ indexOfModel : Int){
        indexOfActiveModel = indexOfModel
        // rotate so that the active model is at 9am
        sceneLevel.setGamma(-(CGFloat(Double.pi / 8.0) * CGFloat(indexOfModel)))
        sceneLevel.hideButtons()
        skview.presentScene(sceneGame)
        sceneGame.renderModel()
    }
    
    func showLeaderboard() {
        let gcVC: GKGameCenterViewController = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = GKGameCenterViewControllerState.leaderboards
        gcVC.leaderboardIdentifier = "leaderboardID"
        self.present(gcVC, animated: true, completion: nil)
    }
    
    func rotateToNextModel() {
        sceneLevel.setGamma( -CGFloat(Double.pi / 8.0) * CGFloat(4 + modelController.getIndexOfNextFreeLevel()))
        sceneLevel.setGammaOffset(0)
    }
    
    func getActiveModel() -> Model {
        return modelController.pageModels[indexOfActiveModel]
    }
    
    func getModelIndex() -> Int {
        return indexOfActiveModel
    }
    
    static func getFormattedString(value: Float) -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value : value))!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Scales.setSize(size: UIScreen.main.bounds.size)
        
        skview = SKView(frame: CGRect(x: 0, y: 0, width: Scales.width, height: Scales.height));
        self.view.addSubview(skview);
        
        sceneStart = StartScene(size: skview.frame.size, viewController: self)
        skview.showsFPS = false
        skview.showsNodeCount = false
        skview.ignoresSiblingOrder = false
        sceneStart.scaleMode = SKSceneScaleMode.aspectFill
        skview.presentScene(sceneStart, transition: SKTransition.flipHorizontal(withDuration: 1))
        
        sceneGame = GameScene(size:skview.bounds.size, viewController: self)
        sceneGame.scaleMode = SKSceneScaleMode.aspectFill
        
        sceneLevel = LevelScene(size:skview.bounds.size, viewController: self)
        sceneLevel.scaleMode = SKSceneScaleMode.aspectFill
        
        addPan()
        
        // Force the device in portrait mode when the view controller gets loaded
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        let orientation: UIInterfaceOrientationMask = [UIInterfaceOrientationMask.portrait, UIInterfaceOrientationMask.portraitUpsideDown]
        return orientation
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
}

