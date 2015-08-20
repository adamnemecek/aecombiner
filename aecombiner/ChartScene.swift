//
//  ChartScene.swift
//  g
//
//  Created by David JM Lewis on 12/08/2015.
//  Copyright (c) 2015 djml.eu. All rights reserved.
//

import SpriteKit

let kBorderDefaultSize = 20.0  // single border
let kNodeName_DataPoint = "p"
let kNodeName_DataSet = "s"
let kNodeName_SelectionRect = "r"
let kNodeName_ZoomButton = "z"

let kButtonName_ZoomIn = "+"
let kButtonName_ZoomOut = "-"
let kButtonName_ZoomZero = "z0"


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
    var dataPoints = [ChartDataPoint]()
    var nameOfDataSet:String = ""
}

class ButtonNode: SKSpriteNode {
    convenience init (position:CGPoint, imageName:String)
    {
        self.init(imageNamed: imageName)
        self.userInteractionEnabled = true
        self.name = kNodeName_ZoomButton
        self.position = position
        self.anchorPoint = CGPoint(x: 0.0, y: 0.0)
    }
    
    override func mouseDown(theEvent: NSEvent) {
        guard let name = self.name, let scene = self.parent as? ChartScene else {return}
            switch name {
                case kButtonName_ZoomIn, kButtonName_ZoomOut, kButtonName_ZoomZero:
                    scene.zoomScale(name)
                default:
                break
        }
        
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
    var axesExtent = ChartDataPoint(xvalue: 1.0, yvalue: 1.0)
    var parameters = ChartDataSet()
    var border:Double = kBorderDefaultSize
    var colour = kColour_Unselected
    var sortDirection = kAscending
    var dataSetName:String? = "Untitled"
    var selectedDataPoints = [ChartDataPoint]()
    
    convenience init (sceneSize:ChartDataPoint, parameters:ChartDataSet, nameOfParameters:String?, colour:NSColor)
    {
        self.init()
        self.name = kNodeName_DataSet
        self.dataSetName = nameOfParameters
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
            let node = DataPointNode(imageNamed: "ball")
            node.initialiseParameters(self.parameters.dataPoints[row], colour: self.colour, yScale: self.yScale, xScale: self.xScale, zPos: row)
            self.addChild(node)
            node.position = CGPoint(x: Double(row), y: node.dataPoint.yValue)
        }

    }
}


class ChartScene: SKScene {
    
    func zoomScale(zoomDirection:String)
    {
        
    }

    
    func removeRectNodes()
    {
        self.enumerateChildNodesWithName(kNodeName_SelectionRect) { (node, found) -> Void in
            node.removeFromParent()
        }
    }
    
    func removeDataSetNodes()
    {
        self.enumerateChildNodesWithName(kNodeName_DataSet) { (node, found) -> Void in
            node.removeFromParent()
       }
    }
    
    func autoLocateAndChartAllParameters()
    {
        self.enumerateChildNodesWithName(kNodeName_DataSet) { (node, found) -> Void in
            (node as! DataSetNode).autolocateAndChartParameters()
        }

    }
    
    func resortAllDataSets()
    {
        self.enumerateChildNodesWithName(kNodeName_DataSet) { (node, found) -> Void in
            (node as! DataSetNode).reSortYourParameters()
        }
    }
    
    func reSortTheseParameters(dataSetName dataSetName:String)
    {
        self.enumerateChildNodesWithName(kNodeName_DataSet) { (node, found) -> Void in
            guard let dsNode = (node as? DataSetNode) else {return}
            if dsNode.dataSetName == dataSetName
            {
                dsNode.reSortYourParameters()
            }
        }

    }

    func chartTheseParameters(parameters parameters:ChartDataSet, nameOfParameters:String?)
    {
        self.removeDataSetNodes()
        let topNode = DataSetNode(sceneSize: ChartDataPoint(xvalue:Double(self.size.width),yvalue:Double(self.size.height)), parameters: parameters, nameOfParameters: nameOfParameters, colour:kColour_Unselected)
        self.addChild(topNode)
        topNode.autolocateAndChartParameters()
    }
    
    func rebuildSelectedPointsArray(rectNode:SKNode)
    {
        self.enumerateChildNodesWithName(kNodeName_DataSet) { (topnode, found) -> Void in
            let dsNode = (topnode as! DataSetNode)
            dsNode.selectedDataPoints = [ChartDataPoint]()
            topnode.enumerateChildNodesWithName(kNodeName_DataPoint) { (pointnode, foundpoint) -> Void in
                let ptNode = (pointnode as! DataPointNode)
                if rectNode.containsPoint(topnode.convertPoint(ptNode.position, toNode: self))
                {
                    (topnode as! DataSetNode).selectedDataPoints.append(ptNode.dataPoint)
                    ptNode.color = kColour_Selected
                }
                else
                {
                    ptNode.color = kColour_Unselected
                }
            }
        }
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here*/
        self.addChild(ButtonNode(position: CGPoint(x: 5, y: 5), imageName: "zoomIn"))
        self.addChild(ButtonNode(position: CGPoint(x: 25, y: 5), imageName: "zoomOut"))
        self.addChild(ButtonNode(position: CGPoint(x: 45, y: 5), imageName: "zoomZero"))
    }
    
    override func mouseDown(theEvent: NSEvent) {
        /* Called when a mouse click occurs */
        self.removeRectNodes()
        let rectNode = SKShapeNode(rect: CGRectZero)
        rectNode.name = kNodeName_SelectionRect
        rectNode.strokeColor = kColour_Selected
        self.addChild(rectNode)
        rectNode.position = theEvent.locationInNode(self)
   }
    
    override func mouseDragged(theEvent: NSEvent) {
        guard let oldNode = self.childNodeWithName(kNodeName_SelectionRect)  else {return}
        let startPos = oldNode.position
        let newPos = theEvent.locationInNode(self)
        self.removeRectNodes()
        let rectNode = SKShapeNode(rect: CGRect(x: 0.0, y: 0.0, width: newPos.x-startPos.x, height: newPos.y-startPos.y))
        rectNode.name = kNodeName_SelectionRect
        rectNode.strokeColor = kColour_Selected
        self.addChild(rectNode)
        rectNode.position = startPos
    }
    
    override func mouseUp(theEvent: NSEvent) {
        guard let rectNode = self.childNodeWithName(kNodeName_SelectionRect)  else {return}
        self.rebuildSelectedPointsArray(rectNode)
        self.removeRectNodes()
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    
}
