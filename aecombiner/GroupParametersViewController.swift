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
    var arrayColumnsToGroupTogether = MulticolumnStringsArray()
    var arrayHeadersSecondarySelected = MulticolumnStringsArray()
    var arrayButtonsForGrouping = [NSButton]()
    var headersExtractedDataModelForChart = SingleColumnStringsArray()
    var groupedDataAfterCombiningToUseForCharting = MulticolumnStringsArray()//used in some subclasses
    
    
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
            let csdo = self.associatedCSVdataDocument
            else {return}
        
        csdo.combineColumnsAndExtractToNewDocument(columnIndexForGrouping: self.popupGroupBy.indexOfSelectedItem, columnIndexesToGroup: self.tvGroupHeadersSecondary.selectedRowIndexes, arrayOfParamatersInGroup: self.arrayOfExtractedParametersToGroupBy(), groupMethod: groupMethod)
    }
    
    @IBAction func groupAndChartTapped(sender: NSButton) {
        self.groupAndChartData()
        
    }
    
    @IBAction func groupAllStatsToFileTapped(sender: AnyObject) {
        guard
            let csdo = self.associatedCSVdataDocument
            else {return}

        //let arrayOfExtractedParametersToGroupBy = self.arrayOfExtractedParametersToGroupBy()
        csdo.combineColumnsAndExtractAllStatsToNewDocument(columnIndexForGrouping: self.popupGroupBy.indexOfSelectedItem, columnIndexesToGroup: columnsToGroupTogether())
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
        guard let csvdo = self.associatedCSVdataDocument else { return}
        self.popupGroupBy.removeAllItems()
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
        self.arrayColumnsToGroupTogether = MulticolumnStringsArray()
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
        guard let csvdata = self.associatedCSVdataDocument else {return}
        let extractedDataMatrix = CSVdata.extractTheseRowsFromDataMatrixAsDataMatrix(rows: indexes, datamatrix: self.groupedDataAfterCombiningToUseForCharting)
        csvdata.createNewDocumentFromExtractedRows(cvsData: extractedDataMatrix, headers: self.headersExtractedDataModelForChart, name: nameOfDataSet)
    }
    
    
    func groupAndChartData()
    {
        guard
            let groupMethod = self.popupGroupMethod.titleOfSelectedItem,
            let cvc = self.chartViewController,
            let csvdo = self.associatedCSVdataDocument,
            let columnIndexForGrouping = self.columnIndexToGroupBy()
            else {return}
        
        let arrayOfExtractedParametersToGroupBy = self.arrayOfExtractedParametersToGroupBy()
        let dataAndName = csvdo.combinedColumnsAndNewColumnName(columnIndexForGrouping: columnIndexForGrouping, columnIndexesToGroup: columnsToGroupTogether(), arrayOfParamatersInGroup: arrayOfExtractedParametersToGroupBy, groupMethod: groupMethod)
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
    
    
    
    class func createArrayFromExtractedParametersToGroup(params params:MulticolumnStringsArray)->SingleColumnStringsArray
    {
        //create an array with the keys the params we extracted for grouping
        var arrayOfExtractedParametersToGroupBy = SingleColumnStringsArray()
        for parameter in params
        {
            arrayOfExtractedParametersToGroupBy.append(parameter[kParametersArray_ParametersIndex])
        }
        return arrayOfExtractedParametersToGroupBy

    }
    
    func arrayOfExtractedParametersToGroupBy()->SingleColumnStringsArray
    {
        return GroupParametersViewController.createArrayFromExtractedParametersToGroup(params:self.arrayColumnsToGroupTogether)
    }
    
    
    

    func groupToFileUsingOneMethod()
    {
        guard
            let csdo = self.associatedCSVdataDocument,
            let groupMethod = self.popupGroupMethod.titleOfSelectedItem
            else {return}
        
        csdo.combineColumnsAndExtractToNewDocument(columnIndexForGrouping: self.popupGroupBy.indexOfSelectedItem, columnIndexesToGroup: self.tvGroupHeadersSecondary.selectedRowIndexes, arrayOfParamatersInGroup: self.arrayOfExtractedParametersToGroupBy(), groupMethod: groupMethod)
        
    }
    
    
    
    // MARK: - TableView overrides
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard   let tvidentifier = tableView.identifier,
                let csvdo = self.associatedCSVdataDocument
            else {return 0}
        switch tvidentifier
        {
        case "tvGroupHeadersSecondary":
            return csvdo.numberOfColumnsInData()
        case "tvGroupParameters":
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
        guard let tvidentifier = tableView.identifier else {
            return cellView
        }
        switch tvidentifier
        {
        case "tvGroupHeadersSecondary":
            guard let csvdm = self.associatedCSVmodel else { return cellView}
            cellView = csvdm.cellForHeadersTable(tableView: tableView, row: row)
        case "tvGroupParameters":
            switch tableColumn!.identifier
            {
            case "parameter":
                cellView = tableView.makeViewWithIdentifier("dataSetCell", owner: self) as! NSTableCellView
                cellView.textField!.stringValue = self.arrayColumnsToGroupTogether[row][kParametersArray_ParametersIndex]
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
        switch tableView.identifier!
        {
        case "tvGroupHeadersSecondary":
            self.updateButtonsForGrouping()

        default:
            break;
        }
    }
    

}
