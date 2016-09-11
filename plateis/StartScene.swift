//
//  StartScene.swift
//  PLATEIS
//
//  Created by Markus Sprunck on 01/07/16.
//  Copyright (c) 2016 Markus Sprunck. All rights reserved.
//
// This class shows the start scene and the inital start button.
// In the case the button is pressed it opens the first level
// view.

import SpriteKit

class StartScene: SKScene {
    
    private var viewController : DataViewController
    
    private var buttonStart : UIButton!
    
    private var labelTitle  : SKLabelNode!
    
    private var labelDescriptions : [SKLabelNode] = []
    
    init(size:CGSize, viewController:DataViewController) {
        self.viewController = viewController
        super.init(size:size)
        
        // create all ui elements
        self.removeAllChildren()
        createBackground()
        createStartButton()
        createTitle()
        createDescription()
        
        // show controls with delay
        buttonStart.fadeIn(1.0)
        for label in labelDescriptions {
            label.runAction(SKAction.fadeAlphaTo(1.0, duration: 3.0))
        }
        print("start scene init ready")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    private func createBackground() {
        let background = SKSpriteNode(imageNamed: "background-white")
        background.zPosition = -1
        background.position = CGPoint(x: viewController.width / 2, y: viewController.height / 2)
        background.setScale(2.0)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        addChild(background)
    }
    
    private func createTitle () {
        // create label
        labelTitle = SKLabelNode(fontNamed:"Helvetica Neue UltraLight")
        labelTitle.text = "P L A T E I S "
      
        // position
        labelTitle.position = CGPoint(x: viewController.width * 0.5, y: viewController.height * 0.80)
    
        // rendering style
        labelTitle.fontSize = 46
        labelTitle.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        labelTitle.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        labelTitle.fontColor = Colors.black
        self.addChild(labelTitle)
        
        // show title
        labelTitle.alpha = 1
    }
    
    private func createDescription() {
        // distance
        let deltaY : CGFloat = 30
        
        // create first label
        labelDescriptions.append(SKLabelNode(fontNamed:"Helvetica Neue UltraLight"));
        labelDescriptions[0].verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        labelDescriptions[0].horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        labelDescriptions[0].alpha = 0
        labelDescriptions[0].fontSize = 22
        labelDescriptions[0].fontColor = Colors.black
        
        // line 1
        labelDescriptions[0].position =  CGPoint(x: size.width * 0.5, y: viewController.height * 0.3 - 0 * deltaY)
        labelDescriptions[0].text = NSLocalizedString("DESCRIPTION_0", comment:"Finding the shortest path between");
        self.addChild(labelDescriptions[0]);

        // line 2
        labelDescriptions.append(labelDescriptions[0].copy() as! SKLabelNode)
        labelDescriptions[1].position =  CGPoint(x: size.width * 0.5, y: viewController.height * 0.3 - 1 * deltaY)
        labelDescriptions[1].text = NSLocalizedString("DESCRIPTION_1", comment:"some nodes is simple, but with an");
        labelDescriptions[1].alpha = 0
        self.addChild(labelDescriptions[1]);

        // line 3
        labelDescriptions.append(labelDescriptions[0].copy() as! SKLabelNode)
        labelDescriptions[2].position =  CGPoint(x: size.width * 0.5, y: viewController.height * 0.3 - 2 * deltaY)
        labelDescriptions[2].text = NSLocalizedString("DESCRIPTION_2", comment:"increasing number of nodes");
        labelDescriptions[2].alpha = 0
        self.addChild(labelDescriptions[2]);

        // line 4
        labelDescriptions.append(labelDescriptions[0].copy() as! SKLabelNode)
        labelDescriptions[3].position =  CGPoint(x: size.width * 0.5, y: viewController.height * 0.3 - 3 * deltaY)
        labelDescriptions[3].text = NSLocalizedString("DESCRIPTION_3", comment:"the task gets extremely");
        labelDescriptions[3].alpha = 0
        self.addChild(labelDescriptions[3]);
        
        // line 5
        labelDescriptions.append(labelDescriptions[0].copy() as! SKLabelNode)
        labelDescriptions[4].position =  CGPoint(x: size.width * 0.5, y: viewController.height * 0.3 - 4 * deltaY)
        labelDescriptions[4].text = NSLocalizedString("DESCRIPTION_4", comment:"difficult to solve.");
        labelDescriptions[4].alpha = 0
        self.addChild(labelDescriptions[4]);
    }
    
    private func getLabelYPosition(index : CGFloat) -> CGFloat {
        return viewController.height * CGFloat(0.5) - CGFloat(40.0) * index
    }
    
    private func createStartButton(){
        // create
        buttonStart = UIButton(type: UIButtonType.Custom)
        
        // define size
        buttonStart.frame = CGRect(x : 0, y: 0, width : Scales.buttonWidth*1.5, height : Scales.buttonHeight*1.5)
       
        // define look and feel
        buttonStart.setTitle("Start", forState: UIControlState.Normal)
        buttonStart.titleLabel!.font = UIFont(name: "Helvetica", size: 24)
        buttonStart.backgroundColor = Colors.blue
        buttonStart.layer.cornerRadius = 0.5 * buttonStart.bounds.height
        buttonStart.layer.borderWidth = 0
        buttonStart.alpha = 0
        buttonStart.center = CGPoint(x : viewController.width * 0.5, y: viewController.height * 0.45)
    
        // add button to view
        viewController.view.addSubview(buttonStart)
        
        // register handler
        buttonStart.addTarget(self, action: #selector(StartScene.actionStartButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    internal func actionStartButton(sender: UIButton!) {
        viewController.actionStart()
    }
    
    internal func hide() {
        labelTitle.alpha = 0
        buttonStart.alpha = 0
        for label in labelDescriptions {
            label.alpha = 0
        }
    }
    
}
