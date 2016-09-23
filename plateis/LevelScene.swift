//
//  GameScene.swift
//  SprunckOne
//
//  Created by Markus Sprunck on 01/07/16.
//  Copyright (c) 2016 Markus Sprunck. All rights reserved.
//

import SpriteKit

class LevelScene: SKScene {
    
    fileprivate var viewController:DataViewController
    
    internal let PI_DIV_8 = CGFloat(M_PI / 8.0)
    
    fileprivate let labelDistanceFromTop: CGFloat = 190.0
    
    fileprivate var labelNameOfLevel: SKLabelNode!
    
    fileprivate var labelBest : SKLabelNode!
    
    fileprivate var labelResult : SKLabelNode!
    
    fileprivate var labelWorld : SKLabelNode!
    
    fileprivate var labelHelp : SKLabelNode!
    
    internal var buttonPlayLevel : UIButton!
    
    internal var buttonFeatures : UIButton!
    
    internal var buttonPreviousWorld : UIButton!
    
    internal var buttonNextWorld : UIButton!
    
    internal var gamma:CGFloat = 0.0
    
    internal var gammaOffset:CGFloat = -CGFloat(M_PI_2)
    
    fileprivate var selectedModelIndex : Int = 0
    
    internal var centerLarge : CGPoint = CGPoint(x: 0.0, y: 0.0)
    
    fileprivate var radiusLargeX : CGFloat = 0.0
    
    fileprivate var radiusLargeY : CGFloat = 0.0
    
    fileprivate var radiusLevel: CGFloat = 0.0
    
    fileprivate var timerSnapToPosition = Timer()
    
    fileprivate var timerRenderModel = Timer()
    
    fileprivate var circles : [SKShapeNode] = []
    
    fileprivate var circlesText : [SKLabelNode] = []
    
    fileprivate var isTapped : Bool = false
    
    init(size:CGSize, viewController:DataViewController) {
        self.viewController = viewController
        super.init(size: size)
        
        radiusLevel = Scales.width * 0.07
        radiusLargeX = (Scales.width -  Scales.left - Scales.right) * 0.5 - radiusLevel
        radiusLargeY = (Scales.height -  Scales.top - Scales.bottom - Scales.bannerTop*2 - Scales.bannerBottom*2 ) * 0.5 - radiusLevel
        centerLarge  = CGPoint(x: Scales.width * 0.5 , y:radiusLargeY + Scales.bottom + Scales.bannerBottom*2 + radiusLevel)
        
        if !viewController.modelController.pageModels.isEmpty {
            createBackground()
            createPlayButton()
            createLabels()
            createNodes()
            updateScene()
            fadeInHelpText()
        }
        print("level scene init ready")
        
    }
    
