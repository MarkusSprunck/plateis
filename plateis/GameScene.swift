//
//  GameScene.swift
//  SprunckOne
//
//  Created by Markus Sprunck on 01/07/16.
//  Copyright (c) 2016 Markus Sprunck. All rights reserved.
//

import SpriteKit

import MessageUI

import UIKit

class GameScene : SKScene {
    
    fileprivate var viewController : DataViewController
 
    fileprivate var background : SKSpriteNode!

    fileprivate var labelLevel : SKLabelNode!
    
    fileprivate var labelResult : SKLabelNode!
    
    fileprivate var labelHelp : SKLabelNode!
    
    fileprivate var buttonHint : UIButton!

    fileprivate var buttonUndo : UIButton!
    
    fileprivate var buttonLevels : UIButton!
    
    fileprivate var buttonShare : UIButton!
    
    fileprivate var starGreen : SKShapeNode!
 
    fileprivate var starYellow : SKShapeNode!
 
    fileprivate var starRed : SKShapeNode!
    
    fileprivate var circles : [SKShapeNode] = []
    
    fileprivate static var isTapped : Bool = false
 
    fileprivate var isSelectionBestVisible : Bool = false
    
    fileprivate var lastSelectedNode : Node!
    
    init(size : CGSize, viewController : DataViewController) {
        self.viewController = viewController
        super.init(size : size)

        createLabels()
        createButtons()
        createStars()
        
        hide()
    }
    
