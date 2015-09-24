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
    var arrayButtonsForGrouping = [NSButton]()
    var headersExtractedDataModelForChart = HeadersMatrix()
    
    
    // MARK: - @IBOutlet
    @IBOutlet weak var tvGroupHeadersSecondary: NSTableView!
    
    @IBOutlet weak var buttonCombineColumns: NSButton!
    @IBOutlet weak var buttonExtractAllStatistics: NSButton!
    @IBOutlet weak var popupGroupMethod: NSPopUpButton!
    
    // MARK: - @IBAction

    @IBAction func groupToFileTapped(sender: NSButton) {
        self.groupToFile()
        
    }
    
    @IBAction func groupAndChartTapped(sender: NSButton) {
        self.groupAndChartData()
        
    }
    
    @IBAction func groupAllStatsToFileTapped(sender: AnyObject) {
        self.groupAllStatsToFile()
    }
    // MARK: - Buttons
    func updateButtonsForGrouping()
    {
        let enabled = columnsToGroupTogether().count>0
        for button in self.arrayButtonsForGrouping
        {
            button.enabled = enabled
        }
    }
    
    func addButtonsToArray()
    {
        guard
                self.buttonCombineColumns != nil &&
                self.buttonExtractAllStatistics != nil &&
                self.buttonModel != nil &&
                self.popupGroupMethod != nil
            else {return}
        self.arrayButtonsForGrouping.append(self.buttonCombineColumns)
        self.arrayButtonsForGrouping.append(self.buttonExtractAllStatistics)
        self.arrayButtonsForGrouping.append(self.buttonModel)
        self.arrayButtonsForGrouping.append(self.popupGroupMethod)
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
        switch popup
        {
        case self.popupHeaders:
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
        // we use self.extractedDataMatrixUsingPredicates which is a list of USERIDs usually (paramater to group) and values
        let extractedDataMatrix = CSVdata.extractTheseRowsFromDataMatrixAsDataMatrix(rows: indexes, datamatrix: self.extractedDataMatrixUsingPredicates)
        csvdatavc.createNewDocumentFromExtractedRows(cvsData: extractedDataMatrix, headers: self.headersExtractedDataModelForChart, name: nameOfDataSet)
    }
    
    
    func groupAndChartData()
    {
        guard self.okToGroup() else {return}
        guard
            let groupMethod = self.popupGroupMethod.titleOfSelectedItem,
            let cvc = self.chartViewController,
            let dvc = self.associatedCSVdataViewController,
            let columnIndexForGrouping = self.columnIndexToGroupBy()
            else {return}
        
        let arrayOfExtractedParametersInGroup = self.arrayOfExtractedParametersInGroup()
        let dataAndName = self.combinedColumnsAndNewColumnName(columnIndexForGrouping: columnIndexForGrouping, columnIndexesToGroup: columnsToGroupTogether(), arrayOfParamatersInGroup: arrayOfExtractedParametersInGroup, groupMethod: groupMethod)
        self.extractedDataMatrixUsingPredicates = dataAndName.matrixOfData
        self.headersExtractedDataModelForChart = [dvc.headerStringForColumnIndex(columnIndexForGrouping),dataAndName.nameOfData]
        let dataset = ChartDataSet(data: dataAndName.matrixOfData, forColumnIndex: kCsvDataData_column_value)
        cvc.plotNewChartDataSet(dataSet: dataset, nameOfChartDataSet: dataAndName.nameOfData)
    }
    

    // MARK: - Override for grouping
    func arrayToUseForfParametersToProcessIntoGroups()->DataMatrix
    {
        return self.arrayExtractedParameters
    }
    
    func columnIndexToGroupBy()->Int? // override in subclasses to substitute popup
    {
        return self.popupHeaders.indexOfSelectedItem == -1 ? nil : self.popupHeaders.indexOfSelectedItem
    }
    
    func columnsToGroupTogether()->NSIndexSet // override in subclasses to substitute popup
    {
        return self.tvGroupHeadersSecondary.selectedRowIndexes
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
        for parameter in self.arrayToUseForfParametersToProcessIntoGroups()
        {
            arrayOfExtractedParametersInGroup.append(parameter[kParametersArrayParametersIndex])
        }
        return arrayOfExtractedParametersInGroup
    }
    
    
    func okToGroup()->Bool
    {
        guard
            let csvdo = self.associatedCSVdataViewController
            else {return false}
        guard
            self.columnIndexToGroupBy() >= 0 &&
            self.columnIndexToGroupBy() < csvdo.numberOfColumnsInData() &&
            columnsToGroupTogether().count > 0 &&
            self.arrayToUseForfParametersToProcessIntoGroups().count > 0
            else {return false}
        
        return true
    }
    
    
    func groupAllStatsToFile()
    {
        guard self.okToGroup() else {return}
        guard
            let dvc = self.associatedCSVdataViewController,
            let columnIndexForGrouping = self.columnIndexToGroupBy()
            else {return}
        
        let arrayOfExtractedParametersInGroup = self.arrayOfExtractedParametersInGroup()
        
        
        dvc.combineColumnsAndExtractAllStatsToNewDocument(columnIndexForGrouping: columnIndexForGrouping, columnIndexesToGroup: columnsToGroupTogether(), arrayOfParamatersInGroup: arrayOfExtractedParametersInGroup)
        
    }

    func groupToFile()
    {
        guard self.okToGroup() else {return}
        guard
            let dvc = self.associatedCSVdataViewController,
            let columnIndexForGrouping = self.columnIndexToGroupBy(),
            let groupMethod = self.popupGroupMethod.titleOfSelectedItem
            else {return}
        
        let arrayOfExtractedParametersInGroup = self.arrayOfExtractedParametersInGroup()
        
        
        dvc.combineColumnsAndExtractToNewDocument(columnIndexForGrouping: columnIndexForGrouping, columnIndexesToGroup: columnsToGroupTogether(), arrayOfParamatersInGroup: arrayOfExtractedParametersInGroup, groupMethod: groupMethod)
        
    }
    
    
    
    // MARK: - TableView overrides
    
    override func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard   let tvidentifier = tableView.identifier,
                let csvdo = self.associatedCSVdataViewController
            else {return 0}
        switch tvidentifier
        {
        case "tvGroupHeadersSecondary":
            return csvdo.numberOfColumnsInData()
        case "tvGroupParameters":
            self.labelNumberOfParameterOrGroupingItems.stringValue = "\(self.arrayToUseForfParametersToProcessIntoGroups().count) in group"
            return self.arrayToUseForfParametersToProcessIntoGroups().count
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
                cellView.textField!.stringValue = self.arrayToUseForfParametersToProcessIntoGroups()[row][kParametersArrayParametersIndex]
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
            self.updateButtonsForGrouping()

        default:
            break;
        }
    }
    

}
