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
    var associatedCSVmodel:CSVdata?
    weak var chartViewController: ChartViewController! // this is useful
   
    // MARK: - @IBOutlet
    @IBOutlet weak var segmentedSortAsTextOrNumbers: NSSegmentedControl!

    
    
    
    
    
    
    
    
    // MARK: - ChartViewControllerDelegate
    
    func extractRowsIntoNewCSVdocumentWithIndexesFromChartDataSet(indexes: NSMutableIndexSet, nameOfDataSet: String) {
        // over ridden in subclasses
        assertionFailure("ColumnSortingChartingViewController : extractRowsIntoNewCSVdocumentWithIndexesFromChartDataSet")
        /*
        guard let csvdatavc = self.associatedCSVdataViewController,
            let MulticolumnStringsArray = csvdatavc.dataMatrixFromAssociatedCSVdataDocument()
            else {return}
        // we use self.extractedDataMatrixUsingPredicates
        let extractedDataMatrix = CSVdata.extractTheseRowsFromDataMatrixAsDataMatrix(rows: indexes, datamatrix: MulticolumnStringsArray)
        csvdatavc.createNewDocumentFromExtractedRows(cvsData: extractedDataMatrix, headers: nil, name: nameOfDataSet)
        */
    }
    
    
    // MARK: - Sorting Tables on header click
    func tableView(tableView: NSTableView, mouseDownInHeaderOfTableColumn tableColumn: NSTableColumn) {
        // inheriteds override
        
    }
    
    
    func sortParametersOrValuesInTableViewColumn(tableView tableView: NSTableView, tableColumn: NSTableColumn, inout arrayToSort:MulticolumnStringsArray, textOrValue:Int)
    {
        guard tableView.columnWithIdentifier(tableColumn.identifier) >= 0 else {return}
        if tableColumn.sortDescriptorPrototype == nil
        {
            tableColumn.sortDescriptorPrototype = NSSortDescriptor(key: nil, ascending: true)
        }
        
        let columnIndex = tableView.columnWithIdentifier(tableColumn.identifier)
        let sortdirection = tableColumn.sortDescriptorPrototype!.ascending
        generic_SortArrayOfColumnsAsTextOrValues(arrayToSort: &arrayToSort, columnIndexToSort: columnIndex, textOrvalue: textOrValue, direction: sortdirection)
        tableColumn.sortDescriptorPrototype = NSSortDescriptor(key: nil, ascending: !sortdirection)
    }
    
    
    
    //MARK: - Supers overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.associatedCSVdataViewController = (self.view.window?.sheetParent?.windowController as? CSVdataWindowController)?.contentViewController as? CSVdataViewController
        self.associatedCSVmodel = self.associatedCSVdataViewController?.associatedCSVdataDocument.csvDataModel
        
        
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
        self.associatedCSVdataViewController?.documentMakeDirty()
    }
    
    
    
}
