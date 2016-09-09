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
    
    private var buttonHint: UIButton!

    private var buttonUndo: UIButton!
    
    private var buttonLevels : UIButton!
    
    private var starGreen : SKShapeNode!
 
    private var starYellow : SKShapeNode!
 
    private var starRed : SKShapeNode!
    
    private var starPath: CGPath!
    
    private var circles : [SKShapeNode] = []
    
    private var radiusNode: CGFloat = 0.0
    
    init(size : CGSize, viewController : DataViewController) {
        self.viewController = viewController
        super.init(size:size)
     
        radiusNode = viewController.width * 0.05
        
        starPath = starPathInRect(CGRect( x: 0 , y: 0, width: 30.0, height: 30.0 )).CGPath
        
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
    }
    
    internal func actionHint(sender: UIButton!) {
        isSelectionBestVisible = true
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
    
    internal func actionLevelsTimer(timer: NSTimer!) {
        if !isSelectionBestVisible {
            viewController.modelController.savePageModels()
            viewController.actionStart()
        }
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
        labelLevel.position = CGPoint(x: viewController.width - 15 , y: viewController.height - 20)
        buttonUndo.backgroundColor = (model.getSelectedCount() > 0) ? Colors.blue : Colors.grey
    }
    
    private func showElements() {
        labelLevel.alpha = 1.0
        buttonLevels.fadeIn()
        buttonHint.fadeIn()
        buttonUndo.fadeIn()
    }
    
    private func createButtons(){
        
        let buttonHeight:CGFloat = 34
        let buttonWidth:CGFloat = 95
        let distanceBottom:CGFloat = 46.0
        
        buttonLevels = UIButton(type: UIButtonType.Custom)
        buttonLevels.frame = CGRect(x : (self.viewController.width - buttonWidth - 10), y: self.viewController.height - distanceBottom, width : buttonWidth, height : buttonHeight)
        buttonLevels.titleLabel!.font =  UIFont(name: "Helvetica", size: 20)
        buttonLevels.backgroundColor =  Colors.blue
        buttonLevels.layer.cornerRadius = 0.5 * buttonLevels.bounds.size.height
        buttonLevels.layer.borderWidth = 0
        buttonLevels.setTitle(NSLocalizedString("LEVELS", comment:"Levels"), forState: UIControlState.Normal)
        buttonLevels.addTarget(self, action: #selector(GameScene.actionLevelsButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        viewController.view.addSubview(buttonLevels)
    
        buttonUndo = UIButton(type: UIButtonType.Custom)
        buttonUndo.frame = CGRect(x : (self.viewController.width/2 - buttonWidth/2), y: self.viewController.height - distanceBottom, width : buttonWidth, height : buttonHeight)
        buttonUndo.titleLabel!.font =  UIFont(name: "Helvetica", size: 20)
        buttonUndo.backgroundColor =  Colors.blue
        buttonUndo.layer.cornerRadius = 0.5 * buttonLevels.bounds.size.height
        buttonUndo.layer.borderWidth = 0
        buttonUndo.setTitle(NSLocalizedString("UNDO", comment:"Undo last selection"),forState: UIControlState.Normal)
        buttonUndo.addTarget(self, action: #selector(GameScene.actionUndoButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        viewController.view.addSubview(buttonUndo)

        buttonHint = UIButton(type: UIButtonType.Custom)
        buttonHint.frame = CGRect(x : 10, y: self.viewController.height - distanceBottom, width : buttonWidth, height : buttonHeight)
        buttonHint.titleLabel!.font =  UIFont(name: "Helvetica", size: 20)
        buttonHint.backgroundColor =  Colors.blue
        buttonHint.layer.cornerRadius = 0.5 * buttonLevels.bounds.size.height
        buttonHint.layer.borderWidth = 0
        buttonHint.setTitle(NSLocalizedString("HINT", comment:"Show hint about best solution"),forState: UIControlState.Normal)
        buttonHint.addTarget(self, action: #selector(GameScene.actionHint(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        viewController.view.addSubview(buttonHint)
    }
    
    private func createStars(){
        
        let distanceTop:CGFloat = 40.0
        let model : Model = viewController.getModel()
        
        let isGreen = model.isReady() && isDistanceBest()
        let isYellow =  model.isReady() && !isDistanceBest() || isGreen
        let isRed = model.getSelectedCount() > 0
        
        starGreen = SKShapeNode(path: starPath)
        starGreen.position = CGPoint(x : 95, y: viewController.height - distanceTop )
        starGreen.zPosition = 10
        starGreen.setScale(0.5)
        starGreen.strokeColor = Colors.black
        starGreen.lineWidth = 2
        starGreen.fillColor = isGreen ? Colors.green : Colors.white
        addChild(starGreen)

        starYellow = SKShapeNode(path: starPath)
        starYellow.position = CGPoint(x : 60, y: viewController.height - distanceTop )
        starYellow.zPosition = 10
        starYellow.setScale(0.5)
        starYellow.strokeColor = Colors.black
        starYellow.lineWidth = 2
        starYellow.fillColor = isYellow ? Colors.yellow : Colors.white
        addChild(starYellow)

        starRed = SKShapeNode(path: starPath)
        starRed.position = CGPoint(x : 25, y: viewController.height - distanceTop )
        starRed.zPosition = 10
        starRed.setScale(0.5)
        starRed.strokeColor = Colors.black
        starRed.lineWidth = 2
        starRed.fillColor = isRed ? Colors.red : Colors.white
        addChild(starRed)
    }

    private func createLabels() {
        labelLevel = SKLabelNode(fontNamed:"Helvetica Neue UltraLight")
        labelLevel.fontSize = 22
        labelLevel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Top
        labelLevel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        labelLevel.fontColor = Colors.black
        self.addChild(labelLevel)
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
        let boxWidth: CGFloat  = viewController.width  / CGFloat(viewController.getModel().getCols() + 1)
        let xLocation: CGFloat =  (CGFloat(node.x) + 1.0 )  * boxWidth
      
        let boxHeight: CGFloat  = viewController.height  / CGFloat(viewController.getModel().getRows() + 3 )
        let yLocation: CGFloat =  (CGFloat(node.y) + 2.0 )  * boxHeight
        
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
                    NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(GameScene.actionLevelsTimer(_:)), userInfo: nil, repeats: false)
                }
            }
        }
    }

    internal func hideAllElements() {
        labelLevel.alpha = 0
        buttonUndo.alpha = 0
        buttonHint.alpha = 0
        buttonLevels.alpha = 0
        starYellow.alpha = 0
        starGreen.alpha = 0
        starRed.alpha = 0
    }
    
    func pointFrom(angle: CGFloat, radius: CGFloat, offset: CGPoint) -> CGPoint {
        return CGPoint(x: radius * cos(angle) + offset.x, y: radius * sin(angle) + offset.y)
    }
    
    
    func starPathInRect(rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        
        let starExtrusion:CGFloat = 30.0
        
        let center = CGPoint(x:rect.width / 2.0, y:rect.height / 2.0)
        
        let pointsOnStar = 5
        
        var angle:CGFloat = -CGFloat(M_PI / 2.0)
        let angleIncrement = CGFloat(M_PI * 2.0 / Double(pointsOnStar))
        let radius = rect.width / 2.0
        
        var firstPoint = true
        
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
        
        return path
    }


}
