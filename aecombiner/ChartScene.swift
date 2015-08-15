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
    var xSpacing:Double = 1.0
    var parameters = ChartParameters()
    var border:CGFloat = 10.0
    var colour = NSColor.blackColor()
    var sortDirection = kAscending
    
    convenience init (xSpacing:Double, yScale:CGFloat, parameters:ChartParameters, nameOfParameters:String?, border:CGFloat, colour:NSColor)
    {
        self.init()
        self.name = nameOfParameters
        self.yScale = yScale
        self.xSpacing = xSpacing
        self.parameters = parameters
        self.border = border
        self.colour = colour
    }
    
    func reSortYourParameters()
    {
        switch self.sortDirection
        {
        case kAscending:
            self.parameters.values.sortInPlace(>)//{$0 > $1}
            self.sortDirection = kDescending
        case kDescending:
            self.parameters.values.sortInPlace(<)//{$0 > $1}
            self.sortDirection = kAscending
      default:
            break
        }
        self.autolocateAndChartParameters()
    }
    
    func autolocateAndChartParameters()
    {
        //autolocate to bottom left axis
        self.position = CGPoint(x: Double(self.border/2.0), y: Double(self.border/2.0)-(self.parameters.minParam*Double(self.yScale)))
        //set the x to bottom left
        var xVal:Double = 0.0
        //process the parameters
        self.removeAllChildren()
        for var row:Int = 0; row<self.parameters.values.count; ++row
        {
            let value = self.parameters.values[row]
            let node = SKSpriteNode(imageNamed: "ball")
            node.userInteractionEnabled = true
            node.color = self.colour
            node.colorBlendFactor = 1.0
            //correct for the top nodes yScale to avoid stretch of images
            node.yScale = 1/self.yScale
            node.zPosition = CGFloat(row)
            node.physicsBody?.dynamic = false
            self.addChild(node)
            node.position = CGPoint(x: xVal, y: value)
            xVal += self.xSpacing
        }

    }
}


class ChartScene: SKScene {
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here*/
    }
    
    override func mouseDown(theEvent: NSEvent) {
        /* Called when a mouse click occurs */
        
        _ = theEvent.locationInNode(self)
        

    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    
}
