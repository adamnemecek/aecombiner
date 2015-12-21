//
//  GroupParametersViewController.swift
//  aecombiner
//
//  Created by David JM Lewis on 11/08/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa

class GroupParametersViewController: ColumnSortingChartingViewController {
    // MARK: - class vars
    var arrayColumnsToGroupTogether = StringsMatrix2D()
    var arrayHeadersSecondarySelected = StringsMatrix2D()
    var arrayButtonsForGrouping = [NSButton]()
    var headersExtractedDataModelForChart = StringsArray1D()
    var groupedDataAfterCombiningToUseForCharting = StringsMatrix2D()//used in some subclasses
    
    
    // MARK: - @IBOutlet
    @IBOutlet weak var tvExtractedParametersToGroupBy: NSTableView!
    @IBOutlet weak var labelNumberOfParameterOrGroupingItems: NSTextField!
    @IBOutlet weak var tvGroupHeadersSecondary: NSTableView!
    
    @IBOutlet weak var buttonModelByGrouping: NSButton!
    @IBOutlet weak var buttonCombineColumns: NSButton!
    @IBOutlet weak var buttonExtractAllStatistics: NSButton!
    @IBOutlet weak var popupGroupMethod: NSPopUpButton!
    @IBOutlet weak var popupGroupBy: NSPopUpButton!

    // MARK: - @IBAction

    @IBAction func groupToFileUsingOneMethodTapped(sender: NSButton) {
        guard
            let groupMethod = self.popupGroupMethod.titleOfSelectedItem,
            let csdo = self.associatedCSVdataDocument?.csvDataModel
            else {return}
        
        csdo.combineColumnsAndExtractToNewDocument(columnIndexForGrouping: self.popupGroupBy.indexOfSelectedItem, columnIndexesToGroup: self.tvGroupHeadersSecondary.selectedRowIndexes, arrayOfParamatersInGroup: self.arrayOfExtractedParametersToGroupBy(), groupMethod: groupMethod)
    }
    
    @IBAction func groupAndChartTapped(sender: NSButton) {
        self.groupAndChartDataUsingSingleMethod()
        
    }
    
    @IBAction func groupAllStatsToFileTapped(sender: AnyObject) {
        guard
            let csdo = self.associatedCSVdataDocument?.csvDataModel
            else {return}

        //let arrayOfExtractedParametersToGroupBy = self.arrayOfExtractedParametersToGroupBy()
        csdo.combineColumnsAndExtractAllStatsToNewDocument(columnIndexForGrouping: self.popupGroupBy.indexOfSelectedItem, columnIndexesToGroup: columnsToGroupTogether(), columnIndexToRecord: nil)
    }
    
