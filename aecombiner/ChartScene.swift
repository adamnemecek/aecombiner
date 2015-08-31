//
//  ChartScene.swift
//  g
//
//  Created by David JM Lewis on 12/08/2015.
//  Copyright (c) 2015 djml.eu. All rights reserved.
//
import SpriteKit

let kButtonName_ZoomIn = "inZoom"
let kButtonName_ZoomOut = "outZoom"
let kButtonName_ZoomZero = "zeroZoom"


let kMinifyDefault:CGFloat = 0.5
let kMagnifyDefault:CGFloat = 2.0



class ChartScene: SKScene {
    
    // MARK: - Var
    var chartCursorState:ChartCursorStates = .Hand
    var mouseClickDownPoint = CGPoint(x: 0.0, y: 0.0)
    var minifyValue = kMinifyDefault
    var magnifyValue = kMagnifyDefault
    
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
    
    func selectedDataPointsArrayFromNodes()->[ChartDataPointsFromNode]
    {
        var arrayOfPoints = [ChartDataPointsFromNode]()
        self.enumerateChildNodesWithName(kNodeName_DataSet) { (node, found) -> Void in
            let points = (node as! DataSetNode).selectedDataPointsWithName()
            if points.chartDataPoints.count > 0
            {
                arrayOfPoints.append(points)
            }
        }
        return arrayOfPoints
    }

    
    func autoLocateAndChartAllDataSets()
    {
        self.enumerateChildNodesWithName(kNodeName_DataSet) { (node, found) -> Void in
            (node as! DataSetNode).autolocateAndChartDataSet()
        }

    }
    
    func reSortAllDataSets()
    {
        self.enumerateChildNodesWithName(kNodeName_DataSet) { (node, found) -> Void in
            (node as! DataSetNode).reSortYourDataSet()
        }
    }
    
    func unSortAllDataSets()
    {
        self.enumerateChildNodesWithName(kNodeName_DataSet) { (node, found) -> Void in
            (node as! DataSetNode).unSortYourDataSet()
        }
    }
    
    func reSortThisChartDataSet(dataSetName dataSetName:String?)
    {
        self.enumerateChildNodesWithName(kNodeName_DataSet) { (node, found) -> Void in
            guard let dsNode = (node as? DataSetNode) else {return}
            if dataSetName == nil || dsNode.dataSetName == dataSetName
            {
                dsNode.reSortYourDataSet()
            }
        }
        
    }
    
    func unSortThisChartDataSet(dataSetName dataSetName:String?)
    {
        self.enumerateChildNodesWithName(kNodeName_DataSet) { (node, found) -> Void in
            guard let dsNode = (node as? DataSetNode) else {return}
            if dataSetName == nil || dsNode.dataSetName == dataSetName
            {
                dsNode.unSortYourDataSet()
            }
        }
        
    }

    
    func reChartTheseDataSets(dataSetNameOrNil dataSetName:String?)
    {
        self.enumerateChildNodesWithName(kNodeName_DataSet) { (node, found) -> Void in
            guard let dsNode = (node as? DataSetNode) else {return}
            if dataSetName == nil || dsNode.dataSetName == dataSetName
            {
                dsNode.autolocateAndChartDataSet()
            }
        }
        
    }
    
    func plotNewChartDataSet(dataSet dataSet:ChartDataSet, nameOfChartDataSet:String)
    {
        self.removeDataSetNodes()
        let topNode = DataSetNode(dataSet: dataSet, nameOfChartDataSet: nameOfChartDataSet, colour:kColour_Unselected)
        self.addChild(topNode)
        self.reChartTheseDataSets(dataSetNameOrNil: nameOfChartDataSet)
    }
    
    
    func clearSelectedPointsArray()
    {
        self.enumerateChildNodesWithName(kNodeName_DataSet) { (topnode, found) -> Void in
            guard let dsNode = (topnode as? DataSetNode) else {return}
            dsNode.selectedDataPoints = ChartDataPointsArray()
        }
    }
    
    func rebuildSelectedPointsArray(rectNode:SKNode)
    {
        self.enumerateChildNodesWithName(kNodeName_DataSet) { (topnode, found) -> Void in
            guard let dsNode = (topnode as? DataSetNode) else {return}
            dsNode.selectedDataPoints = ChartDataPointsArray()
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

    }
    
    override func mouseDown(theEvent: NSEvent) {
        /* Called when a mouse click occurs */
        
        switch self.chartCursorState
        {
        case .Hand:
            self.mouseClickDownPoint = theEvent.locationInNode(self)
        case .Crosshair:
            self.removeRectNodes()
            self.clearSelectedPointsArray()
            let rectNode = SKShapeNode(rect: CGRectZero)
            rectNode.name = kNodeName_SelectionRect
            rectNode.strokeColor = kColour_Selected
            self.addChild(rectNode)
            rectNode.position = theEvent.locationInNode(self)

        case .ZoomIn:
            self.enumerateChildNodesWithName(kNodeName_DataSet) { (topnode, found) -> Void in
                let dsNode = (topnode as! DataSetNode)
                let newMousePoint = theEvent.locationInNode(dsNode)
                dsNode.zoomToThisPoint(zoomFactor: self.magnifyValue, point: newMousePoint)
            }
        case .ZoomOut:
            self.enumerateChildNodesWithName(kNodeName_DataSet) { (topnode, found) -> Void in
                let dsNode = (topnode as! DataSetNode)
                let newMousePoint = theEvent.locationInNode(dsNode)
                dsNode.zoomToThisPoint(zoomFactor: self.minifyValue, point: newMousePoint)
            }

            /*default:
            return NSCursor.arrowCursor()*/
        }

   }
    
    override func mouseDragged(theEvent: NSEvent) {
        
        
        switch self.chartCursorState
        {
        case .Hand:
            let newMousePoint = theEvent.locationInNode(self)
            self.enumerateChildNodesWithName(kNodeName_DataSet) { (topnode, found) -> Void in
                let dsNode = (topnode as! DataSetNode)
                dsNode.position = CGPoint(x: dsNode.position.x+newMousePoint.x-self.mouseClickDownPoint.x, y: dsNode.position.y+newMousePoint.y-self.mouseClickDownPoint.y)
            }
            self.mouseClickDownPoint = newMousePoint
        case .Crosshair:
            guard let oldNode = self.childNodeWithName(kNodeName_SelectionRect)  else {break}
            let startPos = oldNode.position
            let newPos = theEvent.locationInNode(self)
            self.removeRectNodes()
            let rectNode = SKShapeNode(rect: CGRect(x: 0.0, y: 0.0, width: newPos.x-startPos.x, height: newPos.y-startPos.y))
            rectNode.name = kNodeName_SelectionRect
            rectNode.strokeColor = kColour_Selected
            self.addChild(rectNode)
            rectNode.position = startPos
        case .ZoomIn:
            break
        case .ZoomOut:
            break
            /*default:
            return NSCursor.arrowCursor()*/
        }
    }
    
    override func mouseUp(theEvent: NSEvent) {
        switch self.chartCursorState
        {
        case .Hand:
            break
        case .Crosshair:
            guard let rectNode = self.childNodeWithName(kNodeName_SelectionRect)  else {break}
            self.rebuildSelectedPointsArray(rectNode)
            self.removeRectNodes()
        case .ZoomIn:
            break
        case .ZoomOut:
            break
            /*default:
            return NSCursor.arrowCursor()*/
            
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    
}
