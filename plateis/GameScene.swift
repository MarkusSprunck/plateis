//
//  GameScene.swift
//  PLATEIS
//
//  Copyright (c) 2016-2017 Markus Sprunck. All rights reserved.
//

import SpriteKit

import MessageUI

import UIKit

class GameScene : SKScene {
    
    private var viewController : DataViewController
    
    private var background : SKSpriteNode!
    
    private var labelLevel : SKLabelNode!
    
    private var labelResult : SKLabelNode!
    
    private var buttonHint : UIButton!
    
    private var buttonUndo : UIButton!
    
    private var buttonLevels : UIButton!
    
    private var buttonShare : UIButton!
    
    private var starGreen : SKShapeNode!
    
    private var starYellow : SKShapeNode!
    
    private var starRed : SKShapeNode!
    
    private var circles : [SKShapeNode] = []
    
    private var circlesText : [SKLabelNode] = []
    
    private static var isTapped : Bool = false
    
    private static var isSwiped : Bool = false
    
    private var isSelectionBestVisible : Bool = false
    
    private var lastSelectedNode : Node!
    
    private var hasSelectionChanged = false
    
    private var gameVisible = false
    
    @objc private func actionHint(_ sender : UIButton!) {
        isSelectionBestVisible = true
        if !viewController.getActiveModel().isComplete() {
            viewController.getActiveModel().hints = viewController.getActiveModel().hints + 1
        }
        renderModel()
    }
    
    @objc private func actionUndoButton(_ sender : UIButton!) {
        viewController.getActiveModel().undoLastSelected()
        renderModel()
        updateLabels()
    }
    
