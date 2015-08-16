//
//  HeadingsViewController.swift
//  aecombiner
//
//  Created by David JM Lewis on 27/07/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa
import SpriteKit

class HeadingsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
        
    // MARK: - @IBOutlet
    
    @IBOutlet weak var tableViewHeaders: NSTableView!
    @IBOutlet weak var textFieldColumnRecodedName: NSTextField!
    
    @IBOutlet weak var chartView: ChartView!

    @IBOutlet weak var buttonModel: NSButton!
    
    // MARK: - @IBAction
    @IBAction func sortChartParameters(sender: AnyObject) {
        self.chartView?.reSortYourParameters()
    }

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
    
    
    
    
    // MARK: - Charts

    @IBAction func modelParameter(sender: NSButton) {
    
        guard
                let chartview = self.chartView,
                let columnIndex = self.selectedColumnFromHeadersTableView(),
                let parameters = self.myCSVdataViewController()?.parametersAsDoublesFromColumnIndex(columnIndex: columnIndex)
        else {return}
        chartview.chartTheseParameters(parameters: parameters, nameOfParameters: "Untitled")
    }
    
    
    // MARK: - Sorting Tables on header click
    func tableView(tableView: NSTableView, mouseDownInHeaderOfTableColumn tableColumn: NSTableColumn) {
        self.sortParametersOrValuesInTableViewColumn(tableView: tableView, tableColumn: tableColumn)
    }
    

   func sortParametersOrValuesInTableViewColumn(tableView tableView: NSTableView, tableColumn: NSTableColumn)
    {
        //subclasses override
    }

    
    // MARK: - Columns
    func selectedColumnFromHeadersTableView() -> Int?
    {
        guard self.requestedColumnIndexIsOK(self.tableViewHeaders.selectedRow)
            else {return nil}
        return self.tableViewHeaders.selectedRow
    }
    
    func requestedColumnIndexIsOK(columnIndex:Int) -> Bool
    {
        guard let vc = self.myCSVdataViewController() else {return false}
        return vc.requestedColumnIndexIsOK(columnIndex)
    }
    
    func stringForColumnIndex(columnIndex:Int?) -> String
    {
        guard let csvdo = self.myCSVdataViewController() else {return "???"}
        return csvdo.stringForColumnIndex(columnIndex)
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

    // MARK: - CSVdataDocument
    
    
    func documentMakeDirty()
    {
        self.myCSVdataViewController()?.documentMakeDirty()
    }
        
    // MARK: - TableView overrides
        
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard let tvidentifier = tableView.identifier, let csvdo = self.myCSVdataViewController() else { return 0 }
        
        switch tvidentifier
        {
        case "tableViewHeaders":
            return csvdo.numberOfColumnsInData()
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
            default:
                break
        }
        
    }
    

    
}