    func createBackground() {
        let background = SKSpriteNode(imageNamed: "background-white")
        background.zPosition = -1
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        background.setScale(2.0)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(background)
    }
    
    
    func createPlayButton(){
        buttonPlayLevel = UIButton(type: UIButtonType.custom)
        buttonPlayLevel.frame = CGRect(x : 0, y: 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonPlayLevel.titleLabel!.font =  UIFont(name: "Helvetica", size: Scales.fontSizeButton)
        buttonPlayLevel.backgroundColor =  Colors.blue
        buttonPlayLevel.layer.cornerRadius = 0.5 * buttonPlayLevel.bounds.size.height
        buttonPlayLevel.layer.borderWidth = 0
        buttonPlayLevel.setTitle(NSLocalizedString("PLAY", comment:"Start game"), for: UIControlState())
        buttonPlayLevel.addTarget(self, action: #selector(LevelScene.actionPlayButton(_:)), for: UIControlEvents.touchUpInside)
        buttonPlayLevel.alpha = 0
        viewController.skview.addSubview(buttonPlayLevel)
        
        
        buttonFeatures = UIButton(type: UIButtonType.custom)
        buttonFeatures.frame = CGRect(x : 0, y :0, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonFeatures.titleLabel!.font =  UIFont(name: "Helvetica", size: Scales.fontSizeButton)
        buttonFeatures.backgroundColor =  Colors.blue
        buttonFeatures.layer.cornerRadius = 0.5 * buttonFeatures.bounds.size.height
        buttonFeatures.layer.borderWidth = 0
        buttonFeatures.setTitle(NSLocalizedString("FEATURES", comment:"Open In-App-Purcases"), for: UIControlState())
        buttonFeatures.addTarget(self, action: #selector(LevelScene.actionFeaturesButton(_:)), for: UIControlEvents.touchUpInside)
        buttonFeatures.alpha = 0
        viewController.skview.addSubview(buttonFeatures)
        
        
        buttonPreviousWorld = UIButton(type: UIButtonType.custom)
        buttonPreviousWorld.frame =   CGRect(x : Scales.left, y: Scales.top , width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonPreviousWorld.titleLabel!.font =  UIFont(name: "Helvetica", size: Scales.fontSizeButton)
        buttonPreviousWorld.backgroundColor =   Colors.lightGray
        buttonPreviousWorld.layer.cornerRadius = 0.5 * buttonPreviousWorld.bounds.size.height
        buttonPreviousWorld.layer.borderWidth = 0
        buttonPreviousWorld.setTitle(NSLocalizedString("BACK", comment:"Previous world"), for: UIControlState())
        buttonPreviousWorld.addTarget(self, action: #selector(LevelScene.actionPreviousWorldButton(_:)), for: UIControlEvents.touchUpInside)
        buttonPreviousWorld.alpha = 0
        buttonPreviousWorld.isEnabled = false
        viewController.view.addSubview(buttonPreviousWorld)
        
        
        buttonNextWorld = UIButton(type: UIButtonType.custom)
        buttonNextWorld.frame =    CGRect(x : (Scales.width - Scales.buttonWidth - Scales.right), y: Scales.top, width : Scales.buttonWidth, height : Scales.buttonHeight)
        
        buttonNextWorld.titleLabel!.font =  UIFont(name: "Helvetica", size: Scales.fontSizeButton)
        buttonNextWorld.backgroundColor =   Colors.lightGray
        buttonNextWorld.layer.cornerRadius = 0.5 * buttonNextWorld.bounds.size.height
        buttonNextWorld.layer.borderWidth = 0
        buttonNextWorld.setTitle(NSLocalizedString("NEXT", comment:"Next world"), for:UIControlState())
        buttonNextWorld.addTarget(self, action: #selector(LevelScene.actionNextWorldButton(_:)), for: UIControlEvents.touchUpInside)
        buttonNextWorld.alpha = 0
        viewController.view.addSubview(buttonNextWorld)
    }
    
    internal func actionPlayButton(_ sender: UIButton!) {
        if selectedModelIndex <= viewController.modelController.getIndexOfNextFreeLevel() ||
            PlateisProducts.store.isProductPurchased(PlateisProducts.SkipLevelsRage) {
            viewController.actionOpenGame(selectedModelIndex)
        }
    }
    
    internal func actionFeaturesButton(_ sender: UIButton!) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let secondViewController = storyboard.instantiateViewController(withIdentifier: "FeatureId") as UIViewController
        
        let window = UIApplication.shared.windows[0] as UIWindow
        UIView.transition(
            from: window.rootViewController!.view,
            to: secondViewController.view,
            duration: 0.65,
            options: .transitionCrossDissolve,
            completion: {
                finished in window.rootViewController = secondViewController
        })
        
    }
    
    func actionPreviousWorldButton(_ sender: UIButton!) {
        let worldCurrent : String = viewController.modelController.getCurrentWorld()
        var worldLast : ModelController.WorldKeys = ModelController.WorldKeys.allValues.first!
        for worldNext in  ModelController.WorldKeys.allValues.reversed() {
            if worldLast.rawValue == worldCurrent {
                buttonNextWorld.isEnabled  = allNodesReady
                buttonNextWorld.backgroundColor = (allNodesReady) ? Colors.blue : Colors.lightGray
                
                if worldNext != ModelController.WorldKeys.allValues.first {
                    buttonPreviousWorld.isEnabled  = true
                    buttonPreviousWorld.backgroundColor  = Colors.blue
                }
                else {
                    buttonPreviousWorld.isEnabled  = false
                    buttonPreviousWorld.backgroundColor  = Colors.lightGray
                }
                
                viewController.modelController.selectModel(worldNext.rawValue)
                break
            }
            worldLast  = worldNext
        }
        viewController.modelController.findNextFreeLevel()
        viewController.rotateToNextModel()
        updateScene()
    }
    
    func actionNextWorldButton(_ sender: UIButton!) {
        let worldCurrent : String = viewController.modelController.getCurrentWorld()
        var worldLast : ModelController.WorldKeys = ModelController.WorldKeys.allValues.last!
        for worldNext in  ModelController.WorldKeys.allValues {
            if worldLast.rawValue == worldCurrent  && allNodesReady {
                buttonPreviousWorld.isEnabled  = true
                buttonPreviousWorld.backgroundColor =   Colors.blue
                
                if worldNext != ModelController.WorldKeys.allValues.last {
                    buttonNextWorld.isEnabled  = allNodesReady
                    buttonNextWorld.backgroundColor  = (allNodesReady) ? Colors.blue : Colors.lightGray
                }
                else {
                    buttonNextWorld.isEnabled  = false
                    buttonNextWorld.backgroundColor  = Colors.lightGray
                }
                
                viewController.modelController.selectModel(worldNext.rawValue)
                break
            }
            worldLast  = worldNext
        }
        viewController.modelController.findNextFreeLevel()
        viewController.rotateToNextModel()
        updateScene()
    }
    
    func actionExitButton(_ sender: UIButton!) {
        let alert = UIAlertController(title: "Do you like exit the game?", message: "Current state will not be stored.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: { action in
            exit(0)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func createLabels() {
        let model : Model = viewController.modelController.pageModels[selectedModelIndex]
        
        labelWorld = SKLabelNode(fontNamed:"Helvetica Neue")
        labelWorld.text = model.world;
        labelWorld.fontSize = Scales.fontSizeLabel
        labelWorld.position = CGPoint(x: Scales.width/2 , y: Scales.height - Scales.top - Scales.buttonHeight / 2)
        labelWorld.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        labelWorld.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        labelWorld.fontColor = Colors.darkGrey
        self.addChild(labelWorld)
        
        labelNameOfLevel = SKLabelNode(fontNamed:"Helvetica Neue UltraLight")
        labelNameOfLevel.text = NSLocalizedString("LEVEL", comment:"Level ") + model.getName();
        labelNameOfLevel.fontSize = Scales.fontSizeLabel
        labelNameOfLevel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        labelNameOfLevel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        labelNameOfLevel.fontColor = Colors.black
        self.addChild(labelNameOfLevel)
        
        labelBest = SKLabelNode(fontNamed:"Helvetica Neue UltraLight")
        labelBest.text = "Best \(model.getDistanceBest())"
        labelBest.fontSize = Scales.fontSizeLabel
        labelBest.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        labelBest.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        labelBest.fontColor = Colors.black
        self.addChild(labelBest)
        
        labelResult = SKLabelNode(fontNamed:"Helvetica Neue UltraLight")
        labelResult.text = (model.isComplete() || model.isReady()) ? "Result \(Model.getDistance(model.nodesSelected))" : ""
        labelResult.fontSize = Scales.fontSizeLabel
        labelResult.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        labelResult.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        labelResult.fontColor = Colors.black
        self.addChild(labelResult)
        
        labelHelp = SKLabelNode(fontNamed:"Helvetica Neue UltraLight")
        labelHelp.text = NSLocalizedString("LEVEL_HELP", comment:"Help text for level");
        labelHelp.fontSize = Scales.fontSizeLabel
        labelHelp.position = CGPoint(x: Scales.width / 2, y: Scales.bottom + Scales.bannerBottom)
        labelHelp.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        labelHelp.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        labelHelp.fontColor = Colors.darkGrey
        labelHelp.alpha = 0
        self.addChild(labelHelp)
    }
    
    func createNodes() {
        let indexMax = viewController.modelController.pageModels.count
        var index = 0
        while index < indexMax {
            let position = getLocation(index)
            let radius = radiusLevel
            let alpha = CGFloat(1.0)
            let animate : Bool = (index == selectedModelIndex)
            let circle:SKShapeNode = LevelScene.createcircle(radius, position: position, color: getColorOfLevel(index), alpha: alpha, lineWidth: Scales.lineWidth, animate: animate, name : String(index))
            self.addChild(circle)
            circles.append(circle)
            
            let label = SKLabelNode(fontNamed:"Helvetica Neue Light")
            label.text = viewController.modelController.pageModels[index].getName();
            label.name = String(index)
            label.fontSize = Scales.fontSizeLabel
            label.position =  position
            label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
            label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
            label.fontColor = Colors.white
            self.addChild(label)
            circlesText.append(label)
            index += 1
        }
    }
    
    func fadeInHelpText() {
        if !isTapped {
            let fadeAction = SKAction.fadeAlpha(to: 1.0, duration: 3.0)
            labelHelp.run(fadeAction)
        }
    }
    
    func fadeOutHelpText() {
        let fadeAction = SKAction.fadeAlpha(to: 0.0, duration: 3.0)
        labelHelp.run(fadeAction)
        isTapped = true
    }
    
    func updateScene() {
        findActiveIndex()
        updateNodes()
        updateElements()
    }
    
    func findActiveIndex() {
        let indexMax = viewController.modelController.pageModels.count
        var minXPositon:CGFloat = 10000
        var index = 0
        while index < indexMax {
            let position = getLocation(index)
            if (minXPositon > position.x) {
                minXPositon = position.x
                selectedModelIndex = index
            }
            index += 1
        }
    }
    
    var allNodesReady = true
    
    
    func updateNodes() {
        let indexMax = viewController.modelController.pageModels.count
        var index = 0
        allNodesReady = true
        while index < indexMax {
            circles[index].position = getLocation(index)
            circles[index].fillColor = getColorOfLevel(index)
            circlesText[index].position = getLocation(index)
            let animate : Bool = (index == selectedModelIndex)
            let font = animate ? "Helvetica Neue": "Helvetica Neue Light"
            circlesText[index].fontName = font
            circlesText[index].fontSize = Scales.fontSizeLabel
            circlesText[index].text = viewController.modelController.pageModels[index].getName();
            
            if circles[index].fillColor != Colors.green {
                allNodesReady = false
            }
            updateAnimationOfCircle(circles[index], animate: (index == selectedModelIndex))
            index += 1
        }
    }
    
    func updateElements() {
        
        let model : Model = viewController.modelController.pageModels[selectedModelIndex]
        labelWorld.text = model.world;
        
        // Move buttons to right position
        buttonFeatures.frame = CGRect( x: Scales.left,  y: getButtonYPosition() , width: buttonFeatures.frame.width, height: buttonFeatures.frame.height)
        buttonPlayLevel.frame = CGRect(x: Scales.width  - Scales.buttonWidth - Scales.right,  y: getButtonYPosition() , width: buttonPlayLevel.frame.width, height: buttonPlayLevel.frame.height)
        
        if allNodesReady {
            buttonNextWorld.isEnabled  = allNodesReady
            buttonNextWorld.backgroundColor = (allNodesReady) ? Colors.blue : Colors.lightGray
        }
        
        // 1. row
        labelNameOfLevel.text = NSLocalizedString("LEVEL", comment:"Level") + " " + model.getName();
        labelNameOfLevel.position = CGPoint(x: getLabelXPosition(), y:  getLabelYPosition(5.0))
        
        // 2. row
        if model.getDistanceBest() == Float.infinity {
            labelBest.text = ""
        } else {
            let best = model.getDistanceBest()
            let best_string = DataViewController.getFormattedString(value: best)
            labelBest.text = NSLocalizedString("BEST", comment:"Best") + " \(best_string)"
        }
        labelBest.position = CGPoint(x: getLabelXPosition(), y:  getLabelYPosition(6.0))
        
        // 3. row
        let distance = Model.getDistance(model.nodesSelected)
        let distance_string = DataViewController.getFormattedString(value: distance)
        
        labelResult.text = (model.isComplete() || model.isReady()) ? NSLocalizedString("RESULT", comment:"Result") + " \(distance_string)" : ""
        labelResult.position = CGPoint(x: getLabelXPosition(), y:  getLabelYPosition(7.0))
        
    }
    
    func getLabelYPosition(_ index : CGFloat) -> CGFloat {
        return (self.size.height * (1.0 - index / 14.0 ))
    }
    
    func getButtonYPosition() -> CGFloat {
        return Scales.height - Scales.bottom
    }
    
    
    func getLabelXPosition() -> CGFloat {
        return self.centerLarge.x
    }
    
    func setSelectedModel(_ index: Int) {
        selectedModelIndex = index
    }
    
    func getColorOfLevel(_ index : Int) -> UIColor {
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
    
    internal static func createcircle(_ radius : CGFloat, position : CGPoint, color : SKColor, alpha: CGFloat = 1.0, lineWidth:CGFloat = 1, animate:Bool = false, name : String = "") ->  SKShapeNode {
        let circle = SKShapeNode(circleOfRadius: radius)
        circle.position = position
        circle.isAntialiased = true
        circle.alpha = alpha
        circle.name = name
        circle.fillColor = color
        circle.glowWidth = 0.0
        return circle
    }
    
    func updateAnimationOfCircle(_ circle : SKShapeNode, animate :Bool) {
        
        // restore inital state
        circle.removeAllActions()
        circle.setScale(1.0)
        
        // add new animation
        if animate {
            let waitAction = SKAction.wait(forDuration: 0.8)
            let growAction = SKAction.scale(by: 1.3, duration: 0.3)
            let shrinkAction = growAction.reversed()
            let backAndForthSequence = SKAction.sequence([waitAction, growAction, shrinkAction])
            circle.run(SKAction.repeatForever(backAndForthSequence))
            if selectedModelIndex <= viewController.modelController.getIndexOfNextFreeLevel()  ||
                PlateisProducts.store.isProductPurchased(PlateisProducts.SkipLevelsRage) {
                if Colors.darkGrey == getColorOfLevel(selectedModelIndex) {
                    circle.fillColor = Colors.blue
                    buttonPlayLevel.backgroundColor = Colors.blue
                    buttonPlayLevel.setTitle(NSLocalizedString("PLAY", comment:"Play"), for: UIControlState())
                } else if Colors.green == getColorOfLevel(selectedModelIndex) {
                    buttonPlayLevel.backgroundColor = circle.fillColor
                    buttonPlayLevel.setTitle(NSLocalizedString("VIEW", comment: "View"), for: UIControlState())
                } else if Colors.red == getColorOfLevel(selectedModelIndex) {
                    buttonPlayLevel.backgroundColor = circle.fillColor
                    buttonPlayLevel.setTitle(NSLocalizedString("COMPLETE", comment:"Complete"), for: UIControlState())
                }  else {
                    buttonPlayLevel.backgroundColor = circle.fillColor
                    buttonPlayLevel.setTitle(NSLocalizedString("IMPROVE", comment: "Improve"), for: UIControlState())
                }
            } else {
                circle.fillColor = Colors.lightGray
                buttonPlayLevel.backgroundColor = Colors.lightGray
                buttonPlayLevel.setTitle(NSLocalizedString("LOCKED", comment:"Locked"), for: UIControlState())
            }
        }
    }
    
    func getLocation(_ index:Int) -> CGPoint {
        let numberOfNodes = 16
        let angle : CGFloat = 3.14 * CGFloat(index) / CGFloat(numberOfNodes) * 2
        let xLocation :CGFloat =  centerLarge.x + radiusLargeX * sin(angle + gamma + gammaOffset)
        let yLocation :CGFloat =  centerLarge.y + radiusLargeY * cos(angle + gamma + gammaOffset)
        return CGPoint(x: Int(xLocation), y: Int(yLocation))
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let sprite:SKNode = self.atPoint(location)
            if (sprite.name  != nil && !sprite.name!.isEmpty ) {
                let index : Int = Int(sprite.name!)!
                if index <= viewController.modelController.getIndexOfNextFreeLevel()  ||  PlateisProducts.store.isProductPurchased(PlateisProducts.SkipLevelsRage) {
                    viewController.actionOpenGame(index)
                    buttonFeatures.frame = CGRect(x : -Scales.buttonWidth, y: 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
                    buttonPlayLevel.frame = CGRect(x : -Scales.buttonWidth, y: 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
                }
            }
        }
    }
    
    
}
