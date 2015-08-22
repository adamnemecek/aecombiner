//
//  ChartNodes.swift
//  aecombiner
//
//  Created by David Lewis on 21/08/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Foundation
import SpriteKit

let kBorderDefaultSize:CGFloat = 20.0  // single border
let kNodeName_DataPoint = "p"
let kNodeName_DataSet = "s"
let kNodeName_SelectionRect = "r"
let kNodeName_ZoomButton = "z"



let kColour_Selected = NSColor.redColor()
let kColour_Unselected = NSColor.greenColor()



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
    var maxXvalue:Double = 0.0
    var minXvalue:Double = Double(Int.max)
    var dataPoints = [ChartDataPoint]()
    var nameOfDataSet:String = ""
}

class ButtonNode: SKSpriteNode {
    
    var direction:String = kButtonName_ZoomIn
    
    convenience init (position:CGPoint, imageName:String)
    {
        self.init(imageNamed: imageName)
        self.direction = imageName
        self.userInteractionEnabled = true
        self.name = kNodeName_ZoomButton
        self.position = position
        self.anchorPoint = CGPoint(x: 0.0, y: 0.0)
    }
    
    override func mouseDown(theEvent: NSEvent) {
        (self.parent as? ChartScene)?.zoomScale(self.direction)
        
    }
}

class DataPointNode: SKSpriteNode {
    var dataPoint:ChartDataPoint = ChartDataPoint(xvalue: 0.0, yvalue: 0.0)
    
    func initialiseParameters(dataPoint:ChartDataPoint, colour:NSColor, yScale:CGFloat, xScale:CGFloat, zPos:Int)
    {
        self.dataPoint = dataPoint
        self.name = kNodeName_DataPoint
        self.userInteractionEnabled = false
        self.color = colour
        self.colorBlendFactor = 1.0
        self.blendMode = .Alpha
        //correct for the top nodes yScale to avoid stretch of images
        self.yScale = 1/yScale
        self.xScale = 1/xScale
        self.zPosition = CGFloat(zPos)
        self.physicsBody?.dynamic = false
    }
}

class DataSetNode: SKNode {
    var parameters = ChartDataSet()
    var border:CGFloat = kBorderDefaultSize
    var colour = kColour_Unselected
    var sortDirection = kAscending
    var dataSetName:String = "Untitled"
    var selectedDataPoints = [ChartDataPoint]()
    
    convenience init (parameters:ChartDataSet, nameOfParameters:String, colour:NSColor)
    {
        self.init()
        self.userInteractionEnabled = false
        self.name = kNodeName_DataSet
        self.dataSetName = nameOfParameters
        self.parameters = parameters
        self.border = kBorderDefaultSize // single border
        self.colour = colour
    }
    
    func zoom(zoomFactor:CGFloat)
    {
        self.yScale *= zoomFactor
        self.xScale *= zoomFactor
        
        self.enumerateChildNodesWithName(kNodeName_DataPoint) { (node, found) -> Void in
            guard let dpNode = (node as? DataPointNode) else {return}
            dpNode.yScale = 1/self.yScale
            dpNode.xScale = 1/self.xScale
        }
        self.autolocate()
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
    
    func sceneSize()->(yExtent:CGFloat, xExent:CGFloat)
    {
        return (self.scene!.size.height, self.scene!.size.width)
    }
    
    func calculateScalesForXandY()
    {
        let sceneSize = self.sceneSize()
        // yScale is the range between min and max parameter divided into the Y axis length
        self.yScale = (sceneSize.yExtent-self.border*2.0)/CGFloat(parameters.maxYvalue-parameters.minYvalue)
        
        //xScale is the length of x axis / number of parameters to plot -1, minus 1 because we need the number of gaps between poins which = num points -1
        self.xScale = (sceneSize.xExent-self.border*2.0)/CGFloat(parameters.dataPoints.count-1)
    }

    func locateToThisClickPointInScene(clickPoint clickPoint:CGPoint)
    {
        let convertedClickPoint = self.convertPoint(clickPoint, fromNode: self.scene!)
        
    }
    
    func autolocate()
    {
        //autolocate to  centre axes
        
        //find the mid point of scene in scene coords
        let screenMid = CGPoint(x: self.sceneSize().xExent/2.0, y: self.sceneSize().yExtent/2.0)
        //translate the screen mid into our coords taking into account hte scale etc
        let screenMidInSelf = self.convertPoint(screenMid, fromNode: self.scene!)
        //calculate how far the 0,0 must move to align the screen centre in our coords with the mid point of the data distribution
        let newZero = CGPoint(x: Double(screenMidInSelf.x)-((self.parameters.minXvalue+self.parameters.maxXvalue)/2.0), y: Double(screenMidInSelf.y)-((self.parameters.minYvalue+self.parameters.maxYvalue)/2.0))
        //move the 0,0 to the new position translated back into scene coords
        self.position = self.convertPoint(newZero, toNode: self.scene!)

    }
    
    
    func autolocateAndChartParameters()
    {
        //process the parameters
        self.removeAllChildren()
        self.calculateScalesForXandY()
        self.autolocate()
        
        for var row:Int = 0; row<self.parameters.dataPoints.count; ++row
        {
            let node = DataPointNode(imageNamed: "ball")
            node.initialiseParameters(self.parameters.dataPoints[row], colour: self.colour, yScale: self.yScale, xScale: self.xScale, zPos: row)
            self.addChild(node)
            node.position = CGPoint(x: Double(row), y: node.dataPoint.yValue)
        }
        
    }
}

