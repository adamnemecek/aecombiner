//
//  ChartScene.swift
//  g
//
//  Created by David JM Lewis on 12/08/2015.
//  Copyright (c) 2015 djml.eu. All rights reserved.
//

import SpriteKit

let kChartTopLineName = "topline"


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
    
    func relocateTopLine(yValue yValue:Double)
    {
        guard let topline = self.childNodeWithName(kChartTopLineName) else {return}
        
        topline.position = CGPoint(x: topline.position.x, y: topline.position.y+1.0)
    }
    
    func autolocateAndChartParameters()
    {
        //autolocate to bottom left axis
        self.position = CGPoint(x: Double(self.border/2.0), y: Double(self.border/2.0)-(self.parameters.minParam*Double(self.yScale)))
        //set the x to bottom left
        var xVal:Double = 0.0
        //process the parameters
        self.removeAllChildren()
        
        let topline = SKShapeNode(rect: CGRect(x: 0.0, y: 0.0, width: 100.0, height: 2.00))
        topline.name = kChartTopLineName
        topline.strokeColor = NSColor.redColor()
        topline.fillColor = NSColor.redColor()
        topline.yScale = 1/self.yScale
        self.addChild(topline)
        topline.position = CGPoint(x: 50.0, y: 50.0)
        
        for var row:Int = 0; row<self.parameters.values.count; ++row
        {
            let value = self.parameters.values[row]
            let node = SKSpriteNode(imageNamed: "ball")
            node.name = "dot"
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
