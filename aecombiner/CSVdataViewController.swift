//
//  CSVdataViewController.swift
//  aecombiner
//
//  Created by David Lewis on 12/07/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa

class CSVdataViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    
    // MARK: - @IBOutlet
    @IBOutlet weak var tableViewCSVdata: NSTableView!
    @IBOutlet weak var segmentSortTextOrValue: NSSegmentedControl!
    @IBOutlet weak var labelNumRows: NSTextField!

    // MARK: - @IBActions
    
    @IBAction func rebuildColumns(sender: AnyObject) {
        self.columnsClearAndRebuild() 
    }
    
    

    // MARK: - overrides
    var CSVdataDocumentAssociated: CSVdataDocument = CSVdataDocument() {
        didSet {
            // Update the view, if already loaded.
            self.columnsClearAndRebuild()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        //self.CSVdataDocumentAssociated.csvDataModel = CSVdata()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addColumnWithIdentifier:", name: "addColumnWithIdentifier", object: nil)

    }
    
    // MARK: - document
    func documentMakeDirty()
    {
        CSVdataDocument.makeDocumentDirtyForView(self.view)

    }

    
    // MARK: - CSV data table
    /*
    func CSVdataDocumentAssociated()->CSVdataDocument?
    {
        return self.view.window?.windowController?.document as? CSVdataDocument
    }
    */
    func chartDataSetFromColumnIndex(columnIndex columnIndex:Int)->ChartDataSet
    {
        return self.CSVdataDocumentAssociated.chartDataSetFromColumnIndex(columnIndex: columnIndex)
    }
    

    func combinedColumnsAndNewColumnName(columnIndexForGrouping columnIndexForGrouping:Int, columnIndexesToGroup: NSIndexSet, arrayOfParamatersInGroup: [String], groupMethod:String) -> (cvsDataData:DataMatrix, nameOfColumn:String)
    {
        return self.CSVdataDocumentAssociated.combinedColumnsAndNewColumnName(columnIndexForGrouping: columnIndexForGrouping, columnIndexesToGroup: columnIndexesToGroup, arrayOfParamatersInGroup: arrayOfParamatersInGroup, groupMethod: groupMethod)
    }
    
    func combineColumnsAndExtractToNewDocument(columnIndexForGrouping columnIndexForGrouping:Int, columnIndexesToGroup: NSIndexSet, arrayOfParamatersInGroup: [String], groupMethod:String)
    {
        self.CSVdataDocumentAssociated.combineColumnsAndExtractToNewDocument(columnIndexForGrouping: columnIndexForGrouping, columnIndexesToGroup: columnIndexesToGroup, arrayOfParamatersInGroup: arrayOfParamatersInGroup, groupMethod: groupMethod)
        
    }
    
    
    func combineColumnsAndExtractAllStatsToNewDocument(columnIndexForGrouping columnIndexForGrouping:Int, columnIndexesToGroup: NSIndexSet, arrayOfParamatersInGroup: [String])
    {
        self.CSVdataDocumentAssociated.combineColumnsAndExtractAllStatsToNewDocument(columnIndexForGrouping: columnIndexForGrouping, columnIndexesToGroup: columnIndexesToGroup, arrayOfParamatersInGroup: arrayOfParamatersInGroup)
    }

    func headerStringForColumnIndex(columnIndex:Int?) -> String
    {
        return self.CSVdataDocumentAssociated.headerStringForColumnIndex(columnIndex)
    }

    func numberOfColumnsInData()->Int{
        return self.CSVdataDocumentAssociated.numberOfColumnsInData()
    }

    func dataModelExtractedWithPredicates(ANDpredicates ANDpredicates:DataMatrix, ORpredicates:DataMatrix)->DataMatrix
    {
        return self.CSVdataDocumentAssociated.dataModelExtractedWithPredicates(ANDpredicates: ANDpredicates, ORpredicates: ORpredicates)
    }
    
    func extractRowsBasedOnPredicatesIntoNewFile(ANDpredicates ANDpredicates:DataMatrix, ORpredicates:DataMatrix)
    {
        self.CSVdataDocumentAssociated.extractRowsBasedOnPredicatesIntoNewFile(ANDpredicates: ANDpredicates, ORpredicates: ORpredicates)
        self.tableViewCSVdata.reloadData()
    }
    
    func setOfParametersFromColumn(fromColumn columnIndex:Int)->Set<String>?
    {
        return self.CSVdataDocumentAssociated.setOfParametersFromColumn(fromColumn: columnIndex)
    }
    
    func requestedColumnIndexIsOK(columnIndex:Int) -> Bool
    {
        return self.CSVdataDocumentAssociated.requestedColumnIndexIsOK(columnIndex)
    }

    
   func columnsClearAndRebuild(){
        
        self.CSVdataDocumentAssociated.columnsClearAndRebuild(self.tableViewCSVdata)
        self.labelNumRows.stringValue = String(self.CSVdataDocumentAssociated.numberOfRowsOfData())
    }
    
    func renameColumnAtIndex(columnIndex: Int, newName:String)
    {
        guard columnIndex >= 0 && !newName.isEmpty else {return}
        self.CSVdataDocumentAssociated.csvDataModel.headers[columnIndex] = newName
        self.tableViewCSVdata.tableColumns[columnIndex].title = newName
        self.tableViewCSVdata.reloadData()
    }

    
    func addRecodedColumn(withTitle title:String, fromColum columnIndex:Int, usingParamsArray paramsArray:DataMatrix)
    {
        self.CSVdataDocumentAssociated.addRecodedColumn(withTitle: title, fromColum: columnIndex, usingParamsArray: paramsArray)
        
        //Safe to add column to table now
        self.tableViewCSVdata.addTableColumn(self.CSVdataDocumentAssociated.columnWithUniqueIdentifierAndTitle(title))
        self.tableViewCSVdata.reloadData()
        self.tableViewCSVdata.scrollColumnToVisible(self.tableViewCSVdata.numberOfColumns-1)
        self.documentMakeDirty()
    }
    
    func deleteColumnAtIndex(columnIndex: Int)
    {
        guard self.CSVdataDocumentAssociated.deletedColumnAtIndex(columnIndex) else {return}
        
        //Safe to delete column to table now
        self.tableViewCSVdata.removeTableColumn(self.tableViewCSVdata.tableColumns[columnIndex])
        self.tableViewCSVdata.reloadData()
        self.documentMakeDirty()

    }
    
    
    func addColumnWithIdentifier(notification: NSNotification)
    {
        guard let title = notification.object as? String else {return}
        self.tableViewCSVdata.addTableColumn(self.CSVdataDocumentAssociated.columnWithUniqueIdentifierAndTitle(title))
        self.tableViewCSVdata.reloadData()
        self.tableViewCSVdata.scrollColumnToVisible(self.tableViewCSVdata.numberOfColumns-1)
    }


    // MARK: - TableView overrides
    func tableView(tableView: NSTableView, mouseDownInHeaderOfTableColumn tableColumn: NSTableColumn) {
        let columnIndex = tableView.columnWithIdentifier(tableColumn.identifier)
        guard columnIndex >= 0 else {return}
        guard let ascending = tableColumn.sortDescriptorPrototype?.ascending else {return}
        let sortdirection = ascending ? kAscending : kDescending
        self.CSVdataDocumentAssociated.sortCSVrowsInColumnAsTextOrValues(columnIndexToSort: columnIndex, textOrvalue: self.segmentSortTextOrValue.selectedSegment, direction:sortdirection)
        tableColumn.sortDescriptorPrototype = NSSortDescriptor(key: nil, ascending: !ascending)
        self.tableViewCSVdata.reloadData()

    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard let tvidentifier = tableView.identifier else
        {
            return 0
        }
        switch tvidentifier
        {
        case "tableViewCSVdata":
            return self.CSVdataDocumentAssociated.numberOfRowsOfData()
        default:
            return 0
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // Retrieve to get the @"MyView" from the pool or,
        // if no version is available in the pool, load the Interface Builder version
        var cellView = NSTableCellView()
        guard let tvidentifier = tableView.identifier else {
            return cellView
        }
        switch tvidentifier
        {
        case "tableViewCSVdata":
            cellView = tableView.makeViewWithIdentifier("csvCell", owner: self) as! NSTableCellView
            // Set the stringValue of the cell's text field to the nameArray value at row
            let colIndex = tableView.columnWithIdentifier((tableColumn?.identifier)!)
            cellView.textField!.stringValue = self.CSVdataDocumentAssociated.csvDataModel.csvData[row][colIndex]
            
        default:
            break;
        }
        
        
        // Return the cellView
        return cellView;
    }
    
    /*
    func tableViewSelectionDidChange(notification: NSNotification) {
        let tableView = notification.object as! NSTableView
        switch tableView.identifier!
        {

        default:
            break;
        }
        
    }
    */

    
  

    
    
    
}
