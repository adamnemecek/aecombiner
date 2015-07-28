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
        let columnIndex = self.tableViewHeaders.selectedRow
        guard let dvc = self.myCSVdataViewController() where self.requestedColumnIndexIsOK(columnIndex)
            else {return}
        // must add the column to Array BEFORE adding column to table
        for var r = 0; r<self.myCSVdataObject().csvData.count; r++
        {
            var rowArray = self.myCSVdataObject().csvData[r]
            rowArray.removeAtIndex(columnIndex)
            self.myCSVdataObject().csvData[r] = rowArray
        }
        //remove from headers array
        self.myCSVdataObject().headers.removeAtIndex(columnIndex)
        //Safe to add column to table now
        dvc.tableViewCSVdata.removeTableColumn(dvc.tableViewCSVdata.tableColumns[columnIndex])
        dvc.tableViewCSVdata.reloadData()
        self.documentMakeDirty()
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
    

    
    // MARK: - Column parameters
   func selectedColumnFromHeadersTableView() -> Int?
    {
        guard self.requestedColumnIndexIsOK(self.tableViewHeaders.selectedRow)
            else
        {
            print("out of range in selectedColumnFromHeadersTableView")
            return nil
        }
        return self.tableViewHeaders.selectedRow
    }
    
   func requestedColumnIndexIsOK(columnIndex:Int) -> Bool
    {
        return columnIndex >= 0 && columnIndex < self.myCSVdataObject().headers.count
    }
    
    func stringForColumnName(columnIndex:Int) -> String
    {
        guard self.requestedColumnIndexIsOK(columnIndex) else
        {
            print("columnIndex out of range in stringForColumnName")
            return ""
        }
        return (self.myCSVdataObject().headers[columnIndex])
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
            self.textFieldColumnRecodedName?.stringValue = self.stringForColumnName(columnIndex)
        default:
            break
        }
        
    }
    

    
}
