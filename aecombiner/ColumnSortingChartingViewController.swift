//
//  ColumnSortingChartingViewController.swift
//  aecombiner
//
//  Created by David Lewis on 26/09/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa
import SpriteKit




class ColumnSortingChartingViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, ChartViewControllerDelegate {
    
    
    // MARK: - Var
    var associatedCSVdataViewController: CSVdataViewController?
    var associatedCSVdataDocument: CSVdataDocument?
    var associatedCSVmodel:CSVdata?
    weak var chartViewController: ChartViewController! // this is useful
   
    // MARK: - @IBOutlet
    @IBOutlet weak var segmentedSortAsTextOrNumbers: NSSegmentedControl!

    
    // MARK: - ChartViewControllerDelegate
    
    func extractRowsIntoNewCSVdocumentWithIndexesFromChartDataSet(indexes: NSMutableIndexSet, nameOfDataSet: String) {
        // over ridden in subclasses
        assertionFailure("ColumnSortingChartingViewController : extractRowsIntoNewCSVdocumentWithIndexesFromChartDataSet")
    }
    
    
    // MARK: - Sorting Tables on header click
    func tableView(tableView: NSTableView, mouseDownInHeaderOfTableColumn tableColumn: NSTableColumn) {
        // inheriteds override
        
    }
    
    
    
    //MARK: - Supers overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.associatedCSVdataViewController = ((self.view.window?.sheetParent?.windowController as? CSVdataWindowController)?.contentViewController as? CSVdataViewController)
        self.associatedCSVdataDocument = associatedCSVdataViewController?.associatedCSVdataDocument
        self.associatedCSVmodel = self.associatedCSVdataDocument?.csvDataModel

    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // Do view setup here.
    }
    
    
    
    // MARK: - Segue
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if let cvc = (segue.destinationController as? ChartViewController)
        {
            self.chartViewController = cvc
        }
        
        
    }
    
    // MARK: - CSVdataDocument
    
    func documentMakeDirty()
    {
        self.associatedCSVdataDocument?.documentMakeDirty()
    }
    
    
    
}
