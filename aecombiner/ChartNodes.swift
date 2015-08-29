//
//  ChartNodes.swift
//  aecombiner
//
//  Created by David Lewis on 21/08/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Foundation
import SpriteKit

let kBorderDefaultSize:CGFloat = 10.0  // single border
let kNodeName_DataPoint = "p"
let kNodeName_DataSet = "s"
let kNodeName_SelectionRect = "r"
let kNodeName_ZoomButton = "z"

let kDataSetDefaultName = "Untitled"


let kColour_Selected = NSColor.redColor()
let kColour_Unselected = NSColor.greenColor()

struct ChartBorders {
    var top = kBorderDefaultSize
    var bottom = kBorderDefaultSize
    var left = kBorderDefaultSize
    var right = kBorderDefaultSize
}

struct ChartDataPoint {
    var xValue:Double
    var yValue:Double
    
    init (xvalue:Double, yvalue:Double)
    {
        xValue = xvalue // usually the row in the data model
        yValue = yvalue
    }
}

class ChartDataSet {
    var maxYvalue:Double = 0.0
    var minYvalue:Double = Double(Int.max)
    var maxXvalue:Double = 0.0
    var minXvalue:Double = Double(Int.max)
    var dataPoints = [ChartDataPoint]()
    var nameOfDataSet:String = kDataSetDefaultName
    
    convenience init(data: DataMatrix, forColumnIndex columnIndex:Int)
    {
        self.init()
        guard columnIndex>0 && columnIndex<data.count else {return}
        
        for var r:Int = 0; r<data.count; r++
        {
            let row = data[r]
            guard
                row[columnIndex].characters.count>0,
                let Yvalue = Double(row[columnIndex])
                else {continue}
            let Xvalue = Double(r)
            self.minYvalue = fmin(self.minYvalue,Yvalue)
            self.maxYvalue = fmax(self.maxYvalue,Yvalue)
            self.minXvalue = fmin(self.minXvalue,Xvalue)
            self.maxXvalue = fmax(self.maxXvalue,Xvalue)
            // we store the row number as the X value and when we sort on the Y value we can always map back to the row in the data for extracting other values. !! If we sort the CSVdata we are lost
            self.dataPoints.append(ChartDataPoint(xvalue: Xvalue, yvalue: Yvalue))
        }
    }
}


class DataPointNode: SKSpriteNode {
    var dataPoint:ChartDataPoint = ChartDataPoint(xvalue: 0.0, yvalue: 0.0)
    
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
    var selectedDataPoints = [ChartDataPoint]()
    
    convenience init (dataSet:ChartDataSet, nameOfChartDataSet:String?, colour:NSColor)
    {
        self.init()
        self.userInteractionEnabled = false
        self.name = kNodeName_DataSet
        self.dataSetName = nameOfChartDataSet == nil ? kDataSetDefaultName : nameOfChartDataSet!
        self.dataSet = dataSet
        self.colour = colour
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
    
    func unSortYourDataSet()
    {
        switch self.sortDirection
        {
        case kAscending:
            self.dataSet.dataPoints.sortInPlace(){$0.xValue > $1.xValue}
            self.sortDirection = kDescending
        case kDescending:
            self.dataSet.dataPoints.sortInPlace(){$0.xValue < $1.xValue}
            self.sortDirection = kAscending
        default:
            break
        }
        self.autolocateAndChartDataSet()
    }
    
    func reSortYourDataSet()
    {
        switch self.sortDirection
        {
        case kAscending:
            self.dataSet.dataPoints.sortInPlace(){$0.yValue > $1.yValue}
            self.sortDirection = kDescending
        case kDescending:
            self.dataSet.dataPoints.sortInPlace(){$0.yValue < $1.yValue}
            self.sortDirection = kAscending
        default:
            break
        }
        self.autolocateAndChartDataSet()
    }
    
    func sceneSize()->(yExtent:CGFloat, xExent:CGFloat)
    {
        return (self.scene!.size.height, self.scene!.size.width)
    }
    
    func calculateScalesForXandY()
    {
        let sceneSize = self.sceneSize()
        // yxScale is the range between min and max parameter divided into the Y axis length
        self.yScale = (sceneSize.yExtent-self.border.top-self.border.bottom)/CGFloat(dataSet.maxYvalue-dataSet.minYvalue)
        self.xScale = (sceneSize.xExent-self.border.left-self.border.right)/CGFloat(dataSet.maxXvalue-dataSet.minXvalue)
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
    
    
    func autolocateAndChartDataSet()
    {
        //process the dataSet
        self.removeAllChildren()
        self.calculateScalesForXandY()
        self.autolocate(centrePoint: self.midPointOfDataDistribution())
        
        for var row:Int = 0; row<self.dataSet.dataPoints.count; ++row
        {
            let node = DataPointNode(imageNamed: "ball")
            node.initialiseDataSet(self.dataSet.dataPoints[row], colour: self.colour, yScale: self.yScale, xScale: self.xScale, zPos: row)
            self.addChild(node)
            node.position = CGPoint(x: Double(row), y: node.dataPoint.yValue)
        }
        
    }
}
