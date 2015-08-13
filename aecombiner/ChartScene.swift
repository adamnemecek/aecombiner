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
        sprite.setScale(0.5)
        self.addChild(sprite)

    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    
    func chartParameters(parameters parameters:ChartParameters)
    {
        self.removeAllChildren()
        var xVal:Double = 10.0
        for value in parameters.values
        {
            let node = SKSpriteNode(imageNamed: "ball")
            node.setScale(0.05)
            node.physicsBody?.dynamic = false
            node.position = CGPoint(x: xVal, y: value*10)
            self.addChild(node)
            xVal++
        }

    }
}
