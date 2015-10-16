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
    
    var buttonExportSelected:NSButton?

    
    // MARK: - Remove
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
    
    // MARK: - DataPoints
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

    
    func autoLocateAndChartAllDataSets(sortFirst sortFirst:Bool)
    {
        self.enumerateChildNodesWithName(kNodeName_DataSet) { (node, found) -> Void in
            (node as! DataSetNode).autolocateAndChartDataSet(sortFirst: sortFirst)
        }

    }
    
    func reSortAllDataSets(flipDirection flipDirection:Bool)
    {
        self.enumerateChildNodesWithName(kNodeName_DataSet) { (node, found) -> Void in
            (node as! DataSetNode).reSortYourDataSet(flipDirection: flipDirection)
        }
    }
    
    func unSortAllDataSets(flipDirection flipDirection:Bool)
    {
        self.enumerateChildNodesWithName(kNodeName_DataSet) { (node, found) -> Void in
            (node as! DataSetNode).unSortYourDataSet(flipDirection: flipDirection)
        }
    }
    
    func reSortThisChartDataSet(dataSetName dataSetName:String?, flipDirection:Bool)
    {
        self.enumerateChildNodesWithName(kNodeName_DataSet) { (node, found) -> Void in
            guard let dsNode = (node as? DataSetNode) else {return}
            if dataSetName == nil || dsNode.dataSetName == dataSetName
            {
                dsNode.reSortYourDataSet(flipDirection: flipDirection)
            }
        }
        
    }
    
    func unSortThisChartDataSet(dataSetName dataSetName:String?, flipDirection:Bool)
    {
        self.enumerateChildNodesWithName(kNodeName_DataSet) { (node, found) -> Void in
            guard let dsNode = (node as? DataSetNode) else {return}
            if dataSetName == nil || dsNode.dataSetName == dataSetName
            {
                dsNode.unSortYourDataSet(flipDirection: flipDirection)
            }
        }
        
    }

    func swapXYOnAllDataSets()
    {
        self.enumerateChildNodesWithName(kNodeName_DataSet) { (node, found) -> Void in
            guard let dsNode = (node as? DataSetNode) else {return}
            dsNode.swapXYForDataSet()
        }
    }
    
    func reChartTheseDataSets(dataSetNameOrNil dataSetName:String?, sortFirst:Bool)
    {
        self.enumerateChildNodesWithName(kNodeName_DataSet) { (node, found) -> Void in
            guard let dsNode = (node as? DataSetNode) else {return}
            if dataSetName == nil || dsNode.dataSetName == dataSetName
            {
                dsNode.autolocateAndChartDataSet(sortFirst: sortFirst)
            }
        }
        
    }
    
    func plotNewChartDataSet(dataSet dataSet:ChartDataSet, nameOfChartDataSet:String, sortFirst:Bool)
    {
        self.removeDataSetNodes()
        let topNode = DataSetNode(dataSet: dataSet, nameOfChartDataSet: nameOfChartDataSet, colour:kColour_Unselected)
        self.addChild(topNode)
        self.reChartTheseDataSets(dataSetNameOrNil: nameOfChartDataSet, sortFirst: sortFirst)
    }
    
    
    func clearSelectedPointsArray()
    {
        self.enumerateChildNodesWithName(kNodeName_DataSet) { (topnode, found) -> Void in
            guard let dsNode = (topnode as? DataSetNode) else {return}
            dsNode.selectedDataPoints = ChartDataPointsArray()
        }
    }
    
    func rebuildSelectedPointsArray(rectNode:SKNode)->Bool
    {
        var foundNodesInRect = false
        self.enumerateChildNodesWithName(kNodeName_DataSet) { (topnode, found) -> Void in
            guard let dsNode = (topnode as? DataSetNode) else {return}
            dsNode.selectedDataPoints = ChartDataPointsArray()
            topnode.enumerateChildNodesWithName(kNodeName_DataPoint) { (pointnode, foundpoint) -> Void in
                let ptNode = (pointnode as! DataPointNode)
                if rectNode.containsPoint(topnode.convertPoint(ptNode.position, toNode: self))
                {
                    (topnode as! DataSetNode).selectedDataPoints.append(ptNode.dataPoint)
                    ptNode.color = kColour_Selected
                    foundNodesInRect = true
                }
                else
                {
                    ptNode.color = kColour_Unselected
                }
            }
        }
        return foundNodesInRect
    }
    
    
    
    // MARK: - Selection Rect
    typealias PointString = (xText:String, yText:String)
    func textForLabelForPointWithinNode(point point:CGPoint)-> PointString
    {
        var correctedString:PointString = ("","")
        self.enumerateChildNodesWithName(kNodeName_DataSet) { (topnode, found) -> Void in
            guard let dsNode = (topnode as? DataSetNode) where dsNode.calculateAccumulatedFrame().contains(point)
                else {return}
            found.memory = true
            let convPoint = dsNode.convertPoint(point, fromNode: dsNode.scene!)
            correctedString = (String.localizedStringWithFormat("%.02f", convPoint.x), String.localizedStringWithFormat("%.02f", convPoint.y))
                
        }
        return correctedString
    }
    
    func labelNodeForRect(rect rect: CGRect, atPostion:CGPoint, verticalLocation: SKLabelVerticalAlignmentMode)->SKSpriteNode
    {
        let upOrDownFactor:CGFloat
        let labelsText:String
        let correctedPosition: CGPoint
        let anchorPoint: CGPoint
        switch verticalLocation
        {
        case .Top:
            anchorPoint = rect.size.height < 0 ? CGPoint(x: 0.5, y: 0) : CGPoint(x: 0.5, y: 1)
            upOrDownFactor = rect.size.height < 0 ? 0 : -1.0
            correctedPosition = rect.size.height < 0 ? CGPoint(x: 0.0, y: 5.0) : CGPoint(x: 0.0, y: -5.0)
            labelsText = self.textForLabelForPointWithinNode(point: CGPoint(x: atPostion.x, y: atPostion.y)).yText//String(atPostion.y)
        case .Bottom:
            anchorPoint = rect.size.height > 0 ? CGPoint(x: 0.5, y: 0) : CGPoint(x: 0.5, y: 1)
            upOrDownFactor = rect.size.height > 0 ? 0 : -1.0
            correctedPosition = rect.size.height > 0 ? CGPoint(x: rect.size.width, y: rect.size.height+5.0) : CGPoint(x: rect.size.width, y: rect.size.height-5.0)
            labelsText = self.textForLabelForPointWithinNode(point: CGPoint(x: atPostion.x, y: atPostion.y+rect.size.height)).yText// String(atPostion.y+rect.size.height)
       default:
            anchorPoint = rect.size.height < 0 ? CGPoint(x: 0.5, y: 0) : CGPoint(x: 0.5, y: 1)
            correctedPosition = CGPointZero
            upOrDownFactor = 0
            labelsText = "??"
       }
        let label = SKLabelNode(text: labelsText)
        label.fontColor = kColour_Selected
        label.fontSize = 16
        label.fontName = NSFont.boldSystemFontOfSize(label.fontSize).fontName
        label.position = CGPoint(x: 0, y: upOrDownFactor * label.frame.size.height)
      
        
        let backNode = SKSpriteNode(texture: nil, color: self.backgroundColor, size: label.frame.size)
        backNode.name = kNodeName_LabelContainer
        backNode.addChild(label)
        backNode.position = correctedPosition
        backNode.anchorPoint = anchorPoint
        
        return backNode
    }
    
    
    func rectNodeForRect(rect rect: CGRect, atPostion:CGPoint)->SKShapeNode
    {
        let rectNode = SKShapeNode(rect: rect)
        rectNode.name = kNodeName_SelectionRect
        rectNode.strokeColor = kColour_Selected
        rectNode.position = atPostion
        rectNode.addChild(self.labelNodeForRect(rect: rect, atPostion: atPostion, verticalLocation: .Top))
        rectNode.addChild(self.labelNodeForRect(rect: rect, atPostion: atPostion, verticalLocation: .Bottom))
        rectNode.zPosition = CGFloat(Int.max)
        
        return rectNode
    }
    
    // MARK: - override Mouse
    override func mouseDown(theEvent: NSEvent) {
        /* Called when a mouse click occurs */
        
        switch self.chartCursorState
        {
        case .Hand:
            self.mouseClickDownPoint = theEvent.locationInNode(self)
        case .Crosshair:
            self.removeRectNodes()
            self.clearSelectedPointsArray()
            self.addChild(rectNodeForRect(rect: CGRectZero,atPostion: theEvent.locationInNode(self)))
            self.buttonExportSelected?.enabled = false
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
            self.addChild(self.rectNodeForRect(rect: CGRect(x: 0.0, y: 0.0, width: newPos.x-startPos.x, height: newPos.y-startPos.y), atPostion: startPos))
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
            self.buttonExportSelected?.enabled = self.rebuildSelectedPointsArray(rectNode)
            self.removeRectNodes()

        case .ZoomIn:
            break
        case .ZoomOut:
            break
            /*default:
            return NSCursor.arrowCursor()*/
            
        }
    }
    
    // MARK: - override
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here*/
        self.linkChartViewControls()
    }
    
    func linkChartViewControls()
    {
        self.buttonExportSelected = nil
        guard let subviews2search = self.view?.superview?.subviews else {return}
        for view in subviews2search
        {
            guard let id = view.identifier else {continue}
            if id.hasPrefix("buttonExportSelected")
            {
                self.buttonExportSelected = view as? NSButton
            }
        }
    }
}
