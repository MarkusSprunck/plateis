//
//  LevelScene.swift
//  SprunckOne
//
//  Copyright (c) 2016 Markus Sprunck. All rights reserved.
//

import SpriteKit

class LevelScene: SKScene {
    
    fileprivate var viewController:DataViewController
    
    fileprivate var labelNameOfLevel: SKLabelNode!
    
    fileprivate var labelBest : SKLabelNode!
    
    fileprivate var labelResult : SKLabelNode!
    
    fileprivate var labelWorld : SKLabelNode!
    
    fileprivate  var buttonPlayLevel : UIButton!
    
    fileprivate  var buttonGameCenter : UIButton!
    
    fileprivate  var buttonFeatures : UIButton!
    
    fileprivate  var buttonPreviousWorld : UIButton!
    
    fileprivate  var buttonNextWorld : UIButton!
    
    fileprivate var selectedModelIndex : Int = 0
    
    fileprivate var timerSnapToPosition = Timer()
    
    fileprivate var timerRenderModel = Timer()
    
    fileprivate var circles : [SKShapeNode] = []
    
    fileprivate var circlesText : [SKLabelNode] = []
    
    fileprivate var isTapped : Bool = false
    
    fileprivate var allNodesReady = true
    
    fileprivate var gamma:CGFloat = 0.0
    
    fileprivate var gammaOffset:CGFloat = -CGFloat(Double.pi/2)
    
    let defaults = UserDefaults.standard
    
    init(size:CGSize, viewController:DataViewController) {
        self.viewController = viewController
        super.init(size: size)
       
        // Restore default settings
        if let name = defaults.string(forKey: "selectedModelIndex") {
            print("restored setting selectedModelIndex \(name)")
            viewController.modelController.selectModel("\(name)")
        }
        
        if !viewController.modelController.pageModels.isEmpty {
            createBackground()
            createPlayButton()
            createLabels()
            createNodes()
            updateScene()
        }
        print("level scene init ready")
        
        
        GameCenterManager.calculateScore(models:viewController.modelController.allModels)
    }
    
    internal func showButtons() {
        buttonGameCenter.fadeIn(0.1)
        buttonPlayLevel.fadeIn(0.1)
        buttonFeatures.fadeIn(0.1)
        buttonNextWorld.fadeIn(0.1)
        buttonPreviousWorld.fadeIn(0.1)
    }
    
    internal func hideButtons() {
        buttonGameCenter.fadeOut(0.1)
        buttonPlayLevel.fadeOut(0.1)
        buttonFeatures.fadeOut(0.1)
        buttonNextWorld.fadeOut(0.1)
        buttonPreviousWorld.fadeOut(0.1)
    }
    
    internal func updateScene() {
        findActiveIndex()
        updateNodes()
        updateElements()
    }
    
    internal func getGamma() -> CGFloat {
        return gamma;
    }
    
    internal func setGamma(_ value:CGFloat)  {
        gamma = value;
    }
    
    internal func setGammaOffset(_ value:CGFloat)  {
        gammaOffset = value;
    }

    
    fileprivate func createBackground() {
        self.backgroundColor = Colors.white
    }
    
