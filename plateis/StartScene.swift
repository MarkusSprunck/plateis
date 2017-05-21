//
//  StartScene.swift
//  PLATEIS
//
//  Copyright (c) 2016-2017 Markus Sprunck. All rights reserved.
//
//  This class shows the start scene and the inital start button.
//  In the case the button is pressed it opens the first level
//  view.

import SpriteKit

class StartScene: SKScene {
    
    private var viewController : DataViewController
    
    private var buttonStart : UIButton!
    
    private var labelTitle  : SKLabelNode!
    
    private var labelSwitch: SKLabelNode!
    
    private var switchButton : UISwitch!
    
    private var labelDescriptions : [SKLabelNode] = []
    
    private func createBackground() {
        self.backgroundColor = Colors.white
    }
    
    private func createTitle () {
        // create label
        labelTitle = SKLabelNode(fontNamed:"Helvetica Neue UltraLight")
        labelTitle.text = "P L A T E I S "
        
        // position
        labelTitle.position = CGPoint(x: Scales.width * 0.5, y: Scales.height * 0.83)
        
        // rendering style
        labelTitle.fontSize = Scales.fontSizeLabel * 2
        labelTitle.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        labelTitle.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        labelTitle.fontColor = Colors.black
        self.addChild(labelTitle)
        
        // show title
        labelTitle.alpha = 1
    }
    
    private func createDescription() {
        // distance
        let deltaY : CGFloat = Scales.fontSizeLabel * 1.5
        
        // create first label
        labelDescriptions.append(SKLabelNode(fontNamed:"Helvetica Neue UltraLight"));
        labelDescriptions[0].verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        labelDescriptions[0].horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        labelDescriptions[0].alpha = 0
        labelDescriptions[0].fontSize = Scales.fontSizeLabel
        labelDescriptions[0].fontColor = Colors.black
        
        // line 1
        labelDescriptions[0].position =  CGPoint(x: size.width * 0.5, y: Scales.height * 0.4 - 0 * deltaY + Scales.bottom)
        labelDescriptions[0].text = NSLocalizedString("DESCRIPTION_0", comment:"Finding the shortest path between");
        self.addChild(labelDescriptions[0]);
        
        // line 2
        labelDescriptions.append(labelDescriptions[0].copy() as! SKLabelNode)
        labelDescriptions[1].position =  CGPoint(x: size.width * 0.5, y: Scales.height * 0.4 - 1 * deltaY + Scales.bottom)
        labelDescriptions[1].text = NSLocalizedString("DESCRIPTION_1", comment:"some nodes is simple, but with an");
        labelDescriptions[1].alpha = 0
        self.addChild(labelDescriptions[1]);
        
        // line 3
        labelDescriptions.append(labelDescriptions[0].copy() as! SKLabelNode)
        labelDescriptions[2].position =  CGPoint(x: size.width * 0.5, y: Scales.height * 0.4 - 2 * deltaY + Scales.bottom)
        labelDescriptions[2].text = NSLocalizedString("DESCRIPTION_2", comment:"increasing number of nodes");
        labelDescriptions[2].alpha = 0
        self.addChild(labelDescriptions[2]);
        
        // line 4
        labelDescriptions.append(labelDescriptions[0].copy() as! SKLabelNode)
        labelDescriptions[3].position =  CGPoint(x: size.width * 0.5, y: Scales.height * 0.4 - 3 * deltaY + Scales.bottom)
        labelDescriptions[3].text = NSLocalizedString("DESCRIPTION_3", comment:"the task gets extremely");
        labelDescriptions[3].alpha = 0
        self.addChild(labelDescriptions[3]);
        
        // line 5
        labelDescriptions.append(labelDescriptions[0].copy() as! SKLabelNode)
        labelDescriptions[4].position =  CGPoint(x: size.width * 0.5, y: Scales.height * 0.4 - 4 * deltaY + Scales.bottom)
        labelDescriptions[4].text = NSLocalizedString("DESCRIPTION_4", comment:"difficult to solve.");
        labelDescriptions[4].alpha = 0
        self.addChild(labelDescriptions[4]);
    }
    
    private func getLabelYPosition(_ index : CGFloat) -> CGFloat {
        return Scales.height * CGFloat(0.5) - CGFloat(40.0) * index
    }
    
    private func createStartButton(){
        // create
        buttonStart = UIButton(type: UIButtonType.custom)
        
        // define size
        buttonStart.frame = CGRect(x : 0, y: 0, width : Scales.buttonWidth*1.2, height : Scales.buttonHeight*1.2)
        
        // define look and feel
        buttonStart.setTitle(NSLocalizedString("START", comment:"Start"), for: UIControlState())
        buttonStart.titleLabel!.font = UIFont(name: "Helvetica", size: Scales.fontSizeButton*1.2 )
        buttonStart.backgroundColor = Colors.blue
        buttonStart.layer.cornerRadius = 0.5 * buttonStart.bounds.height
        buttonStart.layer.borderWidth = 0
        buttonStart.alpha = 0
        buttonStart.center = CGPoint(x : Scales.width * 0.5, y: Scales.height * 0.35)
        
        // add button to view
        viewController.view.addSubview(buttonStart)
        
        // register handler
        buttonStart.addTarget(self, action: #selector(StartScene.actionStartButton(_:)), for: UIControlEvents.touchUpInside)
    }
    
    private func createSwitchControl(){
        switchButton = UISwitch(frame: CGRect(x: size.width * 0.5 - Scales.fontSizeLabel, y: Scales.height * 0.83,  width:Scales.fontSizeLabel, height:Scales.fontSizeLabel))
        
        switchButton.isOn  = UserDefaults.standard.bool(forKey: "expertMode")
        switchButton.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        viewController.view.addSubview(switchButton)
        
        labelSwitch = SKLabelNode(fontNamed:"Helvetica Neue Light")
        labelSwitch.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        labelSwitch.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        labelSwitch.alpha = 1.0
        labelSwitch.fontSize = Scales.fontSizeLabel
        labelSwitch.fontColor = Colors.darkGrey
        labelSwitch.position =  CGPoint(x: size.width * 0.5, y: Scales.height * 0.07)
        labelSwitch.text = NSLocalizedString("SWITCH", comment:"Select model");
        self.addChild(labelSwitch);
        
    }
    
    func actionStartButton(_ sender: UIButton!) {
        viewController.actionStart()
    }
    
    func hide() {
        labelTitle.alpha = 0
        buttonStart.alpha = 0
        for label in labelDescriptions {
            label.alpha = 0
        }
        switchButton.alpha = 0
    }
    
    func switchChanged(sender: UISwitch!){
        
        if (sender.isOn) {
            labelSwitch.fontColor =  Colors.black ;
        } else {
            labelSwitch.fontColor = Colors.lightGray;
        }
        
        viewController.modelController.savePageModels()
        
        UserDefaults.standard.set(sender.isOn, forKey: "expertMode")
        UserDefaults.standard.synchronize()
        
        viewController.modelController.loadModel()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    init(size:CGSize, viewController:DataViewController) {
        self.viewController = viewController
        super.init(size:size)
        
        // create all ui elements
        self.removeAllChildren()
        createBackground()
        createStartButton()
        createTitle()
        createDescription()
        createSwitchControl()
        
        // show controls with delay
        buttonStart.fadeIn(1.0)
        for label in labelDescriptions {
            label.run(SKAction.fadeAlpha(to: 1.0, duration: 3.0))
        }
        print("start scene init ready")
    }
    
}
