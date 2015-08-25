//
//  GroupParametersViewController.swift
//  aecombiner
//
//  Created by David JM Lewis on 11/08/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa

class GroupParametersViewController: RecodeColumnViewController {
    // MARK: - class vars
    var arrayHeadersSecondarySelected = DataMatrix()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // Do view setup here.
        self.tableViewGroupHeadersSecondary?.reloadData()
    }

    // MARK: - @IBOutlet
    @IBOutlet weak var tableViewGroupHeadersSecondary: NSTableView!
    
    @IBOutlet weak var buttonCombineColumns: NSButton!
    @IBOutlet weak var popupAddOrMultiply: NSPopUpButton!
    
    // MARK: - @IBOutlet

    @IBAction func combineAndExtractColumnsTapped(sender: NSButton) {
        self.combineCoumnsAndExtract()
        
    }
    
    @IBAction func combineAndChartColumnsTapped(sender: NSButton) {
        self.combineColumnsAndChartData()
        
    }
    
    // MARK: - Columns
    
    func combinedColumnsAndNewColumnName(columnIndexForGrouping columnIndexForGrouping:Int, columnIndexesToGroup: NSIndexSet, arrayOfParamatersInGroup: [String], groupMethod:Int) -> (cvsDataData:DataMatrix, nameOfColumn:String)
    {
        guard let csvdo = self.myCSVdataViewController() else {return (DataMatrix(), "")}
        return csvdo.combinedColumnsAndNewColumnName(columnIndexForGrouping: columnIndexForGrouping, columnIndexesToGroup: columnIndexesToGroup, arrayOfParamatersInGroup: arrayOfParamatersInGroup, groupMethod: groupMethod)
    }
    
    func arrayOfExtractedParametersInGroup()->[String]
    {
        //create an array with the keys the params we extracted for grouping
        var arrayOfExtractedParametersInGroup = [String]()
        for parameter in self.arrayExtractedParameters
        {
            arrayOfExtractedParametersInGroup.append(parameter[kParametersArrayParametersIndex])
        }
        return arrayOfExtractedParametersInGroup
    }
    
    
    func okToCombine()->Bool
    {
        guard
            let csvdo = self.myCSVdataViewController()
            else {return false}
        guard
            self.tableViewHeaders.selectedRow >= 0 &&
            self.tableViewHeaders.selectedRow < csvdo.numberOfColumnsInData() &&
            self.tableViewGroupHeadersSecondary.selectedRowIndexes.count > 0 &&
            self.arrayExtractedParameters.count > 0
            else {return false}
        
        return true
    }
    
    func combineColumnsAndChartData()
    {
        guard self.okToCombine() else {return}
        
        let arrayOfExtractedParametersInGroup = self.arrayOfExtractedParametersInGroup()
        let dataAndName = self.combinedColumnsAndNewColumnName(columnIndexForGrouping: self.tableViewHeaders.selectedRow, columnIndexesToGroup: self.tableViewGroupHeadersSecondary.selectedRowIndexes, arrayOfParamatersInGroup: arrayOfExtractedParametersInGroup, groupMethod: self.popupAddOrMultiply.indexOfSelectedItem)
        let dataset = ChartDataSet(data: dataAndName.cvsDataData, forColumnIndex: kCsvDataData_column_value)
        self.chartViewController?.plotNewChartDataSet(dataSet: dataset, nameOfChartDataSet: dataAndName.nameOfColumn)
    }

    
    func combineCoumnsAndExtract()
    {
        guard self.okToCombine() else {return}
        
        let arrayOfExtractedParametersInGroup = self.arrayOfExtractedParametersInGroup()
        
        self.myCSVdataViewController()!.combineColumnsAndExtractToNewDocument(columnIndexForGrouping: self.tableViewHeaders.selectedRow, columnIndexesToGroup: self.tableViewGroupHeadersSecondary.selectedRowIndexes, arrayOfParamatersInGroup: arrayOfExtractedParametersInGroup, groupMethod: self.popupAddOrMultiply.indexOfSelectedItem)
        
    }
    
    // MARK: - TableView overrides
    
    override func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard let tvidentifier = tableView.identifier, let csvdo = self.myCSVdataViewController() else
        {
            return 0
        }
        switch tvidentifier
        {
        case "tableViewGroupHeaders", "tableViewGroupHeadersSecondary":
            return csvdo.numberOfColumnsInData()
        case "tableViewGroupParameters":
            return self.arrayExtractedParameters.count
        default:
            return 0
        }
    }
    
    override func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // Retrieve to get the @"MyView" from the pool or,
        // if no version is available in the pool, load the Interface Builder version
        var cellView = NSTableCellView()
        guard let tvidentifier = tableView.identifier else {
            return cellView
        }
        switch tvidentifier
        {
        case "tableViewGroupHeaders", "tableViewGroupHeadersSecondary":
            cellView = self.cellForHeadersTable(tableView: tableView, row: row)
        case "tableViewGroupParameters":
            switch tableColumn!.identifier
            {
            case "parameter":
                cellView = tableView.makeViewWithIdentifier("dataSetCell", owner: self) as! NSTableCellView
                cellView.textField!.stringValue = self.arrayExtractedParameters[row][kParametersArrayParametersIndex]
        /*  case "value"://dataSet
                cellView = tableView.makeViewWithIdentifier("dataSetValueCell", owner: self) as! NSTableCellView
                cellView.textField!.stringValue = self.arrayExtractedParameters[row][kParametersArrayParametersValueIndex]
                cellView.textField!.tag = row */
            default:
                break
            }
        default:
            break;
        }
        
        
        // Return the cellView
        return cellView;
    }
    
    
    override func tableViewSelectionDidChange(notification: NSNotification) {
        let tableView = notification.object as! NSTableView
        switch tableView.identifier!
        {
        case "tableViewGroupHeaders":
            self.resetExtractedParameters()
            self.extractParametersIntoSetFromColumn()
            self.tableViewGroupHeadersSecondary.reloadData()
        default:
            break;
        }
        
    }
    

}
