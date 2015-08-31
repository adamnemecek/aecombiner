//
//  ChartViewController.swift
//  aecombiner
//
//  Created by David Lewis on 24/08/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa
import SpriteKit

@objc protocol ChartViewControllerDelegate
{
    func extractRowsIntoNewCSVdocumentWithIndexesFromChartDataSet(indexes:NSMutableIndexSet, nameOfDataSet:String)
    
}


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
        self.extractRowsAndMakeNewDocumentsForChartPointsFromNodes()
    }
    

    func associatedChartViewControllerDelegate() -> ChartViewControllerDelegate?
    {
        return self.parentViewController as? ChartViewControllerDelegate
    }

    // MARK: - Func
    func extractRowsAndMakeNewDocumentsForChartPointsFromNodes()
    {
        guard
            let scene = self.chartView.scene as? ChartScene,
            let assocCVCD = self.associatedChartViewControllerDelegate()
            else {return}
        
        for selectedPointsFromNode in scene.selectedDataPointsArrayFromNodes()
        {
            let indexset = NSMutableIndexSet()
            for chartdatapoint in selectedPointsFromNode.chartDataPoints
            {
                indexset.addIndex(Int(chartdatapoint.xValue))//this is the row
            }
            
            assocCVCD.extractRowsIntoNewCSVdocumentWithIndexesFromChartDataSet(indexset, nameOfDataSet: selectedPointsFromNode.nodeName)
        }
    }
    
    

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
