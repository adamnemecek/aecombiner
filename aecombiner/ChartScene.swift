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
    var minParam:Double = Double(Int.max)
    var values = [Double]()
    
}

class ChartScene: SKScene {
    
    //var xScaleFactor:Double = 1.0
    //var yScaleFactor:Double = 1.0
    
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
    
    
    func chartParameters(var parameters parameters:ChartParameters)
    {
        parameters.values.sortInPlace()
        self.removeAllChildren()
        let border = self.size.width/20.0//border is twice the border for each side
        let xScaleFactor = Double(self.size.width-border)/Double(parameters.values.count)
        let yScaleFactor = Double(self.size.height-border)/(parameters.maxParam-parameters.minParam)
        let topNode = SKNode()
        self.addChild(topNode)
        topNode.position = CGPoint(x: Double(border/2.0), y: Double(border/2.0)-(parameters.minParam*yScaleFactor))
        var xVal:Double = 0.0
        for var row:Int = 0; row<parameters.values.count; ++row
        {
            let value = parameters.values[row]
            let node = SKSpriteNode(imageNamed: "ball")
            node.color = NSColor.redColor()
            node.colorBlendFactor = 1.0
            node.zPosition = CGFloat(row)
            node.physicsBody?.dynamic = false
            topNode.addChild(node)
            node.position = CGPoint(x: xVal, y: value*yScaleFactor)
            xVal += xScaleFactor
        }

    }
}
