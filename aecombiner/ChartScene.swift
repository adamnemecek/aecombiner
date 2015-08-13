//
//  ChartScene.swift
//  g
//
//  Created by David JM Lewis on 12/08/2015.
//  Copyright (c) 2015 djml.eu. All rights reserved.
//

import SpriteKit

struct ChartParameters {
    var maxParam:Double = 0.0
    var minParam:Double = 0.0
    var values = [Double]()
    
}

class ChartScene: SKScene {
    
    var xScaleFactor:Double = 1.0
    var yScaleFactor:Double = 1.0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!";
        myLabel.fontSize = 45;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        self.addChild(myLabel)
*/
    }
    
    override func mouseDown(theEvent: NSEvent) {
        /* Called when a mouse click occurs */
        
        let loc = theEvent.locationInNode(self)
        print(loc)
        
        let sprite = SKSpriteNode(imageNamed: "ball")
        sprite.position = loc;
        self.addChild(sprite)

    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    
    func chartParameters(parameters parameters:ChartParameters)
    {
        self.removeAllChildren()
        self.xScaleFactor = Double(self.size.width)/Double(parameters.values.count)
        self.yScaleFactor = Double(self.size.height)/parameters.maxParam
        var xVal:Double = 0.0
        for value in parameters.values
        {
            let node = SKSpriteNode(imageNamed: "ball")
            node.physicsBody?.dynamic = false
            node.position = CGPoint(x: xVal, y: value*self.yScaleFactor)
            self.addChild(node)
            xVal += self.xScaleFactor
        }

    }
}
