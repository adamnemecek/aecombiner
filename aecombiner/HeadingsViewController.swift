//
//  HeadingsViewController.swift
//  aecombiner
//
//  Created by David JM Lewis on 27/07/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa
import SpriteKit

class HeadingsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, ChartViewControllerDelegate {
    
    
    // MARK: - Var
    var extractedDataMatrixUsingPredicates = DataMatrix()//used in some subclasses
    var associatedCSVdataViewController: CSVdataViewController?

    
    // MARK: - @IBOutlet
    
    @IBOutlet weak var tvHeaders: NSTableView!
    @IBOutlet weak var textFieldColumnRecodedName: NSTextField!
    
    weak var chartViewController: ChartViewController!

    @IBOutlet weak var buttonModel: NSButton!
    @IBOutlet weak var buttonSortParameters: NSButton!
    @IBOutlet weak var buttonTrash: NSButton!
    @IBOutlet weak var segmentCursorState: NSSegmentedControl!
    
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
        self.associatedCSVdataViewController?.renameColumnAtIndex(self.tvHeaders.selectedRow, newName: self.textFieldColumnRecodedName.stringValue)
    }
    
    @IBAction func deleteHeading(sender: AnyObject) {
        
        let alert = NSAlert()
        alert.alertStyle = .CriticalAlertStyle
        alert.messageText = "Are you sure you want to delete '"+self.titleForSelectedColumnInHeaders(self.tvHeaders)+"'?\nIt cannot be undone."
        alert.addButtonWithTitle("Delete")
        alert.addButtonWithTitle("Cancel")
        
        alert.beginSheetModalForWindow(self.view.window!) { (response) -> Void in
            if response == NSAlertFirstButtonReturn
            {
                self.associatedCSVdataViewController?.deleteColumnAtIndex(self.tvHeaders.selectedRow)
                self.tvHeaders.reloadData()
            }
        }
    }
    
    
    
    // MARK: - @IBAction Charts
    @IBAction func sortSelectedDataSet(sender: AnyObject) {
        guard
            let chartviewC = self.chartViewController,
            let columnIndex = self.selectedColumnFromHeadersTableView(self.tvHeaders)
            else {return}
        chartviewC.reSortThisChartDataSet(dataSetName: self.headerStringForColumnIndex(columnIndex),flipDirection:true)
    }

    @IBAction func chartSelectedDataSet(sender: NSButton) {
        guard
                let chartviewC = self.chartViewController,
                let columnIndex = self.selectedColumnFromHeadersTableView(self.tvHeaders),
                let dataSet = self.associatedCSVdataViewController?.chartDataSetFromColumnIndex(columnIndex: columnIndex)
            else {return}
        chartviewC.plotNewChartDataSet(dataSet: dataSet, nameOfChartDataSet: self.headerStringForColumnIndex(columnIndex))
    }
    
    // MARK: - ChartViewControllerDelegate

    func extractRowsIntoNewCSVdocumentWithIndexesFromChartDataSet(indexes: NSMutableIndexSet, nameOfDataSet: String) {
        // over ridden in subclasses
        guard let csvdatavc = self.associatedCSVdataViewController,
                let datamatrix = csvdatavc.dataMatrixFromAssociatedCSVdataDocument()
        else {return}
        // we use self.extractedDataMatrixUsingPredicates
        let extractedDataMatrix = CSVdata.extractTheseRowsFromDataMatrixAsDataMatrix(rows: indexes, datamatrix: datamatrix)
        csvdatavc.createNewDocumentFromExtractedRows(cvsData: extractedDataMatrix, headers: nil, name: nameOfDataSet)

    }
    
    
    // MARK: - Sorting Tables on header click
    func tableView(tableView: NSTableView, mouseDownInHeaderOfTableColumn tableColumn: NSTableColumn) {
        // inheriteds override
    
    }
    

    func sortParametersOrValuesInTableViewColumn(tableView tableView: NSTableView, tableColumn: NSTableColumn, inout arrayToSort:DataMatrix, textOrValue:Int)
    {
        guard tableView.columnWithIdentifier(tableColumn.identifier) >= 0 else {return}
        if tableColumn.sortDescriptorPrototype == nil
        {
            tableColumn.sortDescriptorPrototype = NSSortDescriptor(key: nil, ascending: true)
        }
        
        let columnIndex = tableView.columnWithIdentifier(tableColumn.identifier)
        let sortdirection = tableColumn.sortDescriptorPrototype!.ascending
        generic_SortArrayOfColumnsAsTextOrValues(arrayToSort: &arrayToSort, columnIndexToSort: columnIndex, textOrvalue: textOrValue, direction: sortdirection)
        tableColumn.sortDescriptorPrototype = NSSortDescriptor(key: nil, ascending: !sortdirection)
    }

    
    // MARK: - Columns
    func selectedColumnFromHeadersTableView(tableview: NSTableView) -> Int?
    {
        return self.requestedColumnIndexIsOK(tableview.selectedRow)
    }
    
    func titleForSelectedColumnInHeaders(tableview: NSTableView)->String
    {
        return self.headerStringForColumnIndex(self.selectedColumnFromHeadersTableView(tableview))
    }
    
    func requestedColumnIndexIsOK(columnIndex:Int) -> Int?
    {
        guard let vc = self.associatedCSVdataViewController else {return nil}
        return vc.requestedColumnIndexIsOK(columnIndex)
    }
    
    func headerStringForColumnIndex(columnIndex:Int?) -> String
    {
        guard let csvdo = self.associatedCSVdataViewController else {return "???"}
        return csvdo.headerStringForColumnIndex(columnIndex)
    }
    
    //MARK: - Supers overrides
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear() {
        super.viewWillAppear()
        self.associatedCSVdataViewController = (self.view.window?.sheetParent?.windowController as? CSVdataWindowController)?.contentViewController as? CSVdataViewController
        self.tvHeaders?.reloadData()

    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // Do view setup here.
    }

    
    
    // MARK: - Segue
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if let cvc = (segue.destinationController as? ChartViewController)
        {
            self.chartViewController = cvc
        }

        
    }
    
    // MARK: - CSVdataDocument
    
    func documentMakeDirty()
    {
        self.associatedCSVdataViewController?.documentMakeDirty()
    }
        
    // MARK: - TableView overrides
        
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard let csvdo = self.associatedCSVdataViewController else { return 0 }
        
        switch tableView
        {
        case self.tvHeaders:
            return csvdo.numberOfColumnsInData()
        default:
            return 0
        }
    }
    
    
    func cellForHeadersTable(tableView tableView: NSTableView, row: Int) ->NSTableCellView
    {
        let cellView = tableView.makeViewWithIdentifier("headersCell", owner: self) as! NSTableCellView
        cellView.textField!.stringValue = self.headerStringForColumnIndex(row)
        return cellView
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // Retrieve to get the @"MyView" from the pool or,
        // if no version is available in the pool, load the Interface Builder version
        var cellView = NSTableCellView()

       switch tableView
        {
        case self.tvHeaders:
            cellView = self.cellForHeadersTable(tableView: tableView, row: row)
            
        default:
            break;
        }
        
        
        // Return the cellView
        return cellView;
    }
    
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        guard let tableView = (notification.object as? NSTableView) else {return}

        switch tableView
        {
        case self.tvHeaders:
            self.enableButtons(enabled: tableView.selectedRowIndexes.count>0)
            default:
                break
        }
        
    }
    
    func enableButtons(enabled enabled:Bool)
    {
        self.buttonModel?.enabled = enabled
        self.buttonSortParameters?.enabled = enabled
        self.buttonTrash?.enabled = enabled

    }
    
}
