//
//  GameScene.swift
//  SprunckOne
//
//  Created by Markus Sprunck on 01/07/16.
//  Copyright (c) 2016 Markus Sprunck. All rights reserved.
//

import SpriteKit

class LevelScene: SKScene {
    
    private var viewController:DataViewController
    
    internal let PI_DIV_8 = CGFloat(M_PI / 8.0)
    
    private let labelDistanceFromTop: CGFloat = 190.0
    
    private var labelNameOfLevel: SKLabelNode!
    
    private var labelBest : SKLabelNode!
    
    private var labelResult : SKLabelNode!
    
    private var labelWorld : SKLabelNode!
    
    private var labelHelp : SKLabelNode!
    
    internal var buttonPlayLevel : UIButton!
    
    internal var buttonFeatures : UIButton!
    
    internal var buttonPreviousWorld : UIButton!
    
    internal var buttonNextWorld : UIButton!
    
    internal var gamma:CGFloat = 0.0
    
    internal var gammaOffset:CGFloat = -CGFloat(M_PI_2)
    
    private var selectedModelIndex : Int = 0
    
    internal var centerLarge : CGPoint = CGPoint(x: 0.0, y: 0.0)
    
    private var radiusLargeX : CGFloat = 0.0
    
    private var radiusLargeY : CGFloat = 0.0
    
    private var radiusLevel: CGFloat = 0.0
    
    private var timerSnapToPosition = NSTimer()
    
    private var timerRenderModel = NSTimer()
    
    private var circles : [SKShapeNode] = []
    
    private var circlesText : [SKLabelNode] = []
    
    private var isTapped : Bool = false
    
