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
    @IBOutlet weak var segmentCursorState: NSSegmentedControl!
    @IBOutlet weak var buttonExportSelected: NSButton!

    // MARK: - @IBAction
    @IBAction func segmentCursorStateTapped(sender: NSSegmentedControl) {
        self.chartView.updateCursorState(newState: sender.selectedSegment)
    }
    
    @IBAction func segmentChartTypeTapped(sender: NSSegmentedControl) {
        guard
                let scene = self.chartView.scene as? ChartScene,
                let imagename = sender.imageForSegment((sender.selectedSegment))?.name()
                else {return}
        
        switch imagename
        {
        case "scatterChart":
            scene.unSortAllDataSets()
        case "lineChart":
            scene.reSortAllDataSets()

            default: break
        }
        
        
    }
    
    @IBAction func exportSelectedTapped(sender: AnyObject) {
        guard let scene = self.chartView.scene as? ChartScene else {return}

        
        
    }
    
    
    // MARK: - Func

    func reSortThisChartDataSet(dataSetName dataSetName:String?) {
        guard let scene = self.chartView.scene as? ChartScene else {return}
        scene.reSortThisChartDataSet(dataSetName: dataSetName)

    }
    
    func plotNewChartDataSet(dataSet dataSet: ChartDataSet, nameOfChartDataSet: String) {
        guard let scene = self.chartView.scene as? ChartScene else {return}
        scene.plotNewChartDataSet(dataSet: dataSet, nameOfChartDataSet: nameOfChartDataSet)
    }
    

    
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.chartView?.showChartSceneInView()
        
    }
    
}
