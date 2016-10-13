//
//  DataViewController.swift
//  PLATEIS
//
//  Created by Markus Sprunck on 07/07/16.
//  Copyright © 2016 Markus Sprunck. All rights reserved.
//

import UIKit
import SpriteKit
import StoreKit
import Foundation
import GameKit

///
///
///
class DataViewController: UIViewController , GKGameCenterControllerDelegate {
    
    // Stores if the user has Game Center enabled
    var gcEnabled = Bool()
    
    // Stores the default leaderboardID
    var gcDefaultLeaderBoard = String()
    
    var modelController : ModelController {
        get {
            if DataViewController._modelController == nil {
                DataViewController._modelController = ModelController()
            }
            return DataViewController._modelController!
        }
    }
    
    fileprivate static var  _modelController : ModelController? = nil

    fileprivate var sceneStart: StartScene!
    
    internal var sceneLevel: LevelScene!
    
    internal var sceneGame:  GameScene!
    
    fileprivate var indexOfActiveModel : Int = 0;
    
    fileprivate var isInSwipe:Bool = false
    
    fileprivate var products : [SKProduct] = []
    
    fileprivate var skview: SKView!
    
    internal func actionStart() {
        
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
    
    func authenticateLocalPlayer() {
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
                            print(error)
                        } else {
                            self.gcDefaultLeaderBoard = leaderboardIdentifer!
                        }
                    }
                )
            } else {
                // 3 Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated, disabling game center")
                print(error)
            }
        }
    }
    
 
    public func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
      
    public func showLeaderboard() {
        let gcVC: GKGameCenterViewController = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = GKGameCenterViewControllerState.leaderboards
        gcVC.leaderboardIdentifier = "leaderboardID"
        self.present(gcVC, animated: true, completion: nil)
    }

    
    internal func actionOpenGame(_ indexOfModel : Int){
        indexOfActiveModel = indexOfModel
        
        // rotate so that the active model is at 9am
        sceneLevel.gamma = -(CGFloat(M_PI / 8.0) * CGFloat(indexOfModel))
        
        sceneLevel.hideButtons()
        
        skview.presentScene(sceneGame)
        sceneGame.renderModel()
    }
    
    func rotateToNextModel() {
        sceneLevel.gamma =  -self.sceneLevel.PI_DIV_8 * CGFloat(4 + modelController.getIndexOfNextFreeLevel())
        sceneLevel.gammaOffset = 0
    }
  
    func getModel() -> Model {
        return modelController.pageModels[indexOfActiveModel]
    }
    
    func getModelIndex() -> Int {
        return indexOfActiveModel
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
        
        addSwipe()
        addPan()
       
        // Force the device in portrait mode when the view controller gets loaded
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        
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
    
    func addPan() {
        let panGesture = UIPanGestureRecognizer(target: self, action:(#selector(DataViewController.handlePanGesture(_:))))
        self.view.addGestureRecognizer(panGesture)
    }
    
    func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: view)
        panGesture.setTranslation(CGPoint.zero, in: view)
        if panGesture.state == UIGestureRecognizerState.changed {
        
            let point: CGPoint = panGesture.location(in: self.view)
            let center = sceneLevel.centerLarge
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
            sceneLevel.gamma = (sceneLevel.gamma + deltaGamma).truncatingRemainder(dividingBy: (3.1425*2.0))
            sceneLevel.updateScene()
            sceneLevel.fadeOutHelpText()
        }
    }
    
    func addSwipe() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DataViewController.handleSwipe(_:)))
        self.view.addGestureRecognizer(panRecognizer)
    }
    
    func handleSwipe(_ sender:UISwipeGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            isInSwipe = true
        } else if sender.state == UIGestureRecognizerState.ended {
            isInSwipe = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
  
    public static func getFormattedString(value: Float) -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value : value))!
    }
  
}

