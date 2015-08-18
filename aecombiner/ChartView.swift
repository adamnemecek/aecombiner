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
    
    var topNode:ChartTopNode?
    
    override func viewWillStartLiveResize() {
        super.viewWillStartLiveResize()
        self.scene?.hidden = true
    }
    
    override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        guard let topnode = self.topNode else {self.scene?.hidden = false;return}
        self.chartTheseParameters(parameters: topnode.parameters, nameOfParameters: topnode.name)
        self.scene?.hidden = false
    }

    

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.showChartSceneInView()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.showChartSceneInView()
        
    }
    
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
    
    
    func reSortYourParameters()
    {
        self.topNode?.reSortYourParameters()
    }

    
    func chartTheseParameters(parameters parameters:ChartDataSet, nameOfParameters:String?)
    {
        guard let chartscene = self.scene else {return}
        chartscene.removeAllChildren()
        let topNode = ChartTopNode(sceneSize: ChartDataPoint(xvalue:Double(chartscene.size.width),yvalue:Double(chartscene.size.height)), parameters: parameters, nameOfParameters: nameOfParameters, colour:NSColor.redColor())
        
        chartscene.addChild(topNode)
        topNode.autolocateAndChartParameters()
        self.topNode = topNode
    }
    
    
}