    @objc private func actionShareButton(_ sender : UIButton!) {
        // make screenshot
        let window: UIWindow! = UIApplication.shared.keyWindow
        let image : UIImage = window.capture()
        
        let subject = "Succeeded in PLATEIS"
        let link = "https://itunes.apple.com/app/plateis/id1141912894"
        
        // set up activity view controller
        let objectsToShare = [image, link] as [Any]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityViewController.setValue(subject, forKey:  "Subject")
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
        
        // present the view controller
        self.viewController.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc private func actionLevelsButton(_ sender : UIButton!) {
        viewController.actionStart()
        hideElements()
        
        GameCenterManager.calculateScore(models:viewController.modelController.allModels)
        GameCenterManager.submitScore()
        viewController.sceneLevel.updateElements()
    }
    
    private func isDistanceBest() -> Bool {
        let model : Model = viewController.getActiveModel()
        let distance = round(Model.getDistance(model.nodesSelected) * Float(100.0))
        let distanceBest = round( model.getDistanceBest() * Float(100.0))
        return distance <= distanceBest
    }
    
    private func updateLabels() {
        let model : Model = viewController.getActiveModel()
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
        let best_string = DataViewController.getFormattedString(value: best)
        
        let distance = Model.getDistance(model.nodesSelected)
        let distance_string = DataViewController.getFormattedString(value: distance)
        
        labelResult.text = NSLocalizedString("RESULT", comment : "Result") + " \(distance_string) / " + NSLocalizedString("BEST", comment : "Result") + " \(best_string)"
        if model.isReady() {
            fadeInResultText()
        } else {
            fadeOutResultText()
        }
        
        GameScene.isTapped = GameScene.isTapped || model.isComplete()
        
        buttonHint.setTitle(NSLocalizedString("HINT", comment : "Show hint about best solution") + " \(viewController.getActiveModel().hints + 1)"  ,for : UIControlState())
    }
    
    private func showElements() {
        labelLevel.alpha = 1.0
        buttonShare.fadeIn()
        buttonLevels.fadeIn()
        buttonHint.fadeIn()
        buttonUndo.fadeIn()
    }
    
    private func createButtons() {
        buttonLevels = UIButton(type : UIButtonType.custom)
        buttonLevels.frame = CGRect(x : 0, y : 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonLevels.titleLabel!.font =  UIFont(name : "Helvetica", size : Scales.fontSizeButton)
        buttonLevels.backgroundColor =  Colors.blue
        buttonLevels.layer.cornerRadius = 0.5 * buttonLevels.bounds.size.height
        buttonLevels.layer.borderWidth = 0
        buttonLevels.setTitle(NSLocalizedString("LEVELS", comment : "Levels"), for : UIControlState())
        buttonLevels.addTarget(self, action : #selector(self.actionLevelsButton(_ : )), for : UIControlEvents.touchUpInside)
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
        buttonHint.setTitle(NSLocalizedString("HINT", comment : "Show hint about best solution") + " \(viewController.getActiveModel().hints)"  ,for : UIControlState())
        buttonHint.addTarget(self, action : #selector(GameScene.actionHint(_ : )), for : UIControlEvents.touchUpInside)
        viewController.view.addSubview(buttonHint)
    }
    
    private func createStars(){
        let starPath : CGPath = starPathInRect()
        let model : Model = viewController.getActiveModel()
        
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
    
    private func createLabels() {
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
        labelResult.alpha = viewController.getActiveModel().isReady() ? 1.0 : 0.0
        labelResult.position = CGPoint(x : Scales.width/2, y :Scales.bottom + Scales.bannerBottom * 0.5)
        self.addChild(labelResult)
        
    }
    
    private func fadeInResultText() {
        let fadeAction = SKAction.fadeAlpha(to: 1.0, duration : 2.0)
        labelResult.run(fadeAction)
    }
    
    private func fadeOutResultText() {
        let fadeAction = SKAction.fadeAlpha(to: 0.0, duration : 0.0)
        labelResult.run(fadeAction)
    }
    
    private func createBackground() {
        if nil == self.background {
            
            self.backgroundColor = Colors.white
            
            background = SKSpriteNode()
            background.zPosition = -1
            background.position = CGPoint(x : 0, y : 0)
            
            let size = Scales.width * Scales.scaleNodes
            for indexX in 0...6  {
                for indexY in 0...9  {
                    var position = getLocation(nodeX: CGFloat(indexX), nodeY: CGFloat(indexY))
                    
                    let path : CGMutablePath = CGMutablePath()
                    path.move(to: position)
                    position.x += size
                    path.addLine(to: position)
                    position.x -= size * 2
                    path.addLine(to: position)
                    position.x += size
                    path.move(to: position)
                    position.y += size
                    path.addLine(to: position)
                    position.y -= size * 2
                    path.addLine(to: position)
                    position.y += size
                    
                    let shape = SKShapeNode()
                    shape.path = path
                    shape.strokeColor = Colors.blue
                    shape.lineWidth = 0.2
                    shape.lineCap =  CGLineCap.round
                    shape.zPosition = 1
                    shape.alpha = 1.0
                    background.addChild(shape)
                }
            }
        }
        
        if nil != self.background {
            addChild(background.copy() as! SKNode)
        }
        
    }
    
    private func  getColorOfLevel(_ index : Int) -> UIColor {
        var color = Colors.lightGray
        if viewController.modelController.pageModels[index].isComplete() {
            color = Colors.green
        } else if viewController.modelController.pageModels[index].isIncomplete() {
            color = Colors.yellow
        } else if viewController.modelController.pageModels[index].getSelectedCount() > 0 {
            color = Colors.blue
        }
        return color
    }
    
    private func createNodes() {
        let indexMax = viewController.getActiveModel().count()
        var index = 0
        while index < indexMax {
            let node = viewController.getActiveModel().getNode(index)
            let position = getLocation(node)
            let alpha = CGFloat(1.0)
            if viewController.getActiveModel().isSelected(node) {
                let color = getColorOfLevel(viewController.getModelIndex())
                let circle : SKShapeNode = LevelScene.createcircle(Scales.width * Scales.scaleNodes, position : position, color : color
                    , alpha : alpha, lineWidth : Scales.lineWidth, animate : false, name : String(index))
                circle.lineWidth =  Scales.lineWidth
                circle.strokeColor = Colors.black
                circle.name = String(index)
                self.addChild(circle)
                circles.append(circle)
                circle.zPosition = 1000
                
                if !viewController.getActiveModel().isReady() && viewController.getActiveModel().getNodeSelected(viewController.getActiveModel().getSelectedCount()-1) == node {
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
                
                // this label is just needed for UI Tests
                let label = SKLabelNode(fontNamed:"Helvetica Neue Light")
                label.text = String(index)
                label.name = String(index)
                label.fontSize = Scales.fontSizeLabel
                label.position =  position
                label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
                label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
                label.fontColor = Colors.white
                self.addChild(label)
                label.zPosition = 2001
                circlesText.append(label)
            }
            index += 1
        }
    }
    
    private func getLocation(_ node : Node) -> CGPoint {
        return getLocation( nodeX : CGFloat(node.x), nodeY : CGFloat(node.y))
    }
    
    private func getLocation( nodeX : CGFloat, nodeY : CGFloat) -> CGPoint {
        let offsetYTop = Scales.top + Scales.bannerTop * 0.5
        let offsetYBottom = Scales.bottom + Scales.bannerBottom * 3.0
        let sizeY = Scales.height - offsetYBottom - offsetYTop
        
        let sizeX = Scales.width - Scales.left - Scales.right
        let radius = Scales.width * Scales.scaleNodes
        
        let boxWidth : CGFloat  = sizeX / CGFloat(viewController.getActiveModel().getCols())
        let xLocation : CGFloat =  nodeX * boxWidth + Scales.left + radius * 1.15
        
        let boxHeight : CGFloat  = sizeY / CGFloat(viewController.getActiveModel().getRows())
        let yLocation : CGFloat =  nodeY * boxHeight + offsetYBottom
        
        return CGPoint(x : CGFloat(xLocation), y : CGFloat(yLocation))
    }
    
    private func createLines() {
        var firstNodeLocation : CGPoint!
        let path : CGMutablePath = CGMutablePath()
        
        let indexMax = viewController.getActiveModel().getSelectedCount()
        var index = 0
        while index < indexMax {
            let node = viewController.getActiveModel().getNodeSelected(index)
            let location = getLocation(node)
            
            if  nil == firstNodeLocation  {
                firstNodeLocation = location
                path.move(to: firstNodeLocation)
            }  else {
                path.addLine(to: location)
            }
            
            let isReady = viewController.getActiveModel().isReady()
            if isReady && viewController.getActiveModel().isSelectedLast(node) {
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
    
    private func createLinesBest() {
        if self.isSelectionBestVisible {
            var firstNodeLocation : CGPoint!
            let path : CGMutablePath = CGMutablePath()
            
            let indexMax = viewController.getActiveModel().nodesSelectedBest.count
            var index = 0
            while index < indexMax {
                let node = viewController.getActiveModel().nodesSelectedBest[index]
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
    
    private func touchesHandler(_ touches : Set<UITouch>, with event : UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let sprite : SKNode = self.atPoint(location)
            if (sprite.name  != nil && !(sprite.name?.isEmpty)!) {
                let index : Int = Int(sprite.name!)!
                let node =  viewController.getActiveModel().getNode( index )
                viewController.getActiveModel().selectNode(node)
                
                // Store last selected node for animation
                lastSelectedNode = node
                hasSelectionChanged = true
                
                print("    touchesHandler " +  sprite.name!)
            }
        }
    }
    
    private func pointFrom(_ angle : CGFloat, radius : CGFloat, offset : CGPoint) -> CGPoint {
        return CGPoint(x : radius * cos(angle) + offset.x, y : radius * sin(angle) + offset.y)
    }
    
    private func starPathInRect() -> CGPath {
        let rect : CGRect = CGRect( x : 0 , y : 0, width : 24, height : 24 )
        let starExtrusion : CGFloat = 24.0
        let center = CGPoint(x : rect.width / 2.0, y : -rect.height )
        let pointsOnStar = 5
        var angle : CGFloat = -CGFloat(Double.pi / 2.0)
        let angleIncrement = CGFloat(Double.pi * 2.0 / Double(pointsOnStar))
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
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesHandler(touches , with: event)
    }
    
    override func touchesBegan(_ touches : Set<UITouch>, with event : UIEvent?) {
        touchesHandler(touches , with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if hasSelectionChanged {
            renderModel()
            updateLabels()
            hasSelectionChanged = false
        }
    }
    
    func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
        print("pan ")
    }
    
    func getModelName() -> String {
        return viewController.getActiveModel().getName()
    }
    
    func isGameVisible()  -> Bool {
        return gameVisible
    }
        
    func renderModel() {
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
        
        // update user interface
        showElements()
        updateLabels()
        
        gameVisible = true
    }
    
    func hideElements() {
        // make all elements transparent
        labelLevel.alpha = 0.0
        labelResult.alpha = 0.0
        buttonShare.alpha = 0.0
        buttonUndo.alpha = 0.0
        buttonHint.alpha = 0.0
        buttonLevels.alpha = 0.0
        starYellow.alpha = 0.0
        starGreen.alpha = 0.0
        starRed.alpha = 0.0
        
        // move buttons out of screen to avoid not wanted clicks
        buttonHint.frame = CGRect(x : -Scales.buttonWidth, y : 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonUndo.frame = CGRect(x : -Scales.buttonWidth, y : 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonShare.frame = CGRect(x : -Scales.buttonWidth, y : 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonLevels.frame = CGRect(x : -Scales.buttonWidth, y : 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
        
        gameVisible = false
    }
    
    required init(coder aDecoder : NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    
    init(size : CGSize, viewController : DataViewController) {
        self.viewController = viewController
        super.init(size : size)
        self.view?.isMultipleTouchEnabled = true
        
        createLabels()
        createButtons()
        createStars()
        hideElements()
    }
    
}