    init(size:CGSize, viewController:DataViewController) {
        self.viewController = viewController
        super.init(size: size)
        
        radiusLevel = viewController.width * 0.07
        radiusLargeX = (viewController.width -  Scales.left - Scales.right) * 0.5 - radiusLevel
        radiusLargeY = (viewController.height -  Scales.top - Scales.bottom - Scales.bannerTop*2 - Scales.bannerBottom*2 ) * 0.5 - radiusLevel
        centerLarge  = CGPoint(x: viewController.width * 0.5 , y:radiusLargeY + Scales.bottom + Scales.bannerBottom + radiusLevel)
        
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
        buttonPlayLevel = UIButton(type: UIButtonType.Custom)
        buttonPlayLevel.frame = CGRect(x : 0, y: 0, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonPlayLevel.titleLabel!.font =  UIFont(name: "Helvetica", size: Scales.fontSizeButton)
        buttonPlayLevel.backgroundColor =  Colors.blue
        buttonPlayLevel.layer.cornerRadius = 0.5 * buttonPlayLevel.bounds.size.height
        buttonPlayLevel.layer.borderWidth = 0
        buttonPlayLevel.setTitle(NSLocalizedString("PLAY", comment:"Start game"), forState: UIControlState.Normal)
        buttonPlayLevel.addTarget(self, action: #selector(LevelScene.actionPlayButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buttonPlayLevel.alpha = 0
        viewController.skview.addSubview(buttonPlayLevel)
        
        
        buttonFeatures = UIButton(type: UIButtonType.Custom)
        buttonFeatures.frame = CGRect(x : 0, y :0, width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonFeatures.titleLabel!.font =  UIFont(name: "Helvetica", size: Scales.fontSizeButton)
        buttonFeatures.backgroundColor =  Colors.blue
        buttonFeatures.layer.cornerRadius = 0.5 * buttonFeatures.bounds.size.height
        buttonFeatures.layer.borderWidth = 0
        buttonFeatures.setTitle(NSLocalizedString("FEATURES", comment:"Open In-App-Purcases"), forState: UIControlState.Normal)
        buttonFeatures.addTarget(self, action: #selector(LevelScene.actionFeaturesButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buttonFeatures.alpha = 0
        viewController.skview.addSubview(buttonFeatures)
        
        
        buttonPreviousWorld = UIButton(type: UIButtonType.Custom)
        buttonPreviousWorld.frame =   CGRect(x : Scales.left, y: Scales.top , width : Scales.buttonWidth, height : Scales.buttonHeight)
        buttonPreviousWorld.titleLabel!.font =  UIFont(name: "Helvetica", size: Scales.fontSizeButton)
        buttonPreviousWorld.backgroundColor =   Colors.grey
        buttonPreviousWorld.layer.cornerRadius = 0.5 * buttonPreviousWorld.bounds.size.height
        buttonPreviousWorld.layer.borderWidth = 0
        buttonPreviousWorld.setTitle(NSLocalizedString("BACK", comment:"Previous world"), forState: UIControlState.Normal)
        buttonPreviousWorld.addTarget(self, action: #selector(LevelScene.actionPreviousWorldButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buttonPreviousWorld.alpha = 0
        buttonPreviousWorld.enabled = false
        viewController.view.addSubview(buttonPreviousWorld)
        
        
        buttonNextWorld = UIButton(type: UIButtonType.Custom)
        buttonNextWorld.frame =    CGRect(x : (viewController.width - Scales.buttonWidth - Scales.right), y: Scales.top, width : Scales.buttonWidth, height : Scales.buttonHeight)
        
        buttonNextWorld.titleLabel!.font =  UIFont(name: "Helvetica", size: Scales.fontSizeButton)
        buttonNextWorld.backgroundColor =   Colors.blue
        buttonNextWorld.layer.cornerRadius = 0.5 * buttonNextWorld.bounds.size.height
        buttonNextWorld.layer.borderWidth = 0
        buttonNextWorld.setTitle(NSLocalizedString("NEXT", comment:"Next world"), forState:UIControlState.Normal)
        buttonNextWorld.addTarget(self, action: #selector(LevelScene.actionNextWorldButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buttonNextWorld.alpha = 0
        viewController.view.addSubview(buttonNextWorld)
    }
    
    internal func actionPlayButton(sender: UIButton!) {
        if selectedModelIndex <= viewController.modelController.getIndexOfNextFreeLevel() ||
            PlateisProducts.store.isProductPurchased(PlateisProducts.SkipLevelsRage) {
            viewController.actionOpenGame(selectedModelIndex)
        }
    }
    
    internal func actionFeaturesButton(sender: UIButton!) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let secondViewController = storyboard.instantiateViewControllerWithIdentifier("FeatureId") as UIViewController
        
        let window = UIApplication.sharedApplication().windows[0] as UIWindow
        UIView.transitionFromView(
            window.rootViewController!.view,
            toView: secondViewController.view,
            duration: 0.65,
            options: .TransitionCrossDissolve,
            completion: {
                finished in window.rootViewController = secondViewController
        })
        
    }
    
    func actionPreviousWorldButton(sender: UIButton!) {
        let worldCurrent : String = viewController.modelController.getCurrentWorld()
        var worldLast : ModelController.WorldKeys = ModelController.WorldKeys.allValues.first!
        for worldNext in  ModelController.WorldKeys.allValues.reverse() {
            if worldLast.rawValue == worldCurrent {
                buttonNextWorld.enabled  = true
                buttonNextWorld.backgroundColor =   Colors.blue
                
                if worldNext != ModelController.WorldKeys.allValues.first {
                    buttonPreviousWorld.enabled  = true
                    buttonPreviousWorld.backgroundColor  = Colors.blue
                }
                else {
                    buttonPreviousWorld.enabled  = false
                    buttonPreviousWorld.backgroundColor  = Colors.grey
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
    
    func actionNextWorldButton(sender: UIButton!) {
        let worldCurrent : String = viewController.modelController.getCurrentWorld()
        var worldLast : ModelController.WorldKeys = ModelController.WorldKeys.allValues.last!
        for worldNext in  ModelController.WorldKeys.allValues {
            if worldLast.rawValue == worldCurrent {
                buttonPreviousWorld.enabled  = true
                buttonPreviousWorld.backgroundColor =   Colors.blue
                
                
                if worldNext != ModelController.WorldKeys.allValues.last {
                    buttonNextWorld.enabled  = true
                    buttonNextWorld.backgroundColor  = Colors.blue
                }
                else {
                    buttonNextWorld.enabled  = false
                    buttonNextWorld.backgroundColor  = Colors.grey
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
    
    func actionExitButton(sender: UIButton!) {
        let alert = UIAlertController(title: "Do you like exit the game?", message: "Current state will not be stored.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default, handler: { action in
            exit(0)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    func createLabels() {
        let model : Model = viewController.modelController.pageModels[selectedModelIndex]
        
        labelWorld = SKLabelNode(fontNamed:"Helvetica Neue UltraLight")
        labelWorld.text = model.world;
        labelWorld.fontSize = Scales.fontSizeLabel
        labelWorld.position = CGPoint(x: viewController.width/2 , y: viewController.height - Scales.top - Scales.buttonHeight / 2)
        labelWorld.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        labelWorld.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        labelWorld.fontColor = Colors.black
        self.addChild(labelWorld)
        
        labelNameOfLevel = SKLabelNode(fontNamed:"Helvetica Neue UltraLight")
        labelNameOfLevel.text = NSLocalizedString("LEVEL", comment:"Level ") + model.getName();
        labelNameOfLevel.fontSize = Scales.fontSizeLabel
        labelNameOfLevel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        labelNameOfLevel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        labelNameOfLevel.fontColor = Colors.black
        self.addChild(labelNameOfLevel)
        
        labelBest = SKLabelNode(fontNamed:"Helvetica Neue UltraLight")
        labelBest.text = "Best \(model.getDistanceBest())"
        labelBest.fontSize = Scales.fontSizeLabel
        labelBest.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        labelBest.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        labelBest.fontColor = Colors.black
        self.addChild(labelBest)
        
        labelResult = SKLabelNode(fontNamed:"Helvetica Neue UltraLight")
        labelResult.text = (model.isComplete() || model.isReady()) ? "Result \(Model.getDistance(model.nodesSelected))" : ""
        labelResult.fontSize = Scales.fontSizeLabel
        labelResult.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        labelResult.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        labelResult.fontColor = Colors.black
        self.addChild(labelResult)
        
        labelHelp = SKLabelNode(fontNamed:"Helvetica Neue UltraLight")
        labelHelp.text = NSLocalizedString("LEVEL_HELP", comment:"Help text for level");
        labelHelp.fontSize = Scales.fontSizeLabel
        labelHelp.position = CGPoint(x: viewController.width / 2, y: viewController.height - Scales.top - Scales.bannerTop*2)
        labelHelp.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        labelHelp.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        labelHelp.fontColor = Colors.black
        labelHelp.alpha = 0
        self.addChild(labelHelp)
    }
    
    func createNodes() {
        let indexMax = viewController.modelController.pageModels.count
        var index = 0
        while index < indexMax {
            let position = getLocation(index)
            let radius = radiusLevel
            let lineWidth : CGFloat = 1.0
            let alpha = CGFloat(1.0)
            let animate : Bool = (index == selectedModelIndex)
            let circle:SKShapeNode = LevelScene.createcircle(radius, position: position, color: getColorOfLevel(index), alpha: alpha, lineWidth: lineWidth, animate: animate, name : String(index))
            self.addChild(circle)
            circles.append(circle)
            
            let label = SKLabelNode(fontNamed:"Helvetica Neue Light")
            label.text = viewController.modelController.pageModels[index].getName();
            label.name = String(index)
            label.fontSize = Scales.fontSizeLabel
            label.position =  position
            label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
            label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
            label.fontColor = Colors.white
            self.addChild(label)
            circlesText.append(label)
            index += 1
        }
    }
    
    func fadeInHelpText() {
        if !isTapped {
            let fadeAction = SKAction.fadeAlphaTo(1.0, duration: 3.0)
            labelHelp.runAction(fadeAction)
        }
    }
    
    func fadeOutHelpText() {
        let fadeAction = SKAction.fadeAlphaTo(0.0, duration: 3.0)
        labelHelp.runAction(fadeAction)
        isTapped = true
    }
    
    func updateScene() {
        findActiveIndex()
        updateNodes()
        updateLabels()
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
    
    
    func updateNodes() {
        let indexMax = viewController.modelController.pageModels.count
        var index = 0
        while index < indexMax {
            circles[index].position = getLocation(index)
            circles[index].fillColor = getColorOfLevel(index)
            circlesText[index].position = getLocation(index)
            let animate : Bool = (index == selectedModelIndex)
            let font = animate ? "Helvetica Neue": "Helvetica Neue Light"
            circlesText[index].fontName = font
            circlesText[index].fontSize = Scales.fontSizeLabel
            circlesText[index].text = viewController.modelController.pageModels[index].getName();
            
            updateAnimationOfCircle(circles[index], animate: (index == selectedModelIndex))
            index += 1
        }
    }
    
    func updateLabels() {
        
        self.viewController.updateSize(self.size)
        
        let model : Model = viewController.modelController.pageModels[selectedModelIndex]
        labelWorld.text = model.world;
        
        // Move buttons to right position
        buttonFeatures.frame = CGRectMake( Scales.left,  getButtonYPosition() , buttonFeatures.frame.width, buttonFeatures.frame.height)
        buttonPlayLevel.frame = CGRectMake(UIScreen.mainScreen().bounds.width  - Scales.buttonWidth - Scales.right,  getButtonYPosition() , buttonPlayLevel.frame.width, buttonPlayLevel.frame.height)
        
        // 2. row
        labelNameOfLevel.text = NSLocalizedString("LEVEL", comment:"Level") + " " + model.getName();
        labelNameOfLevel.position = CGPoint(x: getLabelXPosition(), y:  getLabelYPosition(5.0))
        
        // 3. row
        if model.getDistanceBest() == Float.infinity {
            labelBest.text = ""
        } else {
            labelBest.text = NSLocalizedString("BEST", comment:"Best") + " \(model.getDistanceBest())"
        }
        labelBest.position = CGPoint(x: getLabelXPosition(), y:  getLabelYPosition(6.0))
        
        // 4. row
        labelResult.text = (model.isComplete() || model.isReady()) ? NSLocalizedString("RESULT", comment:"Result") + " \(Model.getDistance(model.nodesSelected))" : ""
        labelResult.position = CGPoint(x: getLabelXPosition(), y:  getLabelYPosition(7.0))
        
    }
    
    func getLabelYPosition(index : CGFloat) -> CGFloat {
        return (self.size.height * (1.0 - index / 14.0 ))
    }
    
    func getButtonYPosition() -> CGFloat {
        return UIScreen.mainScreen().bounds.height - Scales.bottom
    }
    
    
    func getLabelXPosition() -> CGFloat {
        return self.centerLarge.x
    }
    
    func setSelectedModel(index: Int) {
        selectedModelIndex = index
    }
    
    func getColorOfLevel(index : Int) -> UIColor {
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
    
    internal static func createcircle(radius : CGFloat, position : CGPoint, color : SKColor, alpha: CGFloat = 1.0, lineWidth:CGFloat = 1, animate:Bool = false, name : String = "") ->  SKShapeNode {
        let circle = SKShapeNode(circleOfRadius: radius)
        circle.position = position
        circle.antialiased = true
        circle.alpha = alpha
        circle.name = name
        circle.fillColor = color
        circle.glowWidth = 0.0
        return circle
    }
    
    func updateAnimationOfCircle(circle : SKShapeNode, animate :Bool) {
        
        // restore inital state
        circle.removeAllActions()
        circle.setScale(1.0)
        
        // add new animation
        if animate {
            let waitAction = SKAction.waitForDuration(0.8)
            let growAction = SKAction.scaleBy(1.3, duration: 0.3)
            let shrinkAction = growAction.reversedAction()
            let backAndForthSequence = SKAction.sequence([waitAction, growAction, shrinkAction])
            circle.runAction(SKAction.repeatActionForever(backAndForthSequence))
            if selectedModelIndex <= viewController.modelController.getIndexOfNextFreeLevel()  ||
                PlateisProducts.store.isProductPurchased(PlateisProducts.SkipLevelsRage) {
                if Colors.darkGrey == getColorOfLevel(selectedModelIndex) {
                    circle.fillColor = Colors.blue
                    buttonPlayLevel.backgroundColor = Colors.blue
                    buttonPlayLevel.setTitle(NSLocalizedString("PLAY", comment:"Play"), forState: UIControlState.Normal)
                } else if Colors.green == getColorOfLevel(selectedModelIndex) {
                    buttonPlayLevel.backgroundColor = circle.fillColor
                    buttonPlayLevel.setTitle(NSLocalizedString("VIEW", comment: "View"), forState: UIControlState.Normal)
                } else if Colors.red == getColorOfLevel(selectedModelIndex) {
                    buttonPlayLevel.backgroundColor = circle.fillColor
                    buttonPlayLevel.setTitle(NSLocalizedString("COMPLETE", comment:"Complete"), forState: UIControlState.Normal)
                }  else {
                    buttonPlayLevel.backgroundColor = circle.fillColor
                    buttonPlayLevel.setTitle(NSLocalizedString("IMPROVE", comment: "Improve"), forState: UIControlState.Normal)
                }
            } else {
                circle.fillColor = Colors.lightGray
                buttonPlayLevel.backgroundColor = Colors.lightGray
                buttonPlayLevel.setTitle(NSLocalizedString("LOCKED", comment:"Locked"), forState: UIControlState.Normal)
            }
        }
    }
    
    func getLocation(index:Int) -> CGPoint {
        let numberOfNodes = 16
        let angle : CGFloat = 3.14 * CGFloat(index) / CGFloat(numberOfNodes) * 2
        let xLocation :CGFloat =  centerLarge.x + radiusLargeX * sin(angle + gamma + gammaOffset)
        let yLocation :CGFloat =  centerLarge.y + radiusLargeY * cos(angle + gamma + gammaOffset)
        return CGPoint(x: Int(xLocation), y: Int(yLocation))
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let location = touch.locationInNode(self)
            let sprite:SKNode = self.nodeAtPoint(location)
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
