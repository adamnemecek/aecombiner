//
//  TwoColumnsViewController.swift
//  aecombiner
//
//  Created by David JM Lewis on 15/10/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa

class TwoColumnsViewController: ColumnsViewController {

    
    @IBOutlet weak var buttonCopyColumns: NSButton!
    
    
    @IBAction func copyColumnsTapped(sender: AnyObject) {
        self.copyColumnsExecute()
    }
    
    func copyColumnsExecute()
    {
        guard
            let copiedCols = self.associatedCSVmodel?.copyColumnsToString(fromColumnIndexes: self.tvHeaders.selectedRowIndexes)
        else {return}
        NSPasteboard.generalPasteboard().clearContents()
        if NSPasteboard.generalPasteboard().setString(copiedCols, forType: NSPasteboardTypeTabularText) == false
        {
            print("Not copied: "+(copiedCols as String))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
    override func chartSelectedDataSet()
    {
        guard
            let chartviewC = self.chartViewController,
            let csvdatamodel = self.associatedCSVmodel
            else {return}
        if self.tvHeaders.selectedRowIndexes.count == 2
        {
            let dataSet = csvdatamodel.chartDataSetFromColumnIndexes(columnIndexes: self.tvHeaders.selectedRowIndexes)
            chartviewC.plotNewChartDataSet(dataSet: dataSet, nameOfChartDataSet: csvdatamodel.headerStringForColumnIndex(self.tvHeaders.selectedRow))
        }
        
    }
    
    override func tableViewSelectionDidChange(notification: NSNotification) {
        guard let tableView = (notification.object as? NSTableView) else {return}
        
        switch tableView
        {
        case self.tvHeaders:
            self.enableButtons(enabled: tableView.selectedRowIndexes.count == 2)
        default:
            break
        }
    }

    override func enableButtons(enabled enabled:Bool)
    {
        super.enableButtons(enabled: enabled)
        self.buttonCopyColumns?.enabled = self.tvHeaders.selectedRowIndexes.count > 0
    }

    // MARK: - TableView overrides
    
    override func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard let csvdo = self.associatedCSVmodel else {return 0}
        
        print(tableView.identifier)
        switch tableView
        {
        case self.tvHeaders:
            return csvdo.numberOfColumnsInData()
        default:
            return 0
        }
    }
    
    
    override func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
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
    

}
