//
//  ChartView.swift
//  aecombiner
//
//  Created by David JM Lewis on 14/08/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Foundation
import SpriteKit



class ChartView: SKView {
    
    // MARK: - VAR
    var chartCursorState:ChartCursorStates = .Hand

    
    // MARK: - override

    override func viewWillStartLiveResize() {
        super.viewWillStartLiveResize()
        self.scene?.hidden = true
    }
    
    override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        guard let scene = self.scene as? ChartScene else {self.scene?.hidden = false;return}
        scene.autoLocateAndChartAllParameters()
        scene.hidden = false
    }

    

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.showChartSceneInView()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.showChartSceneInView()
        
    }
    
    
    // MARK: - Cursors
    override func updateTrackingAreas()
    {
        super.updateTrackingAreas()
        
        for TA in self.trackingAreas
        {
            self.removeTrackingArea(TA)
        }
        
        let opts:NSTrackingAreaOptions = [.MouseEnteredAndExited, .ActiveInKeyWindow]
        let trackingArea = NSTrackingArea(rect: self.bounds, options: opts, owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)

    }

    
    override func mouseEntered(theEvent: NSEvent) {
        super.mouseEntered(theEvent)
        self.cursorForChartCursorState(state: self.chartCursorState).set()
    }
    
    override func mouseExited(theEvent: NSEvent) {
        super.mouseExited(theEvent)
        NSCursor.arrowCursor().set()

    }
    
    func updateCursorState(newState newState:Int)
    {
        if let validState = ChartCursorStates(rawValue: newState)
        {
            self.chartCursorState = validState
            (self.scene as? ChartScene)?.chartCursorState = validState
        }
        else
        {
            self.chartCursorState = .Hand
            (self.scene as? ChartScene)?.chartCursorState = .Hand
        }
    }

    func cursorForChartCursorState(state state:ChartCursorStates)->NSCursor
    {
        switch state
        {
        case .Hand:
            return NSCursor.openHandCursor()
        case .Crosshair:
            return NSCursor.crosshairCursor()
        case .ZoomIn:
            return NSCursor(image: NSImage(named: kButtonName_ZoomIn)!, hotSpot: CGPoint(x: 8.0, y: 8.0))
        case .ZoomOut:
            return NSCursor(image: NSImage(named: kButtonName_ZoomIn)!, hotSpot: CGPoint(x: 8.0, y: 8.0))
            /*default:
            return NSCursor.arrowCursor()*/
        }
    }
    
    
    // MARK: - Charts

    func showChartSceneInView() {
        self.layer?.backgroundColor = NSColor.clearColor().CGColor
        let scene = ChartScene(size: self.frame.size)//fileNamed:"ChartScene"),
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .ResizeFill
        scene.backgroundColor = NSColor.whiteColor()
        self.presentScene(scene)
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        self.ignoresSiblingOrder = true
        self.showsFPS = false
        self.showsNodeCount = true
        
    }
    
    
    func reSortAllParameters()
    {
        guard let scene = self.scene as? ChartScene else {return}
        scene.reSortAllDataSets()
    }
    
    
    func reSortTheseParameters(dataSetName dataSetName:String)
    {
        guard let scene = self.scene as? ChartScene else {return}
        scene.reSortTheseParameters(dataSetName: dataSetName)
    }
    
    
    func chartNewParameters(parameters parameters:ChartDataSet, nameOfParameters:String)
    {
        guard let chartscene = self.scene as? ChartScene else {return}
        chartscene.chartNewParameters(parameters: parameters, nameOfParameters: nameOfParameters)
    }
    
    func zoom(segmentImageName segmentImageName:String)
    {
        guard let scene = self.scene as? ChartScene else {return}
        scene.zoomScale(segmentImageName)
    }
}
