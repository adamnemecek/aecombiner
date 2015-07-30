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
    
   
    
    /* MARK: - Represented Object
    func updateRepresentedObjectToCSVData(csvdata:CSVdata)
    {
        self.representedObject = csvdata
    }
    */
    
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

    func myCSVdataObject() -> CSVdata
    {
        guard let csv = myCSVdataViewController()?.csvDataObject else {return CSVdata()}
        return csv
    }
    
    // MARK: - @IBAction
    
    @IBAction func renameColumn(sender: AnyObject) {
        
    }

    @IBAction func deleteHeading(sender: AnyObject) {
        self.myCSVdataViewController()?.deleteColumnAtIndex(self.tableViewHeaders.selectedRow)
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
        
    // MARK: - TableView overrides
        
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard let tvidentifier = tableView.identifier else
        {
            return 0
        }
        switch tvidentifier
        {
        case "tableViewHeaders":
            return self.myCSVdataObject().headers.count
        default:
            return 0
        }
    }
    
    func cellForHeadersTable(tableView tableView: NSTableView, row: Int) ->NSTableCellView
    {
        let cellView = tableView.makeViewWithIdentifier("headersCell", owner: self) as! NSTableCellView
        cellView.textField!.stringValue = self.myCSVdataObject().headers[row]
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
            self.textFieldColumnRecodedName?.stringValue = self.myCSVdataObject().headers[self.tableViewHeaders.selectedRow]
        default:
            break
        }
        
    }
    

    
}
