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


class ChartScene: SKScene {
    
    var mouseClickDownPoint = CGPoint(x: 0.0, y: 0.0)
    
    func zoomScale(zoomDirection:String)
    {
        switch zoomDirection
        {
        case kButtonName_ZoomIn, kButtonName_ZoomOut:
            let zoomfactor:CGFloat = zoomDirection == kButtonName_ZoomIn ? 2.0 : 0.5
            self.enumerateChildNodesWithName(kNodeName_DataSet) { (node, found) -> Void in
                guard let dsNode = (node as? DataSetNode) else {return}
                dsNode.zoom(zoomfactor)
            }
        case kButtonName_ZoomZero:
            self.enumerateChildNodesWithName(kNodeName_DataSet) { (node, found) -> Void in
                guard let dsNode = (node as? DataSetNode) else {return}
                dsNode.autolocateAndChartParameters()
            }
            break
        default:
            break
        }
        
        
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
    
    func reSortAllDataSets()
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
        let topNode = DataSetNode(parameters: parameters, nameOfParameters: nameOfParameters, colour:kColour_Unselected)
        self.addChild(topNode)
        self.autoLocateAndChartAllParameters()
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
        //self.addChild(ButtonNode(position: CGPoint(x: 5, y: 5), imageName: kButtonName_ZoomIn))
        //self.addChild(ButtonNode(position: CGPoint(x: 25, y: 5), imageName: kButtonName_ZoomOut))
        //self.addChild(ButtonNode(position: CGPoint(x: 45, y: 5), imageName: kButtonName_ZoomZero))
    }
    
    override func mouseDown(theEvent: NSEvent) {
        /* Called when a mouse click occurs */
        self.mouseClickDownPoint = theEvent.locationInNode(self)
        
        /*
        self.removeRectNodes()
        let rectNode = SKShapeNode(rect: CGRectZero)
        rectNode.name = kNodeName_SelectionRect
        rectNode.strokeColor = kColour_Selected
        self.addChild(rectNode)
        rectNode.position = theEvent.locationInNode(self)
        */
   }
    
    override func mouseDragged(theEvent: NSEvent) {
        let newMousePoint = theEvent.locationInNode(self)
        self.enumerateChildNodesWithName(kNodeName_DataSet) { (topnode, found) -> Void in
            let dsNode = (topnode as! DataSetNode)
            dsNode.position = CGPoint(x: dsNode.position.x+newMousePoint.x-self.mouseClickDownPoint.x, y: dsNode.position.y+newMousePoint.y-self.mouseClickDownPoint.y)
        }
        self.mouseClickDownPoint = newMousePoint
        /*
        guard let oldNode = self.childNodeWithName(kNodeName_SelectionRect)  else {return}
        let startPos = oldNode.position
        let newPos = theEvent.locationInNode(self)
        self.removeRectNodes()
        let rectNode = SKShapeNode(rect: CGRect(x: 0.0, y: 0.0, width: newPos.x-startPos.x, height: newPos.y-startPos.y))
        rectNode.name = kNodeName_SelectionRect
        rectNode.strokeColor = kColour_Selected
        self.addChild(rectNode)
        rectNode.position = startPos
        */
    }
    
    override func mouseUp(theEvent: NSEvent) {
        
        /*
        guard let rectNode = self.childNodeWithName(kNodeName_SelectionRect)  else {return}
        self.rebuildSelectedPointsArray(rectNode)
        self.removeRectNodes()
        */
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    
}
