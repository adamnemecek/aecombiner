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

class ChartTopNode: SKNode {
    var xScaleFactor:Double = 1.0
    var yScaleFactor:Double = 1.0
    var parameters = ChartParameters()
    var nameOfParameters = "Untitled"
    var border:CGFloat = 10.0
    var colour = NSColor.blackColor()
    
    convenience init (xScaleFactor:Double, yScaleFactor:Double, parameters:ChartParameters, nameOfParameters:String, border:CGFloat, colour:NSColor)
    {
        self.init()
        self.xScaleFactor = xScaleFactor
        self.yScaleFactor = yScaleFactor
        self.parameters = parameters
        self.nameOfParameters = nameOfParameters
        self.border = border
        self.colour = colour
    }
    
    
    func autolocateAndChartParameters()
    {
        //autolocate to bottom left axis
        self.position = CGPoint(x: Double(self.border/2.0), y: Double(self.border/2.0)-(self.parameters.minParam*self.yScaleFactor))
        //reset the x to far left
        var xVal:Double = 0.0
        //process the parameters
        for var row:Int = 0; row<self.parameters.values.count; ++row
        {
            let value = self.parameters.values[row]
            let node = SKSpriteNode(imageNamed: "ball")
            node.color = self.colour
            node.colorBlendFactor = 1.0
            node.zPosition = CGFloat(row)
            node.physicsBody?.dynamic = false
            self.addChild(node)
            node.position = CGPoint(x: xVal, y: value*self.yScaleFactor)
            xVal += self.xScaleFactor
        }

    }
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
        self.addChild(sprite)

    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    
}
