//
//  CSVdataViewController.swift
//  aecombiner
//
//  Created by David Lewis on 12/07/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa

class CSVdataViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    
    @IBOutlet weak var tableViewCSVdata: NSTableView!

    
    var csvDataObject: CSVdata = CSVdata() {
        didSet {
            // Update the view, if already loaded.
            self.columnsClearAndRebuild()
            self.tableViewCSVdata.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.csvDataObject = CSVdata()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addColumnWithIdentifier:", name: "addColumnWithIdentifier", object: nil)

    }
    
    // MARK: - document
    func documentMakeDirty()
    {
        CSVdataDocument.makeDocumentDirtyForView(self.view)

    }

    
    // MARK: - segue
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        guard segue.identifier != nil else {
            return
        }
        
        switch segue.identifier!
        {
        case "HeadingsViewController":
            _ = (segue.destinationController as! HeadingsViewController)
            //recoder.updateRepresentedObjectToCSVData(self.representedObject as! CSVdata)
        case "RecodeColumnViewController":
            _ = (segue.destinationController as! RecodeColumnViewController)
            //recoder.updateRepresentedObjectToCSVData(self.representedObject as! CSVdata)
        case "SelectParametersViewController":
            _ = (segue.destinationController as! SelectParametersViewController)
            //recoder.updateRepresentedObjectToCSVData(self.representedObject as! CSVdata)
            
            
        default:
            break
        }
    }
    
    
    // MARK: - CSV data table
    
    func extractRowsBasedOnParameters(ANDparameters ANDparameters:[[String]], ORparameters:[[String]])
    {
        var extractedRows = [[String]]()
        for parameter in self.csvDataObject.csvData
        {
            // parameter is a [string] array of row columns

        }
    }
    
    func createSetOfParameters(fromColumn columnIndex:Int)->Set<String>?
    {
        var set: Set<String>? = Set<String>()
        for parameter in self.csvDataObject.csvData
        {
            // parameter is a [string] array of row columns
            set!.insert(parameter[columnIndex])
        }
        if set!.count == 0
        {
            set = nil
        }
        return set
    }
    
    func requestedColumnIndexIsOK(columnIndex:Int) -> Bool
    {
        return columnIndex >= 0 && columnIndex < self.csvDataObject.headers.count
    }

    
   func columnsClearAndRebuild(){
        
        while self.tableViewCSVdata.tableColumns.count > 0
        {
            self.tableViewCSVdata.removeTableColumn(tableViewCSVdata.tableColumns.last!)
        }
        for var c = 0; c < self.csvDataObject.headers.count; c++
        {
            self.tableViewCSVdata.addTableColumn(self.columnWithUniqueIdentifierAndTitle(self.csvDataObject.headers[c]))
            
        }
        
    }
    
    func renameColumnAtIndex(columnIndex: Int, newName:String)
    {
        guard columnIndex >= 0 && !newName.isEmpty else {return}
        self.csvDataObject.headers[columnIndex] = newName
        self.tableViewCSVdata.tableColumns[columnIndex].title = newName
        self.tableViewCSVdata.reloadData()
    }

    
    func addRecodedColumn(withTitle title:String, fromColum columnIndex:Int, usingParamsArray paramsArray:[[String]])
    {
        //make a temporary dictionary
        var paramsDict = [String : String]()
        for paramNameAndValueArray in paramsArray
        {
            paramsDict[paramNameAndValueArray[0]] = paramNameAndValueArray[1]
        }
        
        // must add the column to Array BEFORE adding column to table
        for var r = 0; r<self.csvDataObject.csvData.count; r++
        {
            var rowArray = self.csvDataObject.csvData[r]
            //ADD CORRECT PARAMETER AFTER LOOKUP
            let valueToRecode = rowArray[columnIndex]
            let recodedValue = (paramsDict[valueToRecode] ?? "")
            rowArray.append(recodedValue)
            self.csvDataObject.csvData[r] = rowArray
        }
        //add name to headers array
        self.csvDataObject.headers.append(title)
        //Safe to add column to table now
        self.tableViewCSVdata.addTableColumn(self.columnWithUniqueIdentifierAndTitle(title))
        self.tableViewCSVdata.reloadData()
        self.tableViewCSVdata.scrollColumnToVisible(self.tableViewCSVdata.numberOfColumns-1)
        self.documentMakeDirty()
    }
    
    func deleteColumnAtIndex(columnIndex: Int)
    {
        guard columnIndex >= 0 && columnIndex <= self.csvDataObject.headers.count else {return}
        
        // must delete the column from Array BEFORE deleting  table
        for var r = 0; r<self.csvDataObject.csvData.count; r++
        {
            var rowArray = self.csvDataObject.csvData[r]
            rowArray.removeAtIndex(columnIndex)
            self.csvDataObject.csvData[r] = rowArray
        }
        //remove from headers array
        self.csvDataObject.headers.removeAtIndex(columnIndex)
        //Safe to delete column to table now
        self.tableViewCSVdata.removeTableColumn(self.tableViewCSVdata.tableColumns[columnIndex])
        self.tableViewCSVdata.reloadData()
        self.documentMakeDirty()

    }
    
    func columnWithUniqueIdentifierAndTitle(title:String)->NSTableColumn
    {
        let col =  NSTableColumn(identifier:String(NSDate().timeIntervalSince1970))
        col.title = title
        return col
    }
    
    func addColumnWithIdentifier(notification: NSNotification)
    {
        guard let title = notification.object as? String else {return}
        self.tableViewCSVdata.addTableColumn(self.columnWithUniqueIdentifierAndTitle(title))
        self.tableViewCSVdata.reloadData()
        self.tableViewCSVdata.scrollColumnToVisible(self.tableViewCSVdata.numberOfColumns-1)
    }

    // MARK: - TableView overrides
    
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard let tvidentifier = tableView.identifier else
        {
            return 0
        }
        switch tvidentifier
        {
        case "tableViewCSVdata":
            return self.csvDataObject.csvData.count
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
            cellView.textField!.stringValue = self.csvDataObject.csvData[row][colIndex]
            
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
