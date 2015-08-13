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

    // MARK: - @IBActions
    
    @IBAction func rebuildColumns(sender: AnyObject) {
        self.columnsClearAndRebuild() 
    }
    
    

    // MARK: - overrides
    var myCSVdataDocument: CSVdataDocument = CSVdataDocument() {
        didSet {
            // Update the view, if already loaded.
            self.columnsClearAndRebuild()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        //self.myCSVdataDocument.csvDataModel = CSVdata()
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
    /*
    func myCSVdataDocument()->CSVdataDocument?
    {
        return self.view.window?.windowController?.document as? CSVdataDocument
    }
    */
    func parametersAsDoublesFromColumnIndex(columnIndex columnIndex:Int)->ChartParameters
    {
        return self.myCSVdataDocument.parametersAsDoublesFromColumnIndex(columnIndex: columnIndex)
    }
    
    func combineColumnsAndExtractToNewDocument(columnIndexForGrouping columnIndexForGrouping:Int, columnIndexesToGroup: NSIndexSet, arrayOfParamatersInGroup: [String])
    {
        self.myCSVdataDocument.combineColumnsAndExtractToNewDocument(columnIndexForGrouping: columnIndexForGrouping, columnIndexesToGroup: columnIndexesToGroup, arrayOfParamatersInGroup: arrayOfParamatersInGroup)
        
    }

    func stringForColumnIndex(columnIndex:Int?) -> String
    {
        return self.myCSVdataDocument.stringForColumnIndex(columnIndex)
    }

    func numberOfColumnsInData()->Int{
        return self.myCSVdataDocument.numberOfColumnsInData()
    }

    func extractRowsBasedOnParameters(ANDpredicates ANDpredicates:[[String]], ORpredicates:[[String]])
    {
        self.myCSVdataDocument.extractRowsBasedOnParameters(ANDpredicates: ANDpredicates, ORpredicates: ORpredicates)
        self.tableViewCSVdata.reloadData()
    }
    
    func createSetOfParameters(fromColumn columnIndex:Int)->Set<String>?
    {
        return self.myCSVdataDocument.createSetOfParameters(fromColumn: columnIndex)
    }
    
    func requestedColumnIndexIsOK(columnIndex:Int) -> Bool
    {
        return self.myCSVdataDocument.requestedColumnIndexIsOK(columnIndex)
    }

    
   func columnsClearAndRebuild(){
        
        self.myCSVdataDocument.columnsClearAndRebuild(self.tableViewCSVdata)
    }
    
    func renameColumnAtIndex(columnIndex: Int, newName:String)
    {
        guard columnIndex >= 0 && !newName.isEmpty else {return}
        self.myCSVdataDocument.csvDataModel.headers[columnIndex] = newName
        self.tableViewCSVdata.tableColumns[columnIndex].title = newName
        self.tableViewCSVdata.reloadData()
    }

    
    func addRecodedColumn(withTitle title:String, fromColum columnIndex:Int, usingParamsArray paramsArray:[[String]])
    {
        self.myCSVdataDocument.addRecodedColumn(withTitle: title, fromColum: columnIndex, usingParamsArray: paramsArray)
        
        //Safe to add column to table now
        self.tableViewCSVdata.addTableColumn(self.myCSVdataDocument.columnWithUniqueIdentifierAndTitle(title))
        self.tableViewCSVdata.reloadData()
        self.tableViewCSVdata.scrollColumnToVisible(self.tableViewCSVdata.numberOfColumns-1)
        self.documentMakeDirty()
    }
    
    func deleteColumnAtIndex(columnIndex: Int)
    {
        self.myCSVdataDocument.deleteColumnAtIndex(columnIndex)
        
        //Safe to delete column to table now
        self.tableViewCSVdata.removeTableColumn(self.tableViewCSVdata.tableColumns[columnIndex])
        self.tableViewCSVdata.reloadData()
        self.documentMakeDirty()

    }
    
    
    func addColumnWithIdentifier(notification: NSNotification)
    {
        guard let title = notification.object as? String else {return}
        self.tableViewCSVdata.addTableColumn(self.myCSVdataDocument.columnWithUniqueIdentifierAndTitle(title))
        self.tableViewCSVdata.reloadData()
        self.tableViewCSVdata.scrollColumnToVisible(self.tableViewCSVdata.numberOfColumns-1)
    }


    // MARK: - TableView overrides
    func tableView(tableView: NSTableView, mouseDownInHeaderOfTableColumn tableColumn: NSTableColumn) {
        let columnIndex = tableView.columnWithIdentifier(tableColumn.identifier)
        guard columnIndex >= 0 else {return}
        guard let ascending = tableColumn.sortDescriptorPrototype?.ascending else {return}
        self.myCSVdataDocument.sortParametersOrValues(indexToSort: columnIndex, textOrvalue: self.segmentSortTextOrValue.selectedSegment, ascending:ascending)
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
            return self.myCSVdataDocument.numberOfRowsOfData()
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
            cellView.textField!.stringValue = self.myCSVdataDocument.csvDataModel.csvData[row][colIndex]
            
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
