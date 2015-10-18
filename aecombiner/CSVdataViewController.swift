//
//  CSVdataViewController.swift
//  aecombiner
//
//  Created by David Lewis on 12/07/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa

let kRowColumnSeparator = ","

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
        self.associatedCSVdataDocument.csvDataModel.extractRowsBasedOnPredicatesIntoNewFile(predicates: predicates)
        self.tvCSVdata.reloadData()
    }
    

    // MARK: - Columns

    
   func columnsClearAndRebuild(){
        
        self.associatedCSVdataDocument.columnsClearAndRebuild(self.tvCSVdata)
        self.labelNumRows.stringValue = String(self.associatedCSVdataDocument.csvDataModel.numberOfRowsInData())
    }
    
    func renameColumnAtIndex(columnIndex: Int, newName:String)
    {
        guard
            self.associatedCSVdataDocument.csvDataModel.renamedColumnAtIndex(columnIndex: columnIndex, newName:newName)
            else {return}
        self.tvCSVdata.tableColumns[columnIndex].title = newName
        self.tvCSVdata.reloadData()
    }

    func recodedColumnInSitu(columnToRecode columnIndex:Int, usingParamsArray paramsArray:StringsMatrix2D, copyUnmatchedValues:Bool)->Bool
    {
        guard
            self.associatedCSVdataDocument.csvDataModel.recodedColumnInSitu(columnToRecode: columnIndex, usingParamsArray: paramsArray, copyUnmatchedValues:copyUnmatchedValues)
            else {return false}
        self.tvCSVdata.reloadData()
        self.tvCSVdata.scrollColumnToVisible(columnIndex)
        return true
    }
    
    func addedRecodedColumn(withTitle title:String, fromColum columnIndex:Int, usingParamsArray paramsArray:StringsMatrix2D, copyUnmatchedValues:Bool)->Bool
    {
        guard
            self.associatedCSVdataDocument.csvDataModel.addedRecodedColumn(title: title, fromColum: columnIndex, usingParamsArray: paramsArray, copyUnmatchedValues:copyUnmatchedValues)
            else {return false}
        //Safe to add column to table now
        self.addTableColumnAndScrollWithTitle(title)
        return true
    }
    
    func addedRecodedColumnByBooleanCompareWithColumn(title title:String, fromColum:Int, compareColumn:Int, booleanString:String, replacementString:String, copyUnmatchedValues:Bool)->Bool
    {
        guard
            self.associatedCSVdataDocument.csvDataModel.addedRecodedColumnByBooleanCompareWithColumn(fromColum:fromColum, compareColumn:compareColumn, booleanString:booleanString, replacementString:replacementString, copyUnmatchedValues:copyUnmatchedValues)
            else {return false}
        //Safe to add column to table now
        self.addTableColumnAndScrollWithTitle(title)
        return true
    }
    
    func deletedColumnAtIndex(columnIndex: Int)->Bool
    {
        guard self.associatedCSVdataDocument.csvDataModel.deletedColumnAtIndex(columnIndex) else {return false}
        
        //Safe to delete column to table now
        self.tvCSVdata.removeTableColumn(self.tvCSVdata.tableColumns[columnIndex])
        self.tvCSVdata.reloadData()
        self.documentMakeDirty()
        return true
    }
    
    func recodedDateTimeToNewColumn(withTitle title:String, fromColum:Int, formatMethod:DateTimeFormatMethod, formatString:String, copyUnmatchedValues:Bool, asString:Bool)->Bool
    {
        guard
            self.associatedCSVdataDocument.csvDataModel.recodedDateTimeToNewColumn(withTitle: title, fromColum: fromColum, formatMethod: formatMethod, formatString: formatString, asString:asString, copyUnmatchedValues: copyUnmatchedValues)
            else {return false}
        //Safe to add column to table now
        self.addTableColumnAndScrollWithTitle(title)
        return true
    }

    func calculatedDateTimeToNewColumn(withTitle title:String, startColumn:Int, endColumn:Int, formatMethod:DateTimeFormatMethod, formatString:String, roundingUnits:DateTimeRoundingUnits, copyUnmatchedValues: Bool)->Bool
    {
        guard
            self.associatedCSVdataDocument.csvDataModel.calculatedDateTimeToNewColumn(withTitle: title, startColumn: startColumn, endColumn: endColumn, formatMethod: formatMethod, formatString: formatString, roundingUnits: roundingUnits, copyUnmatchedValues: copyUnmatchedValues)
            else {return false}
        //Safe to add column to table now
        self.addTableColumnAndScrollWithTitle(title)
        return true
    }
    
    func addTableColumnAndScrollWithTitle(title:String)
    {
        self.tvCSVdata.addTableColumn(NSTableColumn.columnWithUniqueIdentifierAndTitle(title))
        self.tvCSVdata.reloadData()
        self.tvCSVdata.scrollColumnToVisible(self.tvCSVdata.numberOfColumns-1)
        self.documentMakeDirty()
    }
    // MARK: - TableView overrides
    func tableView(tableView: NSTableView, mouseDownInHeaderOfTableColumn tableColumn: NSTableColumn) {
        tableView.sortParametersOrValuesInTableViewColumn(tableColumn: tableColumn, arrayToSort: &self.associatedCSVdataDocument.csvDataModel.dataStringsMatrix2D, textOrValue: self.segmentSortTextOrValue.selectedSegment)
        
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
            return self.associatedCSVdataDocument.csvDataModel.numberOfRowsInData()
        default:
            return 0
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // Retrieve to get the @"MyView" from the pool or,
        // if no version is available in the pool, load the Interface Builder version
        var cellView = NSTableCellView()
        guard
            let tvidentifier = tableView.identifier,
            let id = tableColumn?.identifier
        else {return cellView}
        
        let colIndex = tableView.columnWithIdentifier(id)
        guard colIndex >= 0 else {return cellView}
        
        switch tvidentifier
        {
        case "tvCSVdata":
            cellView = tableView.makeViewWithIdentifier("csvCell", owner: self) as! NSTableCellView
            // Set the stringValue of the cell's text field to the nameArray value at row
            let valS = self.associatedCSVdataDocument.csvDataModel.stringValueForCell(fromColumn: colIndex, atRow: row)
            if valS != nil
            {
                cellView.textField!.stringValue = valS!
            }
            cellView.textField!.identifier = "\(row)"+kRowColumnSeparator+"\(colIndex)"
        default:
            break
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

    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        guard
            let _ = control as? NSTextField,
            let id = control.identifier,
            let row = Int(id.componentsSeparatedByString(kRowColumnSeparator)[0]),
            let column = Int(id.componentsSeparatedByString(kRowColumnSeparator)[1]),
            let str = fieldEditor.string
        else {return true}
        
        self.associatedCSVdataDocument.csvDataModel.setStringValueForCell(valueString: str, toColumn: column, inRow: row)
        self.documentMakeDirty()
        return true
    }

  

    
    
    
}
