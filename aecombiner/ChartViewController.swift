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
    @IBOutlet weak var buttonSortDataSet: NSButton!
    @IBOutlet weak var buttonTrash: NSButton!
    @IBOutlet weak var segmentCursorState: NSSegmentedControl!

    // MARK: - @IBAction
    @IBAction func segmentCursorStateTapped(sender: NSSegmentedControl) {
        self.chartView.updateCursorState(newState: sender.selectedSegment)
    }
    
    @IBAction func refreshSegmentTapped(sender: NSSegmentedControl) {
        guard let scene = self.chartView.scene as? ChartScene else {return}
        scene.autoLocateAndChartAllDataSets()
    }
    
    func reSortThisChartDataSet(dataSetName dataSetName:String) {
        self.chartView?.reSortThisChartDataSet(dataSetName: dataSetName)
    }
    
    func displayNewChartDataSet(dataSet dataSet: ChartDataSet, nameOfChartDataSet: String ) {
        self.chartView?.displayNewChartDataSet(dataSet: dataSet, nameOfChartDataSet: nameOfChartDataSet)
    }
    

    
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
