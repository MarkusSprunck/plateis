//
//  GameScene.swift
//  SprunckOne
//
//  Created by Markus Sprunck on 01/07/16.
//  Copyright (c) 2016 Markus Sprunck. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    private var viewController:DataViewController
 
    private var isSelectionBestVisible: Bool = false
    
    private var background: SKSpriteNode!

    private var labelLevel: SKLabelNode!
    
    private var labelResult: SKLabelNode!
    
    private var labelHelp: SKLabelNode!
    
    private var buttonHint: UIButton!

    private var buttonUndo: UIButton!
    
    private var buttonLevels : UIButton!
    
    private var starGreen : SKShapeNode!
 
    private var starYellow : SKShapeNode!
 
    private var starRed : SKShapeNode!
    
    private var circles : [SKShapeNode] = []
    
    private var radiusNode: CGFloat = 0.0
    
    private var hintCount : Int = 0
    
    private static var isTapped : Bool = false
    
    init(size : CGSize, viewController : DataViewController) {
        self.viewController = viewController
        super.init(size:size)
     
        radiusNode = viewController.width * 0.05
       
        createLabels()
        createButtons()
        createStars()
        hideAllElements()
        print("game scene init ready")
    }
    
    required init(coder aDecoder: NSCoder) {
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
    
    internal func actionHint(sender: UIButton!) {
        isSelectionBestVisible = true
        hintCount = hintCount + 1
        renderModel()
    }
    
    internal func actionUndoButton(sender: UIButton!) {
        viewController.getModel().undoLastSelected()
        renderModel()
        updateLabels()
    }
  
    internal func actionLevelsButton(sender: UIButton!) {
        viewController.modelController.savePageModels()
        viewController.actionStart()
        hideAllElements()
    }
    
    private func isDistanceBest() -> Bool {
        let model : Model = viewController.getModel()
        let distance = round(Model.getDistance(model.nodesSelected) * Float(100.0))
        let distanceBest = round( model.getDistanceBest() * Float(100.0))
        return distance <= distanceBest
    }
    
    private func updateLabels() {
        let model : Model = viewController.getModel()
        labelLevel.text = viewController.modelController.getCurrentWorld() + " / " + NSLocalizedString("LEVEL", comment:"Level") + " " + model.getName()
        
        buttonUndo.backgroundColor = (model.getSelectedCount() > 0) ? Colors.blue : Colors.grey
        
        // Move buttons to right position
        buttonUndo.frame = CGRect(x : (self.viewController.width/2 - Scales.buttonWidth/2), y: self.viewController.height -  Scales.bottom, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonHint.frame = CGRect(x : 10, y: self.viewController.height -  Scales.bottom, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonLevels.frame = CGRect(x : (self.viewController.width - Scales.buttonWidth - 10), y: self.viewController.height -  Scales.bottom, width : Scales.buttonWidth, height : Scales.buttonHeight)
        
        
        let distance = Model.getDistance(model.nodesSelected)
        labelResult.text = "Result \(distance) / Hints \(hintCount)"
   }
    
    internal func resetHintCount() {
        hintCount = 0
    }
    
    private func showElements() {
        labelLevel.alpha = 1.0
        buttonLevels.fadeIn()
        buttonHint.fadeIn()
        buttonUndo.fadeIn()
    }
    
    private func createButtons() {
        buttonLevels = UIButton(type: UIButtonType.Custom)
        buttonLevels.frame = CGRect(x : 0, y: 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonLevels.titleLabel!.font =  UIFont(name: "Helvetica", size: Scales.fontSizeButton)
        buttonLevels.backgroundColor =  Colors.blue
        buttonLevels.layer.cornerRadius = 0.5 * buttonLevels.bounds.size.height
        buttonLevels.layer.borderWidth = 0
        buttonLevels.setTitle(NSLocalizedString("LEVELS", comment:"Levels"), forState: UIControlState.Normal)
        buttonLevels.addTarget(self, action: #selector(GameScene.actionLevelsButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        viewController.view.addSubview(buttonLevels)
    
        buttonUndo = UIButton(type: UIButtonType.Custom)
        buttonUndo.frame = CGRect(x : 0, y: 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonUndo.titleLabel!.font =  UIFont(name: "Helvetica", size: Scales.fontSizeButton)
        buttonUndo.backgroundColor =  Colors.blue
        buttonUndo.layer.cornerRadius = 0.5 * buttonLevels.bounds.size.height
        buttonUndo.layer.borderWidth = 0
        buttonUndo.setTitle(NSLocalizedString("UNDO", comment:"Undo last selection"), forState: UIControlState.Normal)
        buttonUndo.addTarget(self, action: #selector(GameScene.actionUndoButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        viewController.view.addSubview(buttonUndo)

        buttonHint = UIButton(type: UIButtonType.Custom)
        buttonHint.frame = CGRect(x : 0, y: 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonHint.titleLabel!.font =  UIFont(name: "Helvetica", size: Scales.fontSizeButton )
        buttonHint.backgroundColor =  Colors.blue
        buttonHint.layer.cornerRadius = 0.5 * buttonLevels.bounds.size.height
        buttonHint.layer.borderWidth = 0
        buttonHint.setTitle(NSLocalizedString("HINT", comment:"Show hint about best solution"),forState: UIControlState.Normal)
        buttonHint.addTarget(self, action: #selector(GameScene.actionHint(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        viewController.view.addSubview(buttonHint)
    }
    
    private func createStars(){
        
        let starPath : CGPath = starPathInRect()
        let model : Model = viewController.getModel()
        let isGreen = model.isReady() && isDistanceBest()
        let isYellow =  model.isReady() && !isDistanceBest() || isGreen
        let isRed = model.getSelectedCount() > 0
        
        starGreen = SKShapeNode(path: starPath)
        starGreen.position = CGPoint(x : 95, y: viewController.height - Scales.top )
        starGreen.zPosition = 10
        starGreen.setScale(Scales.scaleStars)
        starGreen.strokeColor = Colors.black
        starGreen.lineWidth = 2
        starGreen.fillColor = isGreen ? Colors.green : Colors.white
        addChild(starGreen)

        starYellow = SKShapeNode(path: starPath)
        starYellow.position = CGPoint(x : 60, y: viewController.height - Scales.top )
        starYellow.zPosition = 10
        starYellow.setScale(Scales.scaleStars)
        starYellow.strokeColor = Colors.black
        starYellow.lineWidth = 2
        starYellow.fillColor = isYellow ? Colors.yellow : Colors.white
        addChild(starYellow)

        starRed = SKShapeNode(path: starPath)
        starRed.position = CGPoint(x : 25, y: viewController.height - Scales.top )
        starRed.zPosition = 10
        starRed.setScale(Scales.scaleStars)
        starRed.strokeColor = Colors.black
        starRed.lineWidth = 2
        starRed.fillColor = isRed ? Colors.red : Colors.white
        addChild(starRed)
    }

    private func createLabels() {
        labelLevel = SKLabelNode(fontNamed:"Helvetica Neue UltraLight")
        labelLevel.fontSize = Scales.fontSizeLabel
        labelLevel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        labelLevel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        labelLevel.fontColor = Colors.black
        labelLevel.position = CGPoint(x: viewController.width - 15 , y: viewController.height - Scales.top)
        self.addChild(labelLevel)
        
        labelResult = SKLabelNode(fontNamed:"Helvetica Neue UltraLight")
        labelResult.fontSize = Scales.fontSizeLabel
        labelResult.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        labelResult.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        labelResult.fontColor = Colors.black
        labelResult.position = CGPoint(x: viewController.width/2, y: Scales.bottom + Scales.bannerBottom)
        self.addChild(labelResult)
        
        labelHelp = SKLabelNode(fontNamed:"Helvetica Neue UltraLight")
        labelHelp.fontSize = Scales.fontSizeLabel
        labelHelp.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        labelHelp.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        labelHelp.fontColor = Colors.black
        labelHelp.text = NSLocalizedString("GAME_HELP", comment:"Tap to select node")
        labelHelp.alpha = 0.0
        labelHelp.position = CGPoint(x: viewController.width/2, y: viewController.height - Scales.top - Scales.bannerTop*2)
        self.addChild(labelHelp)
    }
    
    
    func fadeInHelpText() {
        if !GameScene.isTapped {
            let fadeAction = SKAction.fadeAlphaTo(1.0, duration: 3.0)
            labelHelp.runAction(fadeAction)
        }
    }
    
    func fadeOutHelpText() {
        let fadeAction = SKAction.fadeAlphaTo(0.0, duration: 3.0)
        labelHelp.runAction(fadeAction)
        GameScene.isTapped = true
    }

    
    private func createBackground() {
        if nil == self.background {
            background = SKSpriteNode(imageNamed: "background-white")
            background.zPosition = -1
            background.position = CGPoint(x: viewController.width / 2, y: viewController.height / 2)
            background.setScale(2.0)
            background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        }
        if nil != self.background {
            addChild(background.copy() as! SKNode)
        }
    }
    
    func  getColorOfLevel(index : Int) -> UIColor {
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

    
    private func createNodes() {
        let indexMax = viewController.getModel().count()
        var index = 0
        while index < indexMax {
            let node = viewController.getModel().getNode(index)
            let position = getLocation(node)
            let lineWidth : CGFloat = 1.0
            let alpha = CGFloat(1.0)
            if viewController.getModel().isSelected(node) {
                let color = getColorOfLevel(viewController.getModelIndex())
                let circle:SKShapeNode = LevelScene.createcircle(radiusNode, position: position, color: color
                , alpha: alpha, lineWidth: lineWidth, animate: false, name : String(index))
                circle.lineWidth =  2
                circle.strokeColor = Colors.black
                circle.name = String(index)
                self.addChild(circle)
                circles.append(circle)
                circle.zPosition = 1000
            } else if node.isActive() {
                let circle:SKShapeNode = LevelScene.createcircle(radiusNode, position: position, color: Colors.white, alpha: alpha, lineWidth: lineWidth, animate: false, name : String(index))
                circle.lineWidth =  2
                circle.strokeColor = Colors.black
                circle.name = String(index)
                self.addChild(circle)
                circles.append(circle)
                circle.zPosition = 2000
            }
            index += 1
        }
    }
  
    
    private func getLocation(node : Node) -> CGPoint {
        
        let offsetYTop = Scales.top + Scales.bannerTop * 2
        let offsetYBottom = Scales.bottom + Scales.bannerBottom * 2
        let sizeY = viewController.height - offsetYBottom - offsetYTop
        
        let boxWidth: CGFloat  = viewController.width  / CGFloat(viewController.getModel().getCols() + 1)
        let xLocation: CGFloat =  (CGFloat(node.x) + 1.0 )  * boxWidth
      
        let boxHeight: CGFloat  = sizeY  / CGFloat(viewController.getModel().getRows() )
        let yLocation: CGFloat =  CGFloat(node.y) * boxHeight + offsetYBottom
        
        return CGPoint(x: Int(xLocation), y: Int(yLocation))
    }
    
    
    private func createLines() {
        var firstNodeLocation:CGPoint? = nil
        let path : CGMutablePath = CGPathCreateMutable()
        
        let indexMax = viewController.getModel().getSelectedCount()
        var index = 0
        while index < indexMax {
            let node = viewController.getModel().getNodeSelected(index)
            let location = getLocation(node)
            
            if  nil == firstNodeLocation  {
                    firstNodeLocation = location
                    CGPathMoveToPoint(path, nil, firstNodeLocation!.x, firstNodeLocation!.y)
            }  else {
                CGPathAddLineToPoint(path, nil, location.x, location.y)            }
            
            let isReady = viewController.getModel().isReady()
            if isReady && viewController.getModel().isSelectedLast(node) {
                CGPathAddLineToPoint(path, nil, firstNodeLocation!.x, firstNodeLocation!.y)
            }
            index += 1
        }
        
        let shape = SKShapeNode()
        shape.path = path
        shape.strokeColor = Colors.black
        shape.lineWidth = 3
        shape.zPosition = 5
        addChild(shape)
    }
    
    private func createLinesBest() {
        if self.isSelectionBestVisible {
            var firstNodeLocation:CGPoint? = nil
            let path : CGMutablePath = CGPathCreateMutable()
        
            let indexMax = viewController.getModel().nodesSelectedBest.count
            var index = 0
            while index < indexMax {
                let node = viewController.getModel().nodesSelectedBest[index]
                let location = getLocation(node)
            
                if  nil == firstNodeLocation  {
                    firstNodeLocation = location
                    CGPathMoveToPoint(path, nil, firstNodeLocation!.x, firstNodeLocation!.y)
                }  else {
                    CGPathAddLineToPoint(path, nil, location.x, location.y)
                }
            
                if index + 1 == indexMax {
                    CGPathAddLineToPoint(path, nil, firstNodeLocation!.x, firstNodeLocation!.y)
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
            
            self.buttonLevels.enabled = false
            self.buttonLevels.backgroundColor  = Colors.grey
            self.buttonHint.backgroundColor = Colors.grey
            
            UIView.animateWithDuration(2.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut,
                           animations: {
                                self.buttonHint.backgroundColor = Colors.blue
                                self.buttonLevels.backgroundColor  = Colors.blue
                            },
                           completion: {
                                (value: Bool) in
                                self.isSelectionBestVisible = false
                                self.buttonLevels.enabled = true
                                self.renderModel()
                           })
            
        }
    }

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            let sprite:SKNode = self.nodeAtPoint(location)
            if (sprite.name  != nil && !(sprite.name?.isEmpty)!) {
                let index : Int = Int(sprite.name!)!
                let node =  viewController.getModel().getNode( index )
                viewController.getModel().selectNode(node)
                renderModel()
                updateLabels()
                if viewController.getModel().isComplete() {
                    labelResult.alpha = 1.0
                }
                fadeOutHelpText()
            }
        }
    }

    internal func hideAllElements() {
        labelLevel.alpha = 0.0
        labelResult.alpha = 0.0
        labelHelp.alpha = 0.0
        buttonUndo.alpha = 0.0
        buttonHint.alpha = 0.0
        buttonLevels.alpha = 0.0
        starYellow.alpha = 0.0
        starGreen.alpha = 0.0
        starRed.alpha = 0.0
        
        // Remove buttons to avoid not wanted clicks
        buttonHint.frame = CGRect(x : 0, y: 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonUndo.frame = CGRect(x : 0, y: 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonLevels.frame = CGRect(x : 0, y: 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
    }
    
    func pointFrom(angle: CGFloat, radius: CGFloat, offset: CGPoint) -> CGPoint {
        return CGPoint(x: radius * cos(angle) + offset.x, y: radius * sin(angle) + offset.y)
    }
    
    
    func starPathInRect() -> CGPath {
    
        let rect : CGRect = CGRect( x: 0 , y: 0, width: 30, height: 30 )
        let starExtrusion:CGFloat = 30.0
        let center = CGPoint(x:rect.width / 2.0, y:  -rect.height )
        let pointsOnStar = 5
        var angle:CGFloat = -CGFloat(M_PI / 2.0)
        let angleIncrement = CGFloat(M_PI * 2.0 / Double(pointsOnStar))
        let radius = rect.width / 2.0
        
        var firstPoint = true
        
        let path = UIBezierPath()
        for _ in 1...pointsOnStar {
            
            let point = pointFrom(angle, radius: radius, offset: center)
            let nextPoint = pointFrom(angle + angleIncrement, radius: radius, offset: center)
            let midPoint = pointFrom(angle + angleIncrement / 2.0, radius: starExtrusion, offset: center)
            
            if firstPoint {
                firstPoint = false
                path.moveToPoint(point)
            }
            
            path.addLineToPoint(midPoint)
            path.addLineToPoint(nextPoint)
            
            angle += angleIncrement
        }
        
        path.closePath()
        
        return path.CGPath
    }


}
