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

    var associatedChartViewControllerDelegate: ChartViewControllerDelegate?

    
    // MARK: - @IBOutlet
    @IBOutlet weak var chartView: ChartView!
    @IBOutlet weak var segmentSort: NSSegmentedControl!
    @IBOutlet weak var segmentCursorState: NSSegmentedControl!
    @IBOutlet weak var buttonExportSelected: NSButton!

    // MARK: - @IBAction
    @IBAction func segmentCursorStateTapped(sender: NSSegmentedControl) {
        self.chartView.updateCursorState(newState: sender.selectedSegment)
    }
    
    @IBAction func segmentChartTypeTapped(sender: NSSegmentedControl) {
        self.changeChartSorting(flipDirection: false)
    }
    
    @IBAction func reSortChart(sender: AnyObject) {
        self.changeChartSorting(flipDirection: true)

    }
    
    @IBAction func exportSelectedTapped(sender: AnyObject) {
        self.extractRowsAndMakeNewDocumentsForChartPointsFromNodes()
    }
    
    @IBAction func swapXYtapped(sender: AnyObject) {
        guard
            let scene = self.chartView.scene as? ChartScene
        else {return}
        scene.swapXYOnAllDataSets()
    }


    // MARK: - Func
    func changeChartSorting(flipDirection flipDirection:Bool)
    {
        guard
            let scene = self.chartView.scene as? ChartScene,
            let segment = self.segmentSort,
            let image = segment.imageForSegment((segment.selectedSegment)),
            let imagename = image.name()
            else {return}
        
        switch imagename
        {
        case "scatterChart":
            scene.unSortAllDataSets(flipDirection: flipDirection)
        case "lineChart":
            scene.reSortAllDataSets(flipDirection: flipDirection)
            
        default: break
        }

    }
    
    func chartIsSorted()->Bool
    {
        guard
            let segment = self.segmentSort,
            let image = segment.imageForSegment((segment.selectedSegment)),
            let imagename = image.name()
            else {return false}
        
        switch imagename
        {
        case "scatterChart":
            return false
        case "lineChart":
            return true
        default:
            return false
        }
    }

    func extractRowsAndMakeNewDocumentsForChartPointsFromNodes()
    {
        guard
            let scene = self.chartView.scene as? ChartScene,
            let assocCVCD = self.associatedChartViewControllerDelegate
            else {return}
        
        for selectedPointsFromNode in scene.selectedDataPointsArrayFromNodes()
        {
            let indexset = NSMutableIndexSet()
            for chartdatapoint in selectedPointsFromNode.chartDataPoints
            {
                indexset.addIndex(Int(chartdatapoint.rowNum))//this is the row
            }
            
            assocCVCD.extractRowsIntoNewCSVdocumentWithIndexesFromChartDataSet(indexset, nameOfDataSet: selectedPointsFromNode.nodeName)
        }
    }
    
    

    func reSortThisChartDataSet(dataSetName dataSetName:String?, flipDirection:Bool) {
        guard let scene = self.chartView.scene as? ChartScene else {return}
        scene.reSortThisChartDataSet(dataSetName: dataSetName, flipDirection:flipDirection)

    }
    
    func plotNewChartDataSet(dataSet dataSet: ChartDataSet, nameOfChartDataSet: String) {
        guard let scene = self.chartView.scene as? ChartScene else {return}
    
        scene.plotNewChartDataSet(dataSet: dataSet, nameOfChartDataSet: nameOfChartDataSet, sortFirst: self.chartIsSorted())
    }
    

    
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    

    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.associatedChartViewControllerDelegate = self.parentViewController as? ChartViewControllerDelegate
        self.chartView?.showChartSceneInView()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        
    }
    
}
