//
//  HeadingsViewController.swift
//  aecombiner
//
//  Created by David JM Lewis on 27/07/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa

class HeadingsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    // MARK: - @IBOutlet
    
    @IBOutlet weak var tableViewHeaders: NSTableView!
    @IBOutlet weak var textFieldColumnRecodedName: NSTextField!
    
    // MARK: - Represented Object
    func updateRepresentedObjectToCSVData(csvdata:CSVdata)
    {
        self.representedObject = csvdata
    }
    
    // MARK: - @IBAction
    
    @IBAction func renameColumn(sender: AnyObject) {
        
    }

    // MARK: - Column parameters
   func selectedColumnFromHeadersTableView() -> Int?
    {
        let columnIndex = self.tableViewHeaders.selectedRow
        guard columnIndex >= 0 && columnIndex < (self.representedObject as! CSVdata).headers.count
            else
        {
            print("out of range in selectedColumnFromHeadersTableView")
            return nil
        }
        return columnIndex
    }
    
   func requestedColumnIndexIsOK(columnIndex:Int) -> Bool
    {
        return columnIndex >= 0 && columnIndex < (self.representedObject as! CSVdata).headers.count
    }
    
    func stringForColumnName(columnIndex:Int) -> String
    {
        guard self.requestedColumnIndexIsOK(columnIndex) else
        {
            print("columnIndex out of range in stringForColumnName")
            return ""
        }
        return (self.representedObject as! CSVdata).headers[columnIndex]
    }
    

    // MARK: - Document
    
    func documentMakeDirty()
    {
        guard let doc = NSDocumentController.sharedDocumentController().currentDocument else
        {
            print("No document documentMakeDirty")
            return
        }
        (doc as! Document).updateChangeCount(.ChangeDone)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.tableViewHeaders?.reloadData()

    }
    
    
    
    // MARK: - TableView overrides
        
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard let tvidentifier = tableView.identifier else
        {
            return 0
        }
        switch tvidentifier
        {
        case "tableViewHeaders":
            return (self.representedObject as! CSVdata).headers.count
        default:
            return 0
        }
    }
    
    func cellForHeadersTable(tableView tableView: NSTableView, row: Int) ->NSTableCellView
    {
        let cellView = tableView.makeViewWithIdentifier("headersCell", owner: self) as! NSTableCellView
        cellView.textField!.stringValue = (self.representedObject as! CSVdata).headers[row]
        return cellView
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
        case "tableViewHeaders":
            cellView = self.cellForHeadersTable(tableView: tableView, row: row)
            
        default:
            break;
        }
        
        
        // Return the cellView
        return cellView;
    }
    
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        let tableView = notification.object as! NSTableView
        guard let columnIndex = self.selectedColumnFromHeadersTableView() where tableView.identifier != nil
            else
        {
            print("columnIndex out of range in tableViewSelectionDidChange")
            return
        }

        switch tableView.identifier!
        {
        case "tableViewHeaders":
            self.textFieldColumnRecodedName.stringValue = self.stringForColumnName(columnIndex)
        default:
            break
        }
        
    }
    

    
}