    required init(coder aDecoder : NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    internal func renderModel() {
        // delete all elements
        self.removeAllChildren()
        self.removeAllActions()
        
        // create all elements
        createBackground()
        createNodes()
        createLines()
        createLinesBest()
        createLabels()
        createStars()
    
        showElements()
        updateLabels()
        fadeInHelpText()
    }
    
    internal func actionHint(_ sender : UIButton!) {
        isSelectionBestVisible = true
        viewController.getModel().hints = viewController.getModel().hints + 1
        renderModel()
    }
    
    internal func actionUndoButton(_ sender : UIButton!) {
        viewController.getModel().undoLastSelected()
        renderModel()
        updateLabels()
    }
    
    internal func actionShareButton(_ sender : UIButton!) {
        // Make screenshot
        let window: UIWindow! = UIApplication.shared.keyWindow
        let image = window.capture()
 
        // Save it to the camera roll
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
  
    internal func actionLevelsButton(_ sender : UIButton!) {
        viewController.actionStart()
        hide()
    }
    
    fileprivate func isDistanceBest() -> Bool {
        let model : Model = viewController.getModel()
        let distance = round(Model.getDistance(model.nodesSelected) * Float(100.0))
        let distanceBest = round( model.getDistanceBest() * Float(100.0))
        return distance <= distanceBest
    }
    
    fileprivate func updateLabels() {
        let model : Model = viewController.getModel()
        labelLevel.text = viewController.modelController.getCurrentWorld() + " / " + NSLocalizedString("LEVEL", comment : "Level") + " " + model.getName()
        
        if model.isComplete() {
            buttonShare.backgroundColor = Colors.blue
            buttonShare.alpha = 1.0
            buttonShare.frame = CGRect(x : (Scales.width/2 - Scales.buttonWidth/2), y : Scales.height -  Scales.bottom, width : Scales.buttonWidth, height : Scales.buttonHeight)
   
            buttonUndo.alpha = 0.0
        } else {
            buttonShare.backgroundColor = Colors.grey
            buttonShare.alpha = 0.0
            buttonUndo.frame = CGRect(x : (Scales.width/2 - Scales.buttonWidth/2), y : Scales.height -  Scales.bottom, width : Scales.buttonWidth, height : Scales.buttonHeight)
            buttonUndo.alpha = 1.0
        }
        
        buttonUndo.backgroundColor = (model.getSelectedCount() > 0) ? Colors.blue : Colors.grey
        
        buttonHint.frame = CGRect(x : 10, y : Scales.height -  Scales.bottom, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonLevels.frame = CGRect(x : (Scales.width - Scales.buttonWidth - 10), y : Scales.height -  Scales.bottom, width : Scales.buttonWidth, height : Scales.buttonHeight)
        
        
        let best = model.getDistanceBest()
        let distance = Model.getDistance(model.nodesSelected)
        labelResult.text = NSLocalizedString("RESULT", comment : "Result") + " \(distance) / " + NSLocalizedString("BEST", comment : "Result") + " \(best)"
        if model.isReady() {
            fadeOutHelpText()
            fadeInResultText()
        } else {
            fadeOutResultText()
            fadeInHelpText()
        }
        
        GameScene.isTapped = GameScene.isTapped || model.isComplete()
        
        buttonHint.setTitle(NSLocalizedString("HINT", comment : "Show hint about best solution") + " \(viewController.getModel().hints + 1)"  ,for : UIControlState())
    }
    
    fileprivate func showElements() {
        labelLevel.alpha = 1.0
        buttonShare.fadeIn()
        buttonLevels.fadeIn()
        buttonHint.fadeIn()
        buttonUndo.fadeIn()
    }
    
    fileprivate func createButtons() {
        buttonLevels = UIButton(type : UIButtonType.custom)
        buttonLevels.frame = CGRect(x : 0, y : 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonLevels.titleLabel!.font =  UIFont(name : "Helvetica", size : Scales.fontSizeButton)
        buttonLevels.backgroundColor =  Colors.blue
        buttonLevels.layer.cornerRadius = 0.5 * buttonLevels.bounds.size.height
        buttonLevels.layer.borderWidth = 0
        buttonLevels.setTitle(NSLocalizedString("LEVELS", comment : "Levels"), for : UIControlState())
        buttonLevels.addTarget(self, action : #selector(GameScene.actionLevelsButton(_ : )), for : UIControlEvents.touchUpInside)
        viewController.view.addSubview(buttonLevels)
    
        buttonUndo = UIButton(type : UIButtonType.custom)
        buttonUndo.frame = CGRect(x : 0, y : 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonUndo.titleLabel!.font =  UIFont(name : "Helvetica", size : Scales.fontSizeButton)
        buttonUndo.backgroundColor =  Colors.blue
        buttonUndo.layer.cornerRadius = 0.5 * buttonLevels.bounds.size.height
        buttonUndo.layer.borderWidth = 0
        buttonUndo.setTitle(NSLocalizedString("UNDO", comment : "Undo last selection"), for : UIControlState())
        buttonUndo.addTarget(self, action : #selector(GameScene.actionUndoButton(_ : )), for : UIControlEvents.touchUpInside)
        viewController.view.addSubview(buttonUndo)
        
        buttonShare = UIButton(type : UIButtonType.custom)
        buttonShare.frame = CGRect(x : 0, y : 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonShare.titleLabel!.font =  UIFont(name : "Helvetica", size : Scales.fontSizeButton)
        buttonShare.backgroundColor =  Colors.blue
        buttonShare.layer.cornerRadius = 0.5 * buttonLevels.bounds.size.height
        buttonShare.layer.borderWidth = 0
        buttonShare.setTitle(NSLocalizedString("SHARE", comment : "Share result"), for : UIControlState())
        buttonShare.addTarget(self, action : #selector(GameScene.actionShareButton(_ : )), for : UIControlEvents.touchUpInside)
        viewController.view.addSubview(buttonShare)

        buttonHint = UIButton(type : UIButtonType.custom)
        buttonHint.frame = CGRect(x : 0, y : 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonHint.titleLabel!.font =  UIFont(name : "Helvetica", size : Scales.fontSizeButton )
        buttonHint.backgroundColor =  Colors.blue
        buttonHint.layer.cornerRadius = 0.5 * buttonLevels.bounds.size.height
        buttonHint.layer.borderWidth = 0
        buttonHint.setTitle(NSLocalizedString("HINT", comment : "Show hint about best solution") + " \(viewController.getModel().hints)"  ,for : UIControlState())
        buttonHint.addTarget(self, action : #selector(GameScene.actionHint(_ : )), for : UIControlEvents.touchUpInside)
        viewController.view.addSubview(buttonHint)
    }
    
    fileprivate func createStars(){
        
        let starPath : CGPath = starPathInRect()
        let model : Model = viewController.getModel()
        
        // taffic lights
        let isGreen = model.isReady() && isDistanceBest()
        let isYellow =  model.isReady() && !isDistanceBest() || isGreen
        let isRed = model.getSelectedCount() > 0
        
        starGreen = SKShapeNode(path : starPath)
        starGreen.position = CGPoint(x : 2 * Scales.left + Scales.starDistance * 2.0, y : Scales.height - Scales.top )
        starGreen.zPosition = 10
        starGreen.setScale(Scales.scaleStars)
        starGreen.strokeColor = Colors.black
        starGreen.lineWidth = Scales.lineWidth
        starGreen.fillColor = isGreen ? Colors.green : Colors.white
        addChild(starGreen)

        starYellow = SKShapeNode(path : starPath)
        starYellow.position = CGPoint(x : 2 * Scales.left + Scales.starDistance, y : Scales.height - Scales.top )
        starYellow.zPosition = 10
        starYellow.setScale(Scales.scaleStars)
        starYellow.strokeColor = Colors.black
        starYellow.lineWidth = Scales.lineWidth
        starYellow.fillColor = isYellow ? Colors.yellow : Colors.white
        addChild(starYellow)

        starRed = SKShapeNode(path : starPath)
        starRed.position = CGPoint(x : 2 * Scales.left , y : Scales.height - Scales.top )
        starRed.zPosition = 10
        starRed.setScale(Scales.scaleStars)
        starRed.strokeColor = Colors.black
        starRed.lineWidth = Scales.lineWidth
        starRed.fillColor = isRed ? Colors.red : Colors.white
        addChild(starRed)
    }

    fileprivate func createLabels() {
        labelLevel = SKLabelNode(fontNamed : "Helvetica Neue UltraLight")
        labelLevel.fontSize = Scales.fontSizeLabel
        labelLevel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.top
        labelLevel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        labelLevel.fontColor = Colors.black
        labelLevel.position = CGPoint(x : Scales.width - Scales.right , y : Scales.height - Scales.top)
        self.addChild(labelLevel)
        
        labelResult = SKLabelNode(fontNamed : "Helvetica Neue UltraLight")
        labelResult.fontSize = Scales.fontSizeLabel
        labelResult.verticalAlignmentMode = SKLabelVerticalAlignmentMode.bottom
        labelResult.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        labelResult.fontColor = Colors.black
        labelResult.alpha = viewController.getModel().isReady() ? 1.0 : 0.0
        labelResult.position = CGPoint(x : Scales.width/2, y :Scales.bottom + Scales.bannerBottom * 0.5)
        self.addChild(labelResult)
        
        labelHelp = SKLabelNode(fontNamed : "Helvetica Neue Light")
        labelHelp.fontSize = Scales.fontSizeLabel
        labelHelp.verticalAlignmentMode = SKLabelVerticalAlignmentMode.bottom
        labelHelp.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        labelHelp.fontColor = Colors.darkGrey
        labelHelp.text = NSLocalizedString("GAME_HELP", comment : "Tap to select node")
        labelHelp.position = CGPoint(x : Scales.width/2, y :  Scales.bottom + Scales.bannerBottom * 0.5)
        labelHelp.alpha = GameScene.isTapped || viewController.getModel().isReady() ? 0.0 : 1.0
        self.addChild(labelHelp)
    }
    
    
    func fadeInHelpText() {
        if !GameScene.isTapped {
            let fadeAction = SKAction.fadeAlpha(to: 1.0, duration : 3.0)
            labelHelp.run(fadeAction)
        }
    }
    
    func fadeOutHelpText() {
        let fadeAction = SKAction.fadeAlpha(to: 0.0, duration : 3.0)
        labelHelp.run(fadeAction)
        GameScene.isTapped = true
    }

    
    func fadeInResultText() {
        let fadeAction = SKAction.fadeAlpha(to: 1.0, duration : 2.0)
        labelResult.run(fadeAction)
    }
    
    func fadeOutResultText() {
        let fadeAction = SKAction.fadeAlpha(to: 0.0, duration : 2.0)
        labelResult.run(fadeAction)
    }
    
    fileprivate func createBackground() {
        if nil == self.background {
            background = SKSpriteNode(imageNamed : "background-white")
            background.zPosition = -1
            background.position = CGPoint(x : Scales.width / 2, y : Scales.height / 2)
            background.setScale(2.0)
            background.anchorPoint = CGPoint(x : 0.5, y : 0.5)
        }
        if nil != self.background {
            addChild(background.copy() as! SKNode)
        }
    }
    
    func  getColorOfLevel(_ index : Int) -> UIColor {
        var color = Colors.darkGrey
        if index <= viewController.modelController.getIndexOfNextFreeLevel() || PlateisProducts.store.isProductPurchased(PlateisProducts.SkipLevelsRage)   {
            if viewController.modelController.pageModels[index].isComplete() {
                color = Colors.green
            } else if viewController.modelController.pageModels[index].isIncomplete() {
                color = Colors.yellow
            } else if viewController.modelController.pageModels[index].getSelectedCount() > 0 {
                color = Colors.red
            }
            
        } else {
            if PlateisProducts.store.isProductPurchased(PlateisProducts.SkipLevelsRage)  {
                color = Colors.darkGrey
            } else {
                color = Colors.lightGray
            }
        }
        return color
    }

    
    fileprivate func createNodes() {
        let indexMax = viewController.getModel().count()
        var index = 0
        while index < indexMax {
            let node = viewController.getModel().getNode(index)
            let position = getLocation(node)
            let alpha = CGFloat(1.0)
            if viewController.getModel().isSelected(node) {
                let color = getColorOfLevel(viewController.getModelIndex())
                let circle : SKShapeNode = LevelScene.createcircle(Scales.width * Scales.scaleNodes, position : position, color : color
                , alpha : alpha, lineWidth : Scales.lineWidth, animate : false, name : String(index))
                circle.lineWidth =  Scales.lineWidth
                circle.strokeColor = Colors.black
                circle.name = String(index)
                self.addChild(circle)
                circles.append(circle)
                circle.zPosition = 1000
        
                if !viewController.getModel().isReady() && viewController.getModel().getNodeSelected(viewController.getModel().getSelectedCount()-1) == node {
                    let waitAction = SKAction.wait(forDuration: 0.8)
                    let growAction = SKAction.scale(by: 1.1, duration: 0.3)
                    let shrinkAction = growAction.reversed()
                    let backAndForthSequence = SKAction.sequence([waitAction, growAction, shrinkAction])
                    circle.run(SKAction.repeatForever(backAndForthSequence))
                }

                
            } else if node.isActive() {
                let circle : SKShapeNode = LevelScene.createcircle(Scales.width * Scales.scaleNodes, position : position, color : Colors.white, alpha : alpha, lineWidth : Scales.lineWidth, animate : false, name : String(index))
                circle.lineWidth =  Scales.lineWidth
                circle.strokeColor = Colors.black
                circle.name = String(index)
                self.addChild(circle)
                circles.append(circle)
                circle.zPosition = 2000
            }
            index += 1
        }
    }
  
    
    fileprivate func getLocation(_ node : Node) -> CGPoint {
        
        let offsetYTop = Scales.top + Scales.bannerTop * 0.5
        let offsetYBottom = Scales.bottom + Scales.bannerBottom * 3.0
        let sizeY = Scales.height - offsetYBottom - offsetYTop
        
        let sizeX = Scales.width - Scales.left - Scales.right
        let radius = Scales.width * Scales.scaleNodes
        
        let boxWidth : CGFloat  = sizeX / CGFloat(viewController.getModel().getCols())
        let xLocation : CGFloat =  CGFloat(node.x)  * boxWidth + Scales.left + radius*1.5
      
        let boxHeight : CGFloat  = sizeY / CGFloat(viewController.getModel().getRows())
        let yLocation : CGFloat =  CGFloat(node.y) * boxHeight + offsetYBottom
        
        return CGPoint(x : CGFloat(xLocation), y : CGFloat(yLocation))
    }
    
    
    fileprivate func createLines() {
        var firstNodeLocation : CGPoint!
        let path : CGMutablePath = CGMutablePath()
        
        let indexMax = viewController.getModel().getSelectedCount()
        var index = 0
        while index < indexMax {
            let node = viewController.getModel().getNodeSelected(index)
            let location = getLocation(node)
            
            if  nil == firstNodeLocation  {
                    firstNodeLocation = location
                    path.move(to: firstNodeLocation)
             }  else {
                path.addLine(to: location)
            }
            
            let isReady = viewController.getModel().isReady()
            if isReady && viewController.getModel().isSelectedLast(node) {
                path.addLine(to: firstNodeLocation)
            }
            index += 1
        }
        
        let shape = SKShapeNode()
        shape.path = path
        shape.strokeColor = Colors.black
        shape.lineWidth = Scales.lineWidth
        shape.zPosition = 5
        addChild(shape)
    }
    
    fileprivate func createLinesBest() {
        if self.isSelectionBestVisible {
            var firstNodeLocation : CGPoint!
            let path : CGMutablePath = CGMutablePath()
        
            let indexMax = viewController.getModel().nodesSelectedBest.count
            var index = 0
            while index < indexMax {
                let node = viewController.getModel().nodesSelectedBest[index]
                let location = getLocation(node)
            
                if  nil == firstNodeLocation  {
                    firstNodeLocation = location
                    path.move(to: location)
                }  else {
                    path.addLine(to: location)
                }
            
                if index + 1 == indexMax {
                    path.addLine(to: firstNodeLocation)
                 }
                index += 1
            }
        
            let shape = SKShapeNode()
            shape.path = path
            shape.strokeColor = Colors.green
            shape.lineWidth = 3
            shape.zPosition = 3000
            shape.alpha = 1.0
            addChild(shape)
            
            self.buttonLevels.isEnabled = false
            self.buttonLevels.backgroundColor  = Colors.grey
            self.buttonHint.backgroundColor = Colors.grey
            
            UIView.animate(withDuration: 2.0, delay : 0.0, options : UIViewAnimationOptions.curveEaseOut,
                           animations : {
                                self.buttonHint.backgroundColor = Colors.blue
                                self.buttonLevels.backgroundColor  = Colors.blue
                            },
                           completion : {
                                (value : Bool) in
                                self.isSelectionBestVisible = false
                                self.buttonLevels.isEnabled = true
                                self.renderModel()
                           })
            
        }
    }

    
    override func touchesBegan(_ touches : Set<UITouch>, with event : UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let sprite : SKNode = self.atPoint(location)
            if (sprite.name  != nil && !(sprite.name?.isEmpty)!) {
                let index : Int = Int(sprite.name!)!
                let node =  viewController.getModel().getNode( index )
                viewController.getModel().selectNode(node)
                
                // Store last selected node for animation
                lastSelectedNode = node
                
                renderModel()
                updateLabels()
                fadeOutHelpText()
            }
        }
    }

    internal func hide() {
        labelLevel.alpha = 0.0
        labelResult.alpha = 0.0
        
        buttonShare.alpha = 0.0
        buttonUndo.alpha = 0.0
        buttonHint.alpha = 0.0
        buttonLevels.alpha = 0.0
        
        starYellow.alpha = 0.0
        starGreen.alpha = 0.0
        starRed.alpha = 0.0
        
        // Remove buttons to avoid not wanted clicks
        buttonHint.frame = CGRect(x : -Scales.buttonWidth, y : 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonUndo.frame = CGRect(x : -Scales.buttonWidth, y : 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonShare.frame = CGRect(x : -Scales.buttonWidth, y : 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonLevels.frame = CGRect(x : -Scales.buttonWidth, y : 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
    }
    
    func pointFrom(_ angle : CGFloat, radius : CGFloat, offset : CGPoint) -> CGPoint {
        return CGPoint(x : radius * cos(angle) + offset.x, y : radius * sin(angle) + offset.y)
    }
    
    
    func starPathInRect() -> CGPath {
    
        let rect : CGRect = CGRect( x : 0 , y : 0, width : 28, height : 28 )
        let starExtrusion : CGFloat = 28.0
        let center = CGPoint(x : rect.width / 2.0, y : -rect.height )
        let pointsOnStar = 5
        var angle : CGFloat = -CGFloat(M_PI / 2.0)
        let angleIncrement = CGFloat(M_PI * 2.0 / Double(pointsOnStar))
        let radius = rect.width / 2.0
        
        var firstPoint = true
        
        let path = UIBezierPath()
        for _ in 1...pointsOnStar {
            
            let point = pointFrom(angle, radius : radius, offset : center)
            let nextPoint = pointFrom(angle + angleIncrement, radius : radius, offset : center)
            let midPoint = pointFrom(angle + angleIncrement / 2.0, radius : starExtrusion, offset : center)
            
            if firstPoint {
                firstPoint = false
                path.move(to: point)
            }
            
            path.addLine(to: midPoint)
            path.addLine(to: nextPoint)
            
            angle += angleIncrement
        }
        
        path.close()
        
        return path.cgPath
    }


}


