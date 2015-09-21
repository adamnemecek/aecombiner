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
    var arrayButtonsForExtracting = [NSButton]()
    var headersExtractedDataModelForChart = HeadersMatrix()
    
    
    // MARK: - @IBOutlet
    @IBOutlet weak var tvGroupHeadersSecondary: NSTableView!
    
    @IBOutlet weak var buttonCombineColumns: NSButton!
    @IBOutlet weak var buttonExtractAllStatistics: NSButton!
    @IBOutlet weak var popupAddOrMultiply: NSPopUpButton!
    
    // MARK: - @IBAction

    @IBAction func combineAndExtractColumnsTapped(sender: NSButton) {
        self.combineCoumnsAndExtract()
        
    }
    
    @IBAction func combineAndChartColumnsTapped(sender: NSButton) {
        self.combineColumnsAndChartData()
        
    }
    
    @IBAction func combineAndExtractAllStatsToFile(sender: AnyObject) {
        self.combineColumnsAndExtractAllStatsToFile()
    }
    // MARK: - Buttons
    func updateButtonsForExtracting()
    {
        let enabled = self.tvGroupHeadersSecondary.selectedRowIndexes.count>0
        for button in self.arrayButtonsForExtracting
        {
            button.enabled = enabled
        }
    }
    
    func addButtonsToArray()
    {
        guard self.buttonCombineColumns != nil else {return}
        self.arrayButtonsForExtracting.append(self.buttonCombineColumns)
        self.arrayButtonsForExtracting.append(self.buttonExtractAllStatistics)
        self.arrayButtonsForExtracting.append(self.buttonModel)
        self.arrayButtonsForExtracting.append(self.popupAddOrMultiply)
    }
    
    // MARK: - overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        // Do view setup here.
        self.populateHeaderPopups()
        self.tvGroupHeadersSecondary?.reloadData()
        self.addButtonsToArray()
        
    }
    override func viewDidAppear() {
        super.viewDidAppear()
        // Do view setup here.
    }
    
    // MARK: - header Popups
    override func popupChangedSelection(popup: NSPopUpButton)
    {
        guard let id = popup.identifier else {return}
        switch id
        {
        case "popupHeadersGroup":
            self.resetExtractedParameters()
            self.extractParametersIntoSetFromColumn()
            self.tvGroupHeadersSecondary.reloadData()
        default:
            break
        }
    }
    

    // MARK: - ChartViewControllerDelegate
    
    override func extractRowsIntoNewCSVdocumentWithIndexesFromChartDataSet(indexes: NSMutableIndexSet, nameOfDataSet: String) {
        guard let csvdatavc = self.associatedCSVdataViewController else {return}
        // we use self.extractedDataMatrixForChart which is a list of USERIDs usually (paramater to group) and values
        let extractedDataMatrix = CSVdata.extractTheseRowsFromDataMatrixAsDataMatrix(rows: indexes, datamatrix: self.extractedDataMatrixForChart)
        csvdatavc.createNewDocumentFromExtractedRows(cvsData: extractedDataMatrix, headers: self.headersExtractedDataModelForChart, name: nameOfDataSet)
    }
    
    
    func combineColumnsAndChartData()
    {
        guard self.okToCombine() else {return}
        guard
            let groupMethod = self.popupAddOrMultiply.titleOfSelectedItem,
            let cvc = self.chartViewController,
            let dvc = self.associatedCSVdataViewController
            else {return}
        
        let arrayOfExtractedParametersInGroup = self.arrayOfExtractedParametersInGroup()
        let dataAndName = self.combinedColumnsAndNewColumnName(columnIndexForGrouping: self.popupHeaders.indexOfSelectedItem, columnIndexesToGroup: self.tvGroupHeadersSecondary.selectedRowIndexes, arrayOfParamatersInGroup: arrayOfExtractedParametersInGroup, groupMethod: groupMethod)
        self.extractedDataMatrixForChart = dataAndName.matrixOfData
        self.headersExtractedDataModelForChart = [dvc.headerStringForColumnIndex(self.popupHeaders.indexOfSelectedItem),dataAndName.nameOfData]
        let dataset = ChartDataSet(data: dataAndName.matrixOfData, forColumnIndex: kCsvDataData_column_value)
        cvc.plotNewChartDataSet(dataSet: dataset, nameOfChartDataSet: dataAndName.nameOfData)
    }
    

    // MARK: - Columns
    
    func combinedColumnsAndNewColumnName(columnIndexForGrouping columnIndexForGrouping:Int, columnIndexesToGroup: NSIndexSet, arrayOfParamatersInGroup:ArrayOfStringOneRow , groupMethod:String) -> NamedDataMatrix//(csvDataMatrix:DataMatrix, nameOfColumn:String)
    {
        guard let csvdo = self.associatedCSVdataViewController else {return NamedDataMatrix(matrix:DataMatrix(),name: "")}
        return csvdo.combinedColumnsAndNewColumnName(columnIndexForGrouping: columnIndexForGrouping, columnIndexesToGroup: columnIndexesToGroup, arrayOfParamatersInGroup: arrayOfParamatersInGroup, groupMethod: groupMethod)
    }
    
    func arrayOfExtractedParametersInGroup()->ArrayOfStringOneRow
    {
        //create an array with the keys the params we extracted for grouping
        var arrayOfExtractedParametersInGroup = ArrayOfStringOneRow()
        for parameter in self.arrayExtractedParameters
        {
            arrayOfExtractedParametersInGroup.append(parameter[kParametersArrayParametersIndex])
        }
        return arrayOfExtractedParametersInGroup
    }
    
    
    func okToCombine()->Bool
    {
        guard
            let csvdo = self.associatedCSVdataViewController
            else {return false}
        guard
            self.popupHeaders.indexOfSelectedItem >= 0 &&
            self.popupHeaders.indexOfSelectedItem < csvdo.numberOfColumnsInData() &&
            self.tvGroupHeadersSecondary.selectedRowIndexes.count > 0 &&
            self.arrayExtractedParameters.count > 0
            else {return false}
        
        return true
    }
    
    
    func combineColumnsAndExtractAllStatsToFile()
    {
        guard self.okToCombine() else {return}
        guard
            let dvc = self.associatedCSVdataViewController else {return}
        
        let arrayOfExtractedParametersInGroup = self.arrayOfExtractedParametersInGroup()
        
        
        dvc.combineColumnsAndExtractAllStatsToNewDocument(columnIndexForGrouping: self.popupHeaders.indexOfSelectedItem, columnIndexesToGroup: self.tvGroupHeadersSecondary.selectedRowIndexes, arrayOfParamatersInGroup: arrayOfExtractedParametersInGroup)
        
    }

    func combineCoumnsAndExtract()
    {
        guard self.okToCombine() else {return}
        guard
            let dvc = self.associatedCSVdataViewController,
            let groupMethod = self.popupAddOrMultiply.titleOfSelectedItem
            else {return}
        
        let arrayOfExtractedParametersInGroup = self.arrayOfExtractedParametersInGroup()
        
        
        dvc.combineColumnsAndExtractToNewDocument(columnIndexForGrouping: self.popupHeaders.indexOfSelectedItem, columnIndexesToGroup: self.tvGroupHeadersSecondary.selectedRowIndexes, arrayOfParamatersInGroup: arrayOfExtractedParametersInGroup, groupMethod: groupMethod)
        
    }
    
    
    
    // MARK: - TableView overrides
    
    override func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard let tvidentifier = tableView.identifier, let csvdo = self.associatedCSVdataViewController else
        {
            return 0
        }
        switch tvidentifier
        {
        case "tvGroupHeadersSecondary":
            return csvdo.numberOfColumnsInData()
        case "tvGroupParameters":
            self.labelNumberOfParameterOrGroupingItems.stringValue = "\(self.arrayExtractedParameters.count) in group"
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
        case "tvGroupHeadersSecondary":
            cellView = self.cellForHeadersTable(tableView: tableView, row: row)
        case "tvGroupParameters":
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

        case "tvGroupHeadersSecondary":
            break
        default:
            break;
        }
        self.updateButtonsForExtracting()
    }
    

}
