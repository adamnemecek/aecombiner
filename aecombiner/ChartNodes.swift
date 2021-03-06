//
//  ChartNodes.swift
//  aecombiner
//
//  Created by David Lewis on 21/08/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Foundation
import SpriteKit

let kNodeName_DataPoint = "p"
let kNodeName_DataSet = "s"
let kNodeName_SelectionRect = "r"
let kNodeName_ZoomButton = "z"
let kNodeName_LabelContainer = "l"

let kColour_Selected = NSColor.redColor()
let kColour_Unselected = NSColor.greenColor()

let kBorderDefaultSize:CGFloat = 30.0  // single border

struct ChartBorders {
    var top = kBorderDefaultSize
    var bottom = kBorderDefaultSize
    var left = kBorderDefaultSize
    var right = kBorderDefaultSize
}

class DataPointNode: SKSpriteNode {

    var dataPoint:ChartDataPoint = ChartDataPoint(xValue: 0.0, yValue: 0.0, colY: nil, colX: nil, rowNum: 0)
    
    func initialiseDataSet(dataPoint:ChartDataPoint, colour:NSColor, yScale:CGFloat, xScale:CGFloat, zPos:Int)
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
    var dataSet = ChartDataSet()
    var border:ChartBorders = ChartBorders()
    var colour = kColour_Unselected
    var sortDirection = kAscending
    var dataSetName:String = kDataSetDefaultName
    var selectedDataPoints = ChartDataPointsArray()
    
    convenience init (dataSet:ChartDataSet, nameOfChartDataSet:String?, colour:NSColor)
    {
        self.init()
        self.userInteractionEnabled = false
        self.name = kNodeName_DataSet
        self.dataSetName = nameOfChartDataSet == nil ? kDataSetDefaultName : nameOfChartDataSet!
        self.dataSet = dataSet
        self.colour = colour
    }
    
    func selectedDataPointsWithName()->ChartDataPointsFromNode
    {
        return ChartDataPointsFromNode(dataPoints: self.selectedDataPoints, name: self.dataSetName)
    }
    
    func zoomToThisPoint(zoomFactor zoomFactor:CGFloat, point:CGPoint)
    {
        self.zoom(zoomFactor)
        self.autolocate(centrePoint: point)
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
    }
    
    func adjustSortDirection(flipDirection flipDirection:Bool)
    {
        if flipDirection == true
        {
            switch self.sortDirection
            {
            case kAscending:
                self.sortDirection =  kDescending
            case kDescending:
                self.sortDirection =  kAscending
            default:
                break
            }
        }
    }
    
    func unSortYourDataSet(flipDirection flipDirection:Bool)
    {
        if !self.dataSet.xyType
        {
            self.adjustSortDirection(flipDirection: flipDirection)
            switch self.sortDirection
            {
            case kAscending:
                self.dataSet.dataPoints.sortInPlace(){$0.xValue > $1.xValue}
            case kDescending:
                self.dataSet.dataPoints.sortInPlace(){$0.xValue < $1.xValue}
            default:
                break
            }
            self.autolocateAndChartDataSet(sortFirst: false)
        }
    }
    
    func reSortYourDataSet(flipDirection flipDirection:Bool)
    {
        if !self.dataSet.xyType
        {
            self.adjustSortDirection(flipDirection: flipDirection)
            switch self.sortDirection
            {
            case kAscending:
                self.dataSet.dataPoints.sortInPlace(){$0.yValue > $1.yValue}
            case kDescending:
                self.dataSet.dataPoints.sortInPlace(){$0.yValue < $1.yValue}
            default:
                break
            }
            self.dataSet.renumberXvaluesToRowNumberIfNotXYtype()
            self.autolocateAndChartDataSet(sortFirst: false)
        }
    }
    
    func swapXYForDataSet()
    {
        self.dataSet.swapXandY()
        self.autolocateAndChartDataSet(sortFirst: false)
   }
    
    func sceneSize()->(yExtent:CGFloat, xExent:CGFloat)
    {
        return (self.scene!.size.height, self.scene!.size.width)
    }
    
    func calculateScalesForXandY()
    {
        // yxScale is the range between min and max parameter divided into the XY axis length
        // if the range is 0 we get divide by zero and so we make a range of 1 point
        let yrange:CGFloat = dataSet.maxYvalue == dataSet.minYvalue ? 1.0 : CGFloat(dataSet.maxYvalue-dataSet.minYvalue)
        let xrange:CGFloat = dataSet.maxXvalue == dataSet.minXvalue ? 1.0 : CGFloat(dataSet.maxXvalue-dataSet.minXvalue)
        
        self.yScale = (self.sceneSize().yExtent-self.border.top-self.border.bottom)/yrange
        self.xScale = (self.sceneSize().xExent-self.border.left-self.border.right)/xrange
    }

    func midPointOfDataDistribution()->CGPoint
    {
        return CGPoint(x: ((self.dataSet.minXvalue+self.dataSet.maxXvalue)/2.0), y: ((self.dataSet.minYvalue+self.dataSet.maxYvalue)/2.0))
    }
    
    
    func autolocate(centrePoint centrePoint:CGPoint)
    {
        //autolocate to  centre axes
        
        //find the mid point of scene in scene coords
        let screenMid = CGPoint(x: self.sceneSize().xExent/2.0, y: self.sceneSize().yExtent/2.0)
        //translate the screen mid into our coords taking into account hte scale etc
        let screenMidInSelf = self.convertPoint(screenMid, fromNode: self.scene!)
        //calculate how far the 0,0 must move to align the screen centre in our coords with the mid point of the data distribution
        let newZero = CGPoint(x: screenMidInSelf.x-centrePoint.x, y: screenMidInSelf.y-centrePoint.y)
        //move the 0,0 to the new position translated back into scene coords
        self.position = self.convertPoint(newZero, toNode: self.scene!)

    }
    
    
    func autolocateAndChartDataSet(sortFirst sortFirst:Bool)
    {
        //process the dataSet
        self.removeAllChildren()
        self.calculateScalesForXandY()
        self.autolocate(centrePoint: self.midPointOfDataDistribution())
        
        if sortFirst == true
        {
            self.reSortYourDataSet(flipDirection: false)
        }
        for var row:Int = 0; row<self.dataSet.dataPoints.count; ++row
        {
            let node = DataPointNode(imageNamed: "ball")
            node.initialiseDataSet(self.dataSet.dataPoints[row], colour: self.colour, yScale: self.yScale, xScale: self.xScale, zPos: row)
            self.addChild(node)
            node.position = CGPoint(x: node.dataPoint.xValue, y: node.dataPoint.yValue)
        }
        
    }
}