    @IBAction func popupGroupByButtonSelected(sender: NSPopUpButton) {
        self.popupChangedSelection(sender)
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
                self.buttonModelByGrouping != nil &&
                self.popupGroupMethod != nil
            else {return}
        self.arrayButtonsForGrouping.append(self.buttonCombineColumns)
        self.arrayButtonsForGrouping.append(self.buttonExtractAllStatistics)
        self.arrayButtonsForGrouping.append(self.buttonModelByGrouping)
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
    func populateHeaderPopups()
    {
        self.popupGroupBy.removeAllItems()
        guard let csvdo = self.associatedCSVdataDocument?.csvDataModel where csvdo.headersStringsArray1D.count>0
            else { return}
        self.popupGroupBy.addItemsWithTitles(csvdo.headerStringsForAllColumns())
        self.popupGroupBy.selectItemAtIndex(-1)
    }

    func popupChangedSelection(popup: NSPopUpButton)
    {
        switch popup
        {
        case self.popupGroupBy:
            self.resetExtractedParameters()
            self.extractParametersIntoSetFromColumn()
            self.tvGroupHeadersSecondary.reloadData()
        default:
            break
        }
    }
    
    func resetExtractedParameters()
    {
        self.arrayColumnsToGroupTogether = StringsMatrix2D()
        self.tvExtractedParametersToGroupBy?.reloadData()
        self.labelNumberOfParameterOrGroupingItems?.stringValue = ""
    }
    
    
    
    
    func extractParametersIntoSetFromColumn()
    {
        //called from Process menu
        guard
            let datamodel = self.associatedCSVmodel,
            let dmOfParams = datamodel.dataMatrixOfParametersFromColumn(fromColumn: self.popupGroupBy.indexOfSelectedItem)
            else { return }
        
        self.arrayColumnsToGroupTogether = dmOfParams
        self.tvExtractedParametersToGroupBy.reloadData()
        
    }

    // MARK: - ChartViewControllerDelegate
    
    override func extractRowsIntoNewCSVdocumentWithIndexesFromChartDataSet(indexes: NSMutableIndexSet, nameOfDataSet: String) {
        guard let csvdata = self.associatedCSVdataDocument?.csvDataModel else {return}
        
        // 2 step as we use self.groupedDataAfterCombiningToUseForCharting
        let extractedDataMatrix = CSVdata.extractTheseRowsFromDataMatrixAsDataMatrix(rows: indexes, datamatrix: self.groupedDataAfterCombiningToUseForCharting)
        csvdata.createNewDocumentFromExtractedRows(cvsData: extractedDataMatrix, headers: self.headersExtractedDataModelForChart, name: nameOfDataSet)
    }
    
    
    func groupAndChartDataUsingSingleMethod()
    {
        guard
            let groupMethod = self.popupGroupMethod.titleOfSelectedItem,
            let cvc = self.chartViewController,
            let csvdo = self.associatedCSVdataDocument?.csvDataModel,
            let columnIndexForGrouping = self.columnIndexToGroupBy()
            else {return}
        
        let arrayOfExtractedParametersToGroupBy = self.arrayOfExtractedParametersToGroupBy()
        let dataAndName = csvdo.combinedColumnsAndNewColumnName_UsingSingleMethod(columnIndexForGrouping: columnIndexForGrouping, columnIndexesToGroup: columnsToGroupTogether(), arrayOfParamatersInGroup: arrayOfExtractedParametersToGroupBy, groupMethod: groupMethod)
        self.groupedDataAfterCombiningToUseForCharting = dataAndName.matrixOfData
        self.headersExtractedDataModelForChart = [csvdo.headerStringForColumnIndex(columnIndexForGrouping),dataAndName.nameOfData]
        let dataset = ChartDataSet(data: dataAndName.matrixOfData, forColumnIndex: kCsvDataData_column_value)
        cvc.plotNewChartDataSet(dataSet: dataset, nameOfChartDataSet: dataAndName.nameOfData)
    }
    

    // MARK: - grouping
    
    func columnIndexToGroupBy()->Int? // override in subclasses to substitute popup
    {
        return self.popupGroupBy.indexOfSelectedItem == -1 ? nil : self.popupGroupBy.indexOfSelectedItem
    }
    
    func columnsToGroupTogether()->NSIndexSet // override in subclasses to substitute popup
    {
        return self.tvGroupHeadersSecondary.selectedRowIndexes
    }
    
    // MARK: - Columns
    
    
    
    
    func arrayOfExtractedParametersToGroupBy()->StringsArray1D
    {
        return PredicateForExtracting.createArrayFromExtractedParametersToGroup(params:self.arrayColumnsToGroupTogether)
    }
    
    
    

    func groupToFileUsingOneMethod()
    {
        guard
            let csdo = self.associatedCSVdataDocument?.csvDataModel,
            let groupMethod = self.popupGroupMethod.titleOfSelectedItem
            else {return}
        
        csdo.combineColumnsAndExtractToNewDocument(columnIndexForGrouping: self.popupGroupBy.indexOfSelectedItem, columnIndexesToGroup: self.tvGroupHeadersSecondary.selectedRowIndexes, arrayOfParamatersInGroup: self.arrayOfExtractedParametersToGroupBy(), groupMethod: groupMethod)
        
    }
    
    
    
    // MARK: - TableView overrides
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard   //let tvidentifier = tableView.identifier,
                let csvdo = self.associatedCSVdataDocument?.csvDataModel
            else {return 0}
        switch tableView
        {
        case tvGroupHeadersSecondary:
            return csvdo.numberOfColumnsInData()
        case tvExtractedParametersToGroupBy:
            self.labelNumberOfParameterOrGroupingItems.stringValue = "\(self.arrayColumnsToGroupTogether.count) in group"
            return self.arrayColumnsToGroupTogether.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // Retrieve to get the @"MyView" from the pool or,
        // if no version is available in the pool, load the Interface Builder version
        var cellView = NSTableCellView()
        //guard let tvidentifier = tableView.identifier else {return cellView}
        switch tableView
        {
        case tvGroupHeadersSecondary:
            guard let csvdm = self.associatedCSVmodel else { return cellView}
            cellView = csvdm.cellForHeadersTable(tableView: tableView, row: row)
        case tvExtractedParametersToGroupBy:
            switch tableColumn!.identifier
            {
            case "parameter":
                cellView = tableView.makeViewWithIdentifier("dataSetCell", owner: self) as! NSTableCellView
                cellView.textField!.stringValue = self.arrayColumnsToGroupTogether[row][ParametersValueBoolColumnIndexes.ParametersIndex.rawValue]
            default:
                break
            }
        default:
            break;
        }
        
        
        // Return the cellView
        return cellView;
    }
    
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        let tableView = notification.object as! NSTableView
        switch tableView
        {
        case tvGroupHeadersSecondary:
            self.updateButtonsForGrouping()

        default:
            break;
        }
    }
    

}
