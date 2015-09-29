//
//  CSVdataViewController.swift
//  aecombiner
//
//  Created by David Lewis on 12/07/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa

class CSVdataViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    // MARK: - Var
    var associatedCSVdataDocument: CSVdataDocument = CSVdataDocument() {
        didSet {
            // Update the view, if already loaded.
            self.columnsClearAndRebuild()
        }
    }

    
    // MARK: - @IBOutlet
    @IBOutlet weak var tvCSVdata: NSTableView!
    @IBOutlet weak var segmentSortTextOrValue: NSSegmentedControl!
    @IBOutlet weak var labelNumRows: NSTextField!

    // MARK: - @IBActions
    
    @IBAction func rebuildColumns(sender: AnyObject) {
        self.columnsClearAndRebuild() 
    }
    
    

    // MARK: - overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

    }
    
    // MARK: - document
    func documentMakeDirty()
    {
        self.associatedCSVdataDocument.updateChangeCount(.ChangeDone)
    }

    
    // MARK: - extracting CSV data table

    func extractRowsBasedOnPredicatesIntoNewFile(predicates predicates:ArrayOfPredicatesForExtracting)
    {
        self.associatedCSVdataDocument.extractRowsBasedOnPredicatesIntoNewFile(predicates: predicates)
        self.tvCSVdata.reloadData()
    }
    

    // MARK: - Columns

    
   func columnsClearAndRebuild(){
        
        self.associatedCSVdataDocument.columnsClearAndRebuild(self.tvCSVdata)
        self.labelNumRows.stringValue = String(self.associatedCSVdataDocument.numberOfRowsOfData())
    }
    
    func renameColumnAtIndex(columnIndex: Int, newName:String)
    {
        guard columnIndex >= 0 && !newName.isEmpty else {return}
        self.associatedCSVdataDocument.csvDataModel.headers[columnIndex] = newName
        self.tvCSVdata.tableColumns[columnIndex].title = newName
        self.tvCSVdata.reloadData()
    }

    func recodeColumnInSitu(columnToRecode columnIndex:Int, usingParamsArray paramsArray:MulticolumnStringsArray, copyUnmatchedValues:Bool)
    {
        self.associatedCSVdataDocument.recodeColumnInSitu(columnToRecode: columnIndex, usingParamsArray: paramsArray, copyUnmatchedValues:copyUnmatchedValues)
        self.tvCSVdata.reloadData()
        self.tvCSVdata.scrollColumnToVisible(columnIndex)
    }
    
    func addRecodedColumn(withTitle title:String, fromColum columnIndex:Int, usingParamsArray paramsArray:MulticolumnStringsArray, copyUnmatchedValues:Bool)
    {
        self.associatedCSVdataDocument.addRecodedColumn(withTitle: title, fromColum: columnIndex, usingParamsArray: paramsArray, copyUnmatchedValues:copyUnmatchedValues)
        
        //Safe to add column to table now
        self.tvCSVdata.addTableColumn(self.associatedCSVdataDocument.columnWithUniqueIdentifierAndTitle(title))
        self.tvCSVdata.reloadData()
        self.tvCSVdata.scrollColumnToVisible(self.tvCSVdata.numberOfColumns-1)
        self.documentMakeDirty()
    }
    
    func deleteColumnAtIndex(columnIndex: Int)
    {
        guard self.associatedCSVdataDocument.deletedColumnAtIndex(columnIndex) else {return}
        
        //Safe to delete column to table now
        self.tvCSVdata.removeTableColumn(self.tvCSVdata.tableColumns[columnIndex])
        self.tvCSVdata.reloadData()
        self.documentMakeDirty()

    }
    
    
    func addColumnWithIdentifier(notification: NSNotification)
    {
        guard let title = notification.object as? String else {return}
        self.tvCSVdata.addTableColumn(self.associatedCSVdataDocument.columnWithUniqueIdentifierAndTitle(title))
        self.tvCSVdata.reloadData()
        self.tvCSVdata.scrollColumnToVisible(self.tvCSVdata.numberOfColumns-1)
    }


    // MARK: - TableView overrides
    func tableView(tableView: NSTableView, mouseDownInHeaderOfTableColumn tableColumn: NSTableColumn) {
        tableView.sortParametersOrValuesInTableViewColumn(tableColumn: tableColumn, arrayToSort: &self.associatedCSVdataDocument.csvDataModel.csvData, textOrValue: self.segmentSortTextOrValue.selectedSegment)
        
        self.tvCSVdata.reloadData()

    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard let tvidentifier = tableView.identifier else
        {
            return 0
        }
        switch tvidentifier
        {
        case "tvCSVdata":
            return self.associatedCSVdataDocument.numberOfRowsOfData()
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
        case "tvCSVdata":
            cellView = tableView.makeViewWithIdentifier("csvCell", owner: self) as! NSTableCellView
            // Set the stringValue of the cell's text field to the nameArray value at row
            let colIndex = tableView.columnWithIdentifier((tableColumn?.identifier)!)
            cellView.textField!.stringValue = self.associatedCSVdataDocument.csvDataModel.csvData[row][colIndex]
            
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
