//
//  ChartScene.swift
//  g
//
//  Created by David JM Lewis on 12/08/2015.
//  Copyright (c) 2015 djml.eu. All rights reserved.
//

import SpriteKit

let kBorderDefaultSize = 20.0  // single border

struct ChartDataPoint {
    var xValue:Double
    var yValue:Double
    
    init (xvalue:Double, yvalue:Double)
    {
        xValue = xvalue // usually the row in the data model
        yValue = yvalue
    }
}

struct ChartDataSet {
    var maxYvalue:Double = 0.0
    var minYvalue:Double = Double(Int.max)
    var dataPoints = [ChartDataPoint]()
    var nameOfDataSet:String = ""
}

class ChartTopNode: SKNode {
    var axesExtent = ChartDataPoint(xvalue: 1.0, yvalue: 1.0)
    var parameters = ChartDataSet()
    var border:Double = 10.0
    var colour = NSColor.blackColor()
    var sortDirection = kAscending
    
    convenience init (sceneSize:ChartDataPoint, parameters:ChartDataSet, nameOfParameters:String?, colour:NSColor)
    {
        self.init()
        self.name = nameOfParameters
        self.axesExtent = sceneSize
        self.parameters = parameters
        self.border = kBorderDefaultSize // single border
        self.colour = colour
    }
    
    func reSortYourParameters()
    {
        switch self.sortDirection
        {
        case kAscending:
            self.parameters.dataPoints.sortInPlace(){$0.yValue > $1.yValue}
            self.sortDirection = kDescending
        case kDescending:
            self.parameters.dataPoints.sortInPlace(){$0.yValue < $1.yValue}
            self.sortDirection = kAscending
      default:
            break
        }
        self.autolocateAndChartParameters()
    }
    
    func autolocateAndChartParameters()
    {
        // yScale is the range between min and max parameter divided into the Y axis length
        self.yScale = CGFloat((self.axesExtent.yValue-self.border*2.0)/(parameters.maxYvalue-parameters.minYvalue))
        
        //xScale is the length of x axis / number of parameters to plot -1, minus 1 because we need the number of gaps between poins which = num points -1
        self.xScale = CGFloat((self.axesExtent.xValue-self.border*2.0)/Double(parameters.dataPoints.count-1))
        //process the parameters
        self.removeAllChildren()
        
        //autolocate to bottom left axis in superviews coords, taking account of yscale. We always start with x = 0 so no effect of xScale
        self.position = CGPoint(x: self.border, y: (self.border)-(self.parameters.minYvalue*Double(self.yScale)))

        for var row:Int = 0; row<self.parameters.dataPoints.count; ++row
        {
            let value = self.parameters.dataPoints[row].yValue
            let node = SKSpriteNode(imageNamed: "ball")
            node.name = "dot"
            node.userInteractionEnabled = false
            node.color = self.colour
            node.colorBlendFactor = 1.0
            //correct for the top nodes yScale to avoid stretch of images
            node.yScale = 1/self.yScale
            node.xScale = 1/self.xScale
            node.zPosition = CGFloat(row)
            node.physicsBody?.dynamic = false
            self.addChild(node)
            node.position = CGPoint(x: Double(row), y: value)
        }

    }
}


class ChartScene: SKScene {
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here*/
    }
    
    override func mouseDown(theEvent: NSEvent) {
        /* Called when a mouse click occurs */
        
        
        let rectNode = SKShapeNode(rectOfSize: CGSize(width: 10.0, height: 10.0))
        rectNode.name = "rectNode"
        rectNode.strokeColor = NSColor.redColor()
        rectNode.position = theEvent.locationInNode(self)
        self.addChild(rectNode)
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        
        guard let rectNode = self.childNodeWithName("rectNode") else {return}
        rectNode.position = theEvent.locationInNode(self)
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    
}
