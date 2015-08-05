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
    
   
    
    // MARK: - Columns
    func selectedColumnFromHeadersTableView() -> Int?
    {
        guard self.requestedColumnIndexIsOK(self.tableViewHeaders.selectedRow)
            else {return nil}
        return self.tableViewHeaders.selectedRow
    }
    
    func requestedColumnIndexIsOK(columnIndex:Int) -> Bool
    {
        return self.myCSVdataObject() != nil && columnIndex >= 0 && columnIndex < self.myCSVdataObject()?.headers.count
    }
    
    func stringForColumnIndex(columnIndex:Int?) -> String
    {
        guard let index = columnIndex, let csvdo = self.myCSVdataObject() where self.requestedColumnIndexIsOK(index) else {return "???"}
        return (csvdo.headers[index])
    }
    
    //MARK: - Supers overrides
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // Do view setup here.
        self.tableViewHeaders?.reloadData()
    }

    
    func myCSVdataViewController() -> CSVdataViewController?
    {
        return (self.view.window?.sheetParent?.windowController as? CSVdataWindowController)?.contentViewController as? CSVdataViewController
    }

    func myCSVdataObject() -> CSVdata?
    {
        //guard let csv = myCSVdataViewController()?.csvDataObject else {return CSVdata()}
        return myCSVdataViewController()?.csvDataObject
    }
    
    // MARK: - @IBAction
    
    @IBAction func renameColumn(sender: AnyObject) {
        guard !self.textFieldColumnRecodedName.stringValue.isEmpty else
        {
            let alert = NSAlert()
            alert.messageText = "Name cannot be empty"
            alert.alertStyle = .CriticalAlertStyle
            alert.runModal()
            return
        }
        self.myCSVdataViewController()?.renameColumnAtIndex(self.tableViewHeaders.selectedRow, newName: self.textFieldColumnRecodedName.stringValue)
    }

    @IBAction func deleteHeading(sender: AnyObject) {
        self.myCSVdataViewController()?.deleteColumnAtIndex(self.tableViewHeaders.selectedRow)
        self.tableViewHeaders.reloadData()
    }
    
    // MARK: - CSVdataDocument
    
    
    func documentMakeDirty()
    {
        CSVdataDocument.makeDocumentDirtyForView(self.view)
    }
        
    // MARK: - TableView overrides
        
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard let tvidentifier = tableView.identifier, let csvdo = self.myCSVdataObject() else
        {
            return 0
        }
        switch tvidentifier
        {
        case "tableViewHeaders":
            return csvdo.headers.count
        default:
            return 0
        }
    }
    
    
    func cellForHeadersTable(tableView tableView: NSTableView, row: Int) ->NSTableCellView
    {
        let cellView = tableView.makeViewWithIdentifier("headersCell", owner: self) as! NSTableCellView
        cellView.textField!.stringValue = self.stringForColumnIndex(row)
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
        guard let tableViewID = (notification.object as? NSTableView)?.identifier
            else {return}

        switch tableViewID
        {
        case "tableViewHeaders":
            self.textFieldColumnRecodedName?.stringValue = self.stringForColumnIndex(self.tableViewHeaders.selectedRow)
        default:
            break
        }
        
    }
    

    
}
