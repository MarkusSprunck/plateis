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


class DataViewController: UIViewController {
    
    var modelController : ModelController {
        get {
            if _modelController == nil {
                _modelController = ModelController()
            }
            return _modelController!
        }
    }
    private var _modelController : ModelController? = nil

    var width : CGFloat {
        get {
            return _width
        }
    }
    private var _width : CGFloat!
    
    var height : CGFloat {
        get {
            return _height
        }
    }
    private var _height : CGFloat!
    
    private var sceneStart: StartScene!
    
    private var sceneLevel: LevelScene!
    
    internal var sceneGame:  GameScene!
    
    private var indexOfActiveModel : Int = 0;
    
    private var isInSwipe:Bool = false
    
    private var products : [SKProduct] = []
    
    var skview: SKView!
    
    internal func actionStart() {
        
        sceneStart.hideAllElements()
        sceneGame.hideAllElements()
    
        skview.presentScene(sceneLevel)
        
        sceneLevel.buttonPlayLevel.fadeIn(0.1)
        sceneLevel.buttonFeatures.fadeIn(0.1)
        sceneLevel.buttonNextWorld.fadeIn(0.1)
        sceneLevel.buttonPreviousWorld.fadeIn(0.1)
        
        modelController.findNextFreeLevel()
        sceneLevel.setSelectedModel(modelController.getIndexOfNextFreeLevel())
        rotateToNextModel()
        sceneLevel.updateScene()
        
    }
    
    internal func actionOpenGame(indexOfModel : Int){
        indexOfActiveModel = indexOfModel
        
        // rotate so that the active model is at 9am
        sceneLevel.gamma = -(CGFloat(M_PI / 8.0) * CGFloat(indexOfModel))
        
        sceneLevel.buttonFeatures.fadeOut(0.1)
        sceneLevel.buttonPlayLevel.fadeOut(0.1)
        sceneLevel.buttonNextWorld.fadeOut(0.1)
        sceneLevel.buttonPreviousWorld.fadeOut(0.1)
        
        sceneGame.resetHintCount()
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
    
    func updateSize(size : CGSize) {
        _width =  min(size.width, size.height)
        _height = max(size.width, size.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateSize(UIScreen.mainScreen().bounds.size)
        
        skview = SKView(frame: CGRect(x: 0, y: 0, width: _width, height: _height));
        self.view.addSubview(skview);
        
        sceneStart = StartScene(size: skview.frame.size, viewController: self)
        skview.showsFPS = false
        skview.showsNodeCount = false
        skview.ignoresSiblingOrder = false
        sceneStart.scaleMode = SKSceneScaleMode.AspectFill
        skview.presentScene(sceneStart, transition: SKTransition.flipHorizontalWithDuration(1))
       
        sceneGame = GameScene(size:skview.bounds.size, viewController: self)
        sceneGame.scaleMode = SKSceneScaleMode.AspectFill
         
        sceneLevel = LevelScene(size:skview.bounds.size, viewController: self)
        sceneLevel.scaleMode = SKSceneScaleMode.AspectFill
        
        addSwipe()
        addPan()
       
        // Force the device in portrait mode when the view controller gets loaded
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
        
    }
   
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
  
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    func addPan() {
        let panGesture = UIPanGestureRecognizer(target: self, action:(#selector(DataViewController.handlePanGesture(_:))))
        self.view.addGestureRecognizer(panGesture)
    }

    
    func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translationInView(view)
        panGesture.setTranslation(CGPoint.zero, inView: view)
        if panGesture.state == UIGestureRecognizerState.Changed {
        
            let point: CGPoint = panGesture.locationInView(self.view)
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
            sceneLevel.gamma = (sceneLevel.gamma + deltaGamma) % (3.1425*2.0)
            sceneLevel.updateScene()
            sceneLevel.fadeOutHelpText()
        }
    }
    
    func addSwipe() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DataViewController.handleSwipe(_:)))
        self.view.addGestureRecognizer(panRecognizer)
    }
    
    
    func handleSwipe(sender:UISwipeGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            isInSwipe = true
        } else if sender.state == UIGestureRecognizerState.Ended {
            isInSwipe = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
  
  
}

