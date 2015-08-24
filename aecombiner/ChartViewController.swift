//
//  ChartViewController.swift
//  aecombiner
//
//  Created by David Lewis on 24/08/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa
import SpriteKit

class ChartViewController: NSViewController {

    
    // MARK: - @IBOutlet
    @IBOutlet weak var chartView: ChartView!
    @IBOutlet weak var buttonSortParameters: NSButton!
    @IBOutlet weak var buttonTrash: NSButton!
    @IBOutlet weak var segmentCursorState: NSSegmentedControl!
    @IBOutlet weak var placeHolderView: NSView!

    // MARK: - @IBAction
    @IBAction func segmentCursorStateTapped(sender: NSSegmentedControl) {
        self.chartView.updateCursorState(newState: sender.selectedSegment)
    }
    
    @IBAction func refreshSegmentTapped(sender: NSSegmentedControl) {
        guard let scene = self.chartView.scene as? ChartScene else {return}
        scene.autoLocateAndChartAllParameters()
    }
    
    func reSortTheseParameters(dataSetName:String) {
        guard
            let chartview = self.chartView
            else {return}
        chartview.reSortTheseParameters(dataSetName: dataSetName)
    }
    
    func chartNewParameters(parameters: ChartDataSet, nameOfParameters: String ) {
        guard
            let chartview = self.chartView
            else {return}
        chartview.chartNewParameters(parameters: parameters, nameOfParameters: nameOfParameters)
    }
    

    
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
    
}
