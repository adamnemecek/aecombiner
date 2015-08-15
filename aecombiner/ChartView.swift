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

    
    func chartTheseParameters(var parameters parameters:ChartParameters, nameOfParameters:String?)
    {
        guard let chartscene = self.scene else {return}
        chartscene.removeAllChildren()
        let border = chartscene.size.width/20.0//border is twice the border for each side
        let xSpacing = Double(chartscene.size.width-border)/Double(parameters.values.count)
        let yScale:CGFloat = (chartscene.size.height-border)/CGFloat(parameters.maxParam-parameters.minParam)
        let topNode = ChartTopNode(xSpacing: xSpacing, yScale: yScale, parameters: parameters, nameOfParameters: nameOfParameters, border: border, colour:NSColor.redColor())
        chartscene.addChild(topNode)
        topNode.autolocateAndChartParameters()
        self.topNode = topNode
    }
    
    
}