    fileprivate func createPlayButton(){
        
        print("current world = \(viewController.modelController.getCurrentWorld())")
        
        buttonPlayLevel = UIButton(type: UIButtonType.custom)
        buttonPlayLevel.frame = CGRect(x : 0, y: 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonPlayLevel.titleLabel!.font =  UIFont(name: "Helvetica", size: Scales.fontSizeButton)
        buttonPlayLevel.backgroundColor =  Colors.blue
        buttonPlayLevel.layer.cornerRadius = 0.5 * buttonPlayLevel.bounds.size.height
        buttonPlayLevel.layer.borderWidth = 0
        buttonPlayLevel.setTitle(NSLocalizedString("PLAY", comment:"Start game"), for: UIControlState())
        buttonPlayLevel.addTarget(self, action: #selector(LevelScene.actionPlayButton(_:)), for: UIControlEvents.touchUpInside)
        buttonPlayLevel.alpha = 0
        viewController.view.addSubview(buttonPlayLevel)
        
        
        buttonGameCenter = UIButton(type : UIButtonType.custom)
        buttonGameCenter.frame = CGRect(x : 0, y : 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonGameCenter.titleLabel!.font =  UIFont(name : "Helvetica", size : Scales.fontSizeButton)
        buttonGameCenter.backgroundColor =  Colors.blue
        buttonGameCenter.layer.cornerRadius = 0.5 * buttonPlayLevel.bounds.size.height
        buttonGameCenter.layer.borderWidth = 0
        buttonGameCenter.setTitle(NSLocalizedString("GAMECENTER", comment:"Game center"), for: UIControlState())
        buttonGameCenter.addTarget(self, action : #selector(LevelScene.actionGameCenterButton(_ : )), for : UIControlEvents.touchUpInside)
        buttonGameCenter.alpha = 0
        viewController.view.addSubview(buttonGameCenter)
        
        
        buttonFeatures = UIButton(type: UIButtonType.custom)
        buttonFeatures.frame = CGRect(x : 0, y :0, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonFeatures.titleLabel!.font =  UIFont(name: "Helvetica", size: Scales.fontSizeButton)
        buttonFeatures.backgroundColor =  Colors.blue
        buttonFeatures.layer.cornerRadius = 0.5 * buttonFeatures.bounds.size.height
        buttonFeatures.layer.borderWidth = 0
        buttonFeatures.setTitle(NSLocalizedString("FEATURES", comment:"Open In-App-Purcases"), for: UIControlState())
        buttonFeatures.addTarget(self, action: #selector(LevelScene.actionFeaturesButton(_:)), for: UIControlEvents.touchUpInside)
        buttonFeatures.alpha = 0
        viewController.view.addSubview(buttonFeatures)
        
        
        buttonPreviousWorld = UIButton(type: UIButtonType.custom)
        buttonPreviousWorld.frame =   CGRect(x : Scales.left, y: Scales.top , width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonPreviousWorld.titleLabel!.font =  UIFont(name: "Helvetica", size: Scales.fontSizeButton)
        buttonPreviousWorld.backgroundColor =   Colors.lightGray
        buttonPreviousWorld.layer.cornerRadius = 0.5 * buttonPreviousWorld.bounds.size.height
        buttonPreviousWorld.layer.borderWidth = 0
        buttonPreviousWorld.setTitle(NSLocalizedString("BACK", comment:"Previous world"), for: UIControlState())
        buttonPreviousWorld.addTarget(self, action: #selector(LevelScene.actionPreviousWorldButton(_:)), for: UIControlEvents.touchUpInside)
        buttonPreviousWorld.alpha = 0
        buttonPreviousWorld.isEnabled = viewController.modelController.getCurrentWorld() != ModelController.WorldKeys.random01.rawValue
        buttonPreviousWorld.backgroundColor = buttonPreviousWorld.isEnabled ? Colors.blue : Colors.lightGray
        viewController.view.addSubview(buttonPreviousWorld)
        
        
        buttonNextWorld = UIButton(type: UIButtonType.custom)
        buttonNextWorld.frame =    CGRect(x : (Scales.width - Scales.buttonWidth - Scales.right), y: Scales.top, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonNextWorld.titleLabel!.font =  UIFont(name: "Helvetica", size: Scales.fontSizeButton)
        buttonNextWorld.layer.cornerRadius = 0.5 * buttonNextWorld.bounds.size.height
        buttonNextWorld.layer.borderWidth = 0
        buttonNextWorld.isEnabled = viewController.modelController.getCurrentWorld() != ModelController.WorldKeys.random10.rawValue
        buttonNextWorld.backgroundColor = buttonNextWorld.isEnabled ? Colors.blue : Colors.lightGray
        buttonNextWorld.setTitle(NSLocalizedString("NEXT", comment:"Next world"), for:UIControlState())
        buttonNextWorld.addTarget(self, action: #selector(LevelScene.actionNextWorldButton(_:)), for: UIControlEvents.touchUpInside)
        buttonNextWorld.alpha = 0
        viewController.view.addSubview(buttonNextWorld)
    }
    
    internal func actionPlayButton(_ sender: UIButton!) {
        viewController.actionOpenGame(selectedModelIndex)
    }
    
    internal func actionGameCenterButton(_ sender: UIButton!) {
        viewController.showLeaderboard()
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
    
    @objc fileprivate func actionPreviousWorldButton(_ sender: UIButton!) {
        let isSkipWorldAllowed = PlateisProducts.store.isProductPurchased(PlateisProducts.SkipWorlds)
        let isNextWorldAllowed = allNodesReady  || isSkipWorldAllowed
        let worldCurrent : String = viewController.modelController.getCurrentWorld()
        var worldFirst : ModelController.WorldKeys = ModelController.WorldKeys.allValues.first!
        for worldNext in  ModelController.WorldKeys.allValues.reversed() {
            if worldFirst.rawValue == worldCurrent {
                buttonNextWorld.isEnabled  = isNextWorldAllowed
                buttonNextWorld.backgroundColor = (isNextWorldAllowed) ? Colors.blue : Colors.lightGray
                
                if worldNext != ModelController.WorldKeys.allValues.first {
                    buttonPreviousWorld.isEnabled  = true
                    buttonPreviousWorld.backgroundColor  = Colors.blue
                }
                else {
                    buttonPreviousWorld.isEnabled  = false
                    buttonPreviousWorld.backgroundColor  = Colors.lightGray
                }
                
                viewController.modelController.selectModel(worldNext.rawValue)
                defaults.set("\(worldNext.rawValue)", forKey: "selectedModelIndex")
                print("store setting selected model \(worldNext.rawValue)")
                
                break
            }
            worldFirst  = worldNext
        }
        viewController.modelController.findNextFreeLevel()
        viewController.rotateToNextModel()
        updateScene()
    }
    
    @objc fileprivate func actionNextWorldButton(_ sender: UIButton!) {
        let worldCurrent : String = viewController.modelController.getCurrentWorld()
        let isSkipWorldAllowed = PlateisProducts.store.isProductPurchased(PlateisProducts.SkipWorlds)
        let isNextWorldAllowed = allNodesReady  || isSkipWorldAllowed
        var worldLast : ModelController.WorldKeys = ModelController.WorldKeys.allValues.last!
        for worldNext in  ModelController.WorldKeys.allValues {
            if worldLast.rawValue == worldCurrent && isNextWorldAllowed {
                buttonPreviousWorld.isEnabled  = true
                buttonPreviousWorld.backgroundColor =   Colors.blue
                
                if worldNext != ModelController.WorldKeys.allValues.last {
                    buttonNextWorld.isEnabled  = true
                    buttonNextWorld.backgroundColor  = Colors.blue
                } else {
                    buttonNextWorld.isEnabled  = false
                    buttonNextWorld.backgroundColor  = Colors.lightGray
                }
                viewController.modelController.selectModel(worldNext.rawValue)
                defaults.set("\(worldNext.rawValue)", forKey: "selectedModelIndex")
                print("store setting selected model \(worldNext.rawValue)")
                
                break
            }
            worldLast  = worldNext
        }
        viewController.modelController.findNextFreeLevel()
        viewController.rotateToNextModel()
        updateScene()
    }
    
    fileprivate func actionExitButton(_ sender: UIButton!) {
        let alert = UIAlertController(title: "Do you like exit the game?", message: "Current state will not be stored.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: { action in
            exit(0)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func createLabels() {
        let model : Model = viewController.modelController.pageModels[selectedModelIndex]
        
        labelWorld = SKLabelNode(fontNamed:"Helvetica Neue")
        labelWorld.text = model.world;
        labelWorld.fontSize = Scales.fontSizeLabel
        labelWorld.position = CGPoint(x: Scales.width/2 , y: Scales.height - Scales.top - Scales.buttonHeight / 2)
        labelWorld.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        labelWorld.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        labelWorld.fontColor = Colors.lightGray
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
        
    }
    
    fileprivate func createNodes() {
        let indexMax = viewController.modelController.pageModels.count
        var index = 0
        while index < indexMax {
            let position = getLocation(index)
            let radius = Scales.radiusLevel
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
    
    
    fileprivate func findActiveIndex() {
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
    
    fileprivate func updateNodes() {
        let indexMax = viewController.modelController.pageModels.count
        var index = 0
        allNodesReady = true
        
        while index < indexMax {
            let currentModel = viewController.modelController.pageModels[index]
            circles[index].position = getLocation(index)
            circles[index].fillColor = getColorOfLevel(index)
            circlesText[index].position = getLocation(index)
            let animate : Bool = (index == selectedModelIndex)
            let font = animate ? "Helvetica Neue": "Helvetica Neue Light"
            circlesText[index].fontName = font
            circlesText[index].fontSize = Scales.fontSizeLabel
            circlesText[index].text = currentModel.getName();
            
            if getColorOfLevel(index) != Colors.green {
                allNodesReady = false
            }
            
            updateAnimationOfCircle(circles[index], animate: (index == selectedModelIndex))
            index += 1
        }
    }
    
    internal func updateElements() {
        
        let model : Model = viewController.modelController.pageModels[selectedModelIndex]
        labelWorld.text = model.world;
        
        // Move buttons to right position
        buttonFeatures.frame = CGRect( x: Scales.left,  y: getButtonYPosition() , width: buttonFeatures.frame.width, height: buttonFeatures.frame.height)
        buttonGameCenter.frame = CGRect(x : (Scales.width/2 - Scales.buttonWidth/2), y : Scales.height -  Scales.bottom, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonPlayLevel.frame = CGRect(x: Scales.width  - Scales.buttonWidth - Scales.right,  y: getButtonYPosition() , width: buttonPlayLevel.frame.width, height: buttonPlayLevel.frame.height)
        
        // En/Disable skip next button
        let isSkipWorldAllowed = PlateisProducts.store.isProductPurchased(PlateisProducts.SkipWorlds)
        let isNextWorldAllowed = allNodesReady  || isSkipWorldAllowed
        let isNotLast = viewController.modelController.getCurrentWorld() != ModelController.WorldKeys.random10.rawValue
        buttonNextWorld.isEnabled  = isNextWorldAllowed && isNotLast
        buttonNextWorld.backgroundColor = buttonNextWorld.isEnabled ? Colors.blue : Colors.lightGray
        
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
    
    fileprivate func getLabelYPosition(_ index : CGFloat) -> CGFloat {
        return (self.size.height * (1.0 - index / 14.0 ))
    }
    
    fileprivate func getButtonYPosition() -> CGFloat {
        return Scales.height - Scales.bottom
    }
    
    
    fileprivate func getLabelXPosition() -> CGFloat {
        return Scales.centerLarge.x
    }
    
    internal func setSelectedModel(_ index: Int) {
        selectedModelIndex = index
    }
    
    fileprivate func getColorOfLevel(_ index : Int) -> UIColor {
        var color = Colors.darkGrey
        if viewController.modelController.pageModels[index].isComplete() {
            color = Colors.green
        } else if viewController.modelController.pageModels[index].isIncomplete() {
            color = Colors.yellow
        } else if viewController.modelController.pageModels[index].getSelectedCount() > 0 {
            color = Colors.red
        }
        return color
    }
    
    internal static func createcircle(_ radius : CGFloat, position : CGPoint, color : SKColor, alpha: CGFloat = 1.0, lineWidth:CGFloat = 1, animate:Bool = false, name : String = "") ->  SKShapeNode {
        let circle = SKShapeNode(circleOfRadius: radius)
        circle.position = position
        circle.isAntialiased = false
        circle.alpha = alpha
        circle.name = name
        circle.fillColor = color
        circle.strokeColor = color
        circle.glowWidth = 0.0
        circle.lineWidth = 0.0
        return circle
    }
    
    fileprivate func updateAnimationOfCircle(_ circle : SKShapeNode, animate :Bool) {
        
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
        }
    }
    
    fileprivate func getLocation(_ index:Int) -> CGPoint {
        let numberOfNodes = 16
        let angle : CGFloat = 3.14 * CGFloat(index) / CGFloat(numberOfNodes) * 2
        let xLocation :CGFloat =  Scales.centerLarge.x + Scales.radiusLargeX * sin(angle + gamma + gammaOffset)
        let yLocation :CGFloat =  Scales.centerLarge.y + Scales.radiusLargeY * cos(angle + gamma + gammaOffset)
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
                viewController.actionOpenGame(index)
                buttonFeatures.frame = CGRect(x : -Scales.buttonWidth, y: 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
                buttonPlayLevel.frame = CGRect(x : -Scales.buttonWidth, y: 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
            }
        }
    }

}
