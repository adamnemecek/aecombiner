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

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.representedObject = CSVdata()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addColumnWithIdentifier:", name: "addColumnWithIdentifier", object: nil)

    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
            self.columnsClearAndRebuild()
            self.tableViewCSVdata.reloadData()
            
            
        }
    }

    // MARK: - CSV data table
   func columnsClearAndRebuild(){
        
        while self.tableViewCSVdata.tableColumns.count > 0
        {
            self.tableViewCSVdata.removeTableColumn(tableViewCSVdata.tableColumns.last!)
        }
        for var c = 0; c < (self.representedObject as! CSVdata).headers.count; c++
        {
            let col_title = (self.representedObject as! CSVdata).headers[c]
            let col = NSTableColumn(identifier: col_title)
            col.title = col_title
            self.tableViewCSVdata.addTableColumn(col)
            
        }
        
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
            return (self.representedObject as! CSVdata).csvData.count
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
            cellView.textField!.stringValue = (self.representedObject as! CSVdata).csvData[row][colIndex]
            
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
