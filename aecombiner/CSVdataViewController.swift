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
   func columnsClearAndRebuild(){
        
        while self.tableViewCSVdata.tableColumns.count > 0
        {
            self.tableViewCSVdata.removeTableColumn(tableViewCSVdata.tableColumns.last!)
        }
        for var c = 0; c < self.csvDataObject.headers.count; c++
        {
            let col_title = self.csvDataObject.headers[c]
            let col = NSTableColumn(identifier: col_title)
            col.title = col_title
            self.tableViewCSVdata.addTableColumn(col)
            
        }
        
    }
    
    func deleteColumnWithIdentifier(identifier: String)
    {
        guard let column = self.tableViewCSVdata.tableColumnWithIdentifier(identifier) else {return}
        self.tableViewCSVdata.removeTableColumn(column)
    }
    
    func addColumnWithIdentifier(notification: NSNotification)
    {
        let column_identifier = notification.object as! String
        let col = NSTableColumn(identifier:column_identifier)
        col.title = column_identifier
        self.tableViewCSVdata.addTableColumn(col)
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
