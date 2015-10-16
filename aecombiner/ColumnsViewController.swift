//
//  ColumnSortingChartingViewController.swift
//  aecombiner
//
//  Created by David JM Lewis on 27/07/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa
import SpriteKit

class ColumnsViewController: ColumnSortingChartingViewController {
    
    
    
    // MARK: - @IBOutlet
    @IBOutlet weak var tvHeaders: NSTableView!
    @IBOutlet weak var textFieldColumnRecodedName: NSTextField!
    @IBOutlet weak var buttonModel: NSButton!
    @IBOutlet weak var buttonTrash: NSButton!

    // MARK: - @IBAction
    @IBAction func renameColumn(sender: AnyObject) {
        guard
            let csdo = self.associatedCSVdataViewController
            else {return}
        
        guard !self.textFieldColumnRecodedName.stringValue.isEmpty else
        {
            let alert = NSAlert()
            alert.messageText = "Name cannot be empty"
            alert.alertStyle = .CriticalAlertStyle
            alert.runModal()
            return
        }
        csdo.renameColumnAtIndex(self.tvHeaders.selectedRow, newName: self.textFieldColumnRecodedName.stringValue)
    }
    
    @IBAction func deleteHeading(sender: AnyObject) {
        
        guard
        let csdo = self.associatedCSVdataViewController,
            let csvdatamodel = self.associatedCSVmodel
        else {return}
        
        let alert = NSAlert()
        alert.alertStyle = .CriticalAlertStyle
        alert.messageText = "Are you sure you want to delete '"+csvdatamodel.headerStringForColumnIndex(self.tvHeaders.selectedRow)+"'?\nIt cannot be undone."
        alert.addButtonWithTitle("Delete")
        alert.addButtonWithTitle("Cancel")
        
        alert.beginSheetModalForWindow(self.view.window!) { (response) -> Void in
            guard
                response == NSAlertFirstButtonReturn &&
                csdo.deletedColumnAtIndex(self.tvHeaders.selectedRow)
            else {return}
            self.tvHeaders.reloadData()
        }
    }
    
    // MARK: - @IBAction Charts
    @IBAction func sortSelectedDataSet(sender: AnyObject) {
        guard
            let chartviewC = self.chartViewController,
            let csvdatamodel = self.associatedCSVmodel
            else {return}
        chartviewC.reSortThisChartDataSet(dataSetName: csvdatamodel.headerStringForColumnIndex(self.tvHeaders.selectedRow),flipDirection:true)
    }
    
    @IBAction func chartSelectedDataSetTapped(sender: NSButton)
    {
        self.chartSelectedDataSet()
    }

    func chartSelectedDataSet()
    {
        guard
            let chartviewC = self.chartViewController,
            let csvdatamodel = self.associatedCSVmodel
            else {return}
        let dataSet = csvdatamodel.chartDataSetFromColumnIndexes(columnIndexes: NSIndexSet(index: self.tvHeaders.selectedRow))
        chartviewC.plotNewChartDataSet(dataSet: dataSet, nameOfChartDataSet: csvdatamodel.headerStringForColumnIndex(self.tvHeaders.selectedRow))
    }

    
    override func extractRowsIntoNewCSVdocumentWithIndexesFromChartDataSet(indexes: NSMutableIndexSet, nameOfDataSet: String) {
        guard let csvdata = self.associatedCSVdataDocument?.csvDataModel else {return}
        
        // 1 step as we use self.associatedCSVdataDocument?.csvDataModel directly
        csvdata.createNewDocumentFromRowsInIndexSet(rows: indexes, docName: nameOfDataSet)
    }

    // MARK: - overrides
    override func viewWillAppear() {
        super.viewWillAppear()

        self.tvHeaders?.reloadData()
        
    }

    
    // MARK: - TableView overrides
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard let csvdo = self.associatedCSVmodel else {return 0}
        
        switch tableView
        {
        case self.tvHeaders:
            return csvdo.numberOfColumnsInData()
        default:
            return 0
        }
    }
    
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // Retrieve to get the @"MyView" from the pool or,
        // if no version is available in the pool, load the Interface Builder version
        var cellView = NSTableCellView()
        
        switch tableView
        {
        case self.tvHeaders:
            guard
                let csvdatamodel = self.associatedCSVmodel
            else {return cellView}
            cellView = csvdatamodel.cellForHeadersTable(tableView: tableView, row: row)
            
        default:
            break
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
        self.buttonTrash?.enabled = enabled
    }

}

