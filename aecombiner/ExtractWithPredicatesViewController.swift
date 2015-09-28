//
//  ExtractWithPredicatesViewController.swift
//  aecombiner
//
//  Created by David JM Lewis on 17/07/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa


class ExtractWithPredicatesViewController: ColumnSortingChartingViewController {
    
    
    // MARK: - class vars
    var arrayColParams1 = MulticolumnStringsArray()
    var array2ColParams2 = MulticolumnStringsArray()
    var array1ColParams = MulticolumnStringsArray()
    var arrayPredicates = ArrayOfPredicatesForExtracting()
    var extractedDataMatrixUsingPredicatesForCharting = MulticolumnStringsArray()//used in some subclasses
   
    
    // MARK: - @IBOutlet
    
    
    @IBOutlet weak var tv1colParameters: NSTableView!
    @IBOutlet weak var tv2colParameters2: NSTableView!
    @IBOutlet weak var tv2colParameters1: NSTableView!
    @IBOutlet weak var tvPredicates: NSTableView!
    @IBOutlet weak var buttonModelByPredicates: NSButton!
    @IBOutlet weak var buttonRemovePredicate: NSButton!
    @IBOutlet weak var buttonChartExtractedRows: NSButton!

    @IBOutlet weak var popupParameterToChart: NSPopUpButton!
    @IBOutlet weak var popup1ColHeaders: NSPopUpButton!
    @IBOutlet weak var popup2colHeaders1: NSPopUpButton!
    @IBOutlet weak var popup2colHeaders2: NSPopUpButton!


    /* MARK: - Represented Object
    override func updateRepresentedObjectToCSVData(csvdata:CSVdata)
    {
        self.representedObject = csvdata
    }
*/
    // MARK: - @IBAction
    
    @IBAction func popupHeadersButtonSelected(sender: NSPopUpButton) {
        self.popupChangedSelection(sender)
    }

    @IBAction func addSelectedParameter(sender: NSButton) {
        self.addColumnAndSelectedParameter(sender.identifier!)
    }
    
    @IBAction func removeSelectedParameter(sender: NSButton) {
        self.removeColumnAndSelectedParameter(sender.identifier!)
    }
    
    @IBAction func clearANORarray(sender: NSButton) {
        self.clearPredicates(sender.identifier!)
    }
    
    
    @IBAction func extractRowsBasedOnPredicatesIntoNewFile(sender: NSButton) {
        guard let cdvc = self.associatedCSVdataViewController else {return}
        
        cdvc.extractRowsBasedOnPredicatesIntoNewFile(predicates: self.arrayPredicates)
    }
    
    @IBAction func extractRowsBasedOnPredicatesIntoModelForChart(sender: NSButton) {
        guard self.extractDataMatrixUsingPredicatesIntoArray() == true else {return}
        
        
        self.buttonChartExtractedRows.enabled = self.extractedDataMatrixUsingPredicatesForCharting.count>0
        self.chartExtractedRows(sender)
    }
    
    
    
    @IBAction func savePredicates(sender: NSButton) {
        let sp = NSSavePanel()
        sp.allowedFileTypes = ["aePreds"]
        if sp.runModal() == NSFileHandlingPanelOKButton
        {
            guard  let targetURL = sp.URL else {return}
            PredicateForExtracting.saveExtractingPredicatesArrayToURL(url: targetURL, predicatesarray: self.arrayPredicates)
        }
    }
    
    @IBAction func loadPredicates(sender: NSButton) {
        guard let csvdatavc = self.associatedCSVdataDocument else {return}
        let sp = NSOpenPanel()
        sp.allowsMultipleSelection = false
        sp.canChooseDirectories = false
        sp.allowedFileTypes = ["aePreds"]
        if sp.runModal() == NSFileHandlingPanelOKButton
        {
            guard  sp.URLs.count>0 else {return}
            guard  let newgpa = PredicateForExtracting.loadExtractingPredicatesArrayFromURL(url: sp.URLs[0]) else {return}
            self.arrayPredicates = csvdatavc.checkedExtractingPredicatesArray(newgpa)
            self.updateTableViewSelectedColumnAndParameters()
        }
    }
    
    // MARK: - overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }
    override func viewWillAppear() {
        super.viewWillAppear()
        self.populateHeaderPopups()
        self.tv1colParameters?.reloadData()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
    }
    
    // MARK: - header Popups
    func populateHeaderPopups()
    {
        guard let csvdo = self.associatedCSVdataDocument else { return}
        
        self.popupParameterToChart.removeAllItems()
        self.popupParameterToChart.addItemsWithTitles(csvdo.headerStringsForAllColumns())
        
        self.popup1ColHeaders.removeAllItems()
        self.popup1ColHeaders.addItemsWithTitles(csvdo.headerStringsForAllColumns())
        self.popup1ColHeaders.selectItemAtIndex(-1)
        
        self.popup2colHeaders1.removeAllItems()
        self.popup2colHeaders1.addItemsWithTitles(csvdo.headerStringsForAllColumns())
        self.popup2colHeaders1.selectItemAtIndex(-1)
        
        self.popup2colHeaders2.removeAllItems()
        self.popup2colHeaders2.addItemsWithTitles(csvdo.headerStringsForAllColumns())
        self.popup2colHeaders2.selectItemAtIndex(-1)
        
    }
    
    func popupChangedSelection(popup: NSPopUpButton)
    {
        guard let id = popup.identifier else {return}
        switch id
        {
        case "popup1ColHeaders":
            self.reset1ColExtractedParameters()
            self.extract1ColParametersIntoSet(colIndex: popup.indexOfSelectedItem)
            
        case "popup2colHeaders1":
            self.resetCol1ExtractedParameters()
            self.extractCol1ParametersIntoSetFromSelectedColumn()
            self.popup2colHeaders2?.selectItemAtIndex(-1)
            self.popup2colHeaders2.enabled = false
        case "popup2colHeaders2":
            self.resetCol2ExtractedParameters()
            self.extractCol2ParametersIntoSetFromHeaders2()
        default:
            break;
        }
        
    }

    func reset1ColExtractedParameters()
    {
        self.array1ColParams = MulticolumnStringsArray()
        self.tv1colParameters?.reloadData()
    }

    // MARK: - ChartViewControllerDelegate
    
    override func extractRowsIntoNewCSVdocumentWithIndexesFromChartDataSet(indexes: NSMutableIndexSet, nameOfDataSet: String) {
        guard let csvdatavc = self.associatedCSVdataDocument else {return}
        // we use self.extractedDataMatrixUsingPredicatesForCharting
        let extractedDataMatrix = CSVdata.extractTheseRowsFromDataMatrixAsDataMatrix(rows: indexes, datamatrix: self.extractedDataMatrixUsingPredicatesForCharting)
        csvdatavc.createNewDocumentFromExtractedRows(cvsData: extractedDataMatrix, headers: nil, name: nameOfDataSet)
    }

    func chartExtractedRows(sender: NSButton) {
        guard
            let chartviewC = self.chartViewController,
            let csvdm = self.associatedCSVmodel,
            let colIndex = csvdm.validatedColumnIndex(self.popupParameterToChart.indexOfSelectedItem)
            else {return}
        let dataset = ChartDataSet(data: self.extractedDataMatrixUsingPredicatesForCharting, forColumnIndex: colIndex)
        chartviewC.plotNewChartDataSet(dataSet: dataset, nameOfChartDataSet: csvdm.headerStringForColumnIndex(colIndex))
    }
    

    // MARK: - Sorting Tables on header click
    override func tableView(tableView: NSTableView, mouseDownInHeaderOfTableColumn tableColumn: NSTableColumn) {
        // inheriteds override
        guard let tvidentifier = tableView.identifier else {return}
        switch tvidentifier
        {
        case "tv1colParameters":
            tableView.sortParametersOrValuesInTableViewColumn(tableColumn: tableColumn, arrayToSort: &self.array1ColParams, textOrValue: self.segmentedSortAsTextOrNumbers.selectedSegment)
            tableView.reloadData()
        case "tv2colParameters1":
            tableView.sortParametersOrValuesInTableViewColumn(tableColumn: tableColumn, arrayToSort: &self.arrayColParams1, textOrValue: self.segmentedSortAsTextOrNumbers.selectedSegment)
            tableView.reloadData()
        case "tv2colParameters2":
            tableView.sortParametersOrValuesInTableViewColumn(tableColumn: tableColumn, arrayToSort: &self.array2ColParams2, textOrValue: self.segmentedSortAsTextOrNumbers.selectedSegment)
            tableView.reloadData()
            
        default:
            break
        }

    }

    // MARK: - TableView overrides
    
    
     func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard let tvidentifier = tableView.identifier
            else {return 0}
        
        switch tvidentifier
        {
        case "tv1colParameters":
            return self.array1ColParams.count
        case "tv2colParameters1":
            return self.arrayColParams1.count
        case "tv2colParameters2":
            return self.array2ColParams2.count
        case "tvPredicates":
            return self.arrayPredicates.count
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
        case "tv1colParameters":
            switch tableColumn!.identifier
            {
            case "parameter":
                cellView = tableView.makeViewWithIdentifier("parametersCell", owner: self) as! NSTableCellView
                cellView.textField!.stringValue = self.array1ColParams[row][kParametersArrayParametersIndex]
            case "value"://parameters
                cellView = tableView.makeViewWithIdentifier("parametersValueCell", owner: self) as! NSTableCellView
                cellView.textField!.stringValue = self.array1ColParams[row][kParametersArrayParametersValueIndex]
                cellView.textField!.tag = row
            default:
                break
            }
            
        case "tv2colParameters1":
            cellView = tableView.makeViewWithIdentifier("parametersCell", owner: self) as! NSTableCellView
            cellView.textField!.stringValue = self.arrayColParams1[row][kParametersArrayParametersIndex]
        case "tv2colParameters2":
            cellView = tableView.makeViewWithIdentifier("parametersCell", owner: self) as! NSTableCellView
            cellView.textField!.stringValue = self.array2ColParams2[row][kParametersArrayParametersIndex]
            
        case "tvPredicates":
            let predcellView = tableView.makeViewWithIdentifier("parameterImageCell", owner: self) as! ExtractingPredicateTableCellView
            predcellView.textField!.stringValue = self.arrayPredicates[row].columnNameToMatch
            predcellView.textFieldLower!.stringValue = self.arrayPredicates[row].stringToMatch
            predcellView.imageView!.image = NSImage(named: self.arrayPredicates[row].booleanOperator)
            return predcellView

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
            
        case "tv2colParameters1":
            self.resetCol2ExtractedParameters()
            self.popup2colHeaders2?.selectItemAtIndex(-1)
            self.popup2colHeaders2.enabled = true

        case "tvPredicates":
            self.buttonRemovePredicate.enabled = tableView.selectedRow != -1

        //case "tvGroupHeadersSecondaryExtract":
            //self.updateButtonsForGrouping()

        default:
            break;
        }

    }
    
    
    // MARK: - Column 1 2 parameters
    func extract1ColParametersIntoSet(colIndex colIndex:Int)
    {
        //called from Process menu
        self.array1ColParams = MulticolumnStringsArray()
       guard
            let datamodel = self.associatedCSVmodel,
            let newArray = datamodel.dataMatrixOfParametersFromColumn(fromColumn: colIndex)
            else { return }
        
        self.array1ColParams = newArray
        self.tv1colParameters.reloadData()
        
    }

    
    func resetCol1ExtractedParameters()
    {
        self.arrayColParams1 = MulticolumnStringsArray()
        self.array2ColParams2 = MulticolumnStringsArray()
        self.tv2colParameters1?.reloadData()
        self.tv2colParameters2?.reloadData()
    }
    
    func resetCol2ExtractedParameters()
    {
        self.array2ColParams2 = MulticolumnStringsArray()
        self.tv2colParameters2?.reloadData()
   }
    
    func extractCol1ParametersIntoSetFromSelectedColumn()
    {
        self.arrayColParams1 = MulticolumnStringsArray()
        guard let datamodel = self.associatedCSVmodel,
        let newArray = datamodel.dataMatrixOfParametersFromColumn(fromColumn: self.popup2colHeaders1.indexOfSelectedItem)
        else { return }
        
        self.arrayColParams1 = newArray
        self.tv2colParameters1.reloadData()
        
    }

    func param1SelectedIndex()->Int?
    {
        let index = self.tv2colParameters1.selectedRow
        return  index >= 0 && index < self.arrayColParams1.count ? index : nil
    }

    
    func extractCol2ParametersIntoSetFromHeaders2()
    {
        guard
            let csvdm = self.associatedCSVmodel,
            let columnToMatchIndex = csvdm.validatedColumnIndex(self.popup2colHeaders1.indexOfSelectedItem),
            let columnToExtractIndex = csvdm.validatedColumnIndex(self.popup2colHeaders2.indexOfSelectedItem),
            let safeParam1Index = self.param1SelectedIndex()
        else { return }

        let matchStr = self.arrayColParams1[safeParam1Index][kParametersArrayParametersIndex]
        guard
            let set = csvdm.setOfParametersFromColumnIfStringMatchedInColumn(fromColumn:columnToExtractIndex, matchString:matchStr, matchColumn:columnToMatchIndex)
        else { return }
        self.array2ColParams2 = CSVdata.dataMatrixWithNoBlanksFromSet(set: set)
        self.tv2colParameters2.reloadData()

        
    }

    
    // MARK: - AND OR tables
    func extractDataMatrixUsingPredicatesIntoArray()->Bool
    {
        guard let csvdo = self.associatedCSVdataDocument
            else {return false}
        self.extractedDataMatrixUsingPredicatesForCharting = csvdo.extractDataMatrixUsingPredicates(predicates: self.arrayPredicates)
        return true
    }

    func updateTableViewSelectedColumnAndParameters()
    {
        self.tvPredicates.reloadData()
        self.buttonRemovePredicate.enabled = false
    }
    
    func addColumnAndSelectedParameter(arrayIdentifier: String)
    {
        guard let csvdo = self.associatedCSVdataDocument else {return}
        let columnIndex: Int
        let parameterRows: NSIndexSet
        let arrayParamsToUse: MulticolumnStringsArray
        
        switch arrayIdentifier
        {
        case "addANDarray","addORarray","addNOTarray":
            columnIndex = self.popup1ColHeaders.indexOfSelectedItem
            parameterRows = self.tv1colParameters.selectedRowIndexes
            arrayParamsToUse = self.array1ColParams
        case "addANDarrayCol1","addORarrayCol1","addNOTarrayCol1":
            columnIndex = self.popup2colHeaders1.indexOfSelectedItem
            parameterRows = self.tv2colParameters1.selectedRowIndexes
            arrayParamsToUse = self.arrayColParams1
        case "addANDarrayCol2","addORarrayCol2","addNOTarrayCol2":
            columnIndex = self.popup2colHeaders2.indexOfSelectedItem
            parameterRows = self.tv2colParameters2.selectedRowIndexes
            arrayParamsToUse = self.array2ColParams2
        default:
            columnIndex = -1
            parameterRows = NSIndexSet()
            arrayParamsToUse = MulticolumnStringsArray()
        }

        
        guard
            columnIndex >= 0 &&
            columnIndex < csvdo.numberOfColumnsInData() &&
            parameterRows.count > 0
            else {return}
        
        for parameterIndex in parameterRows
        {
            if parameterIndex >= 0 && parameterIndex < arrayParamsToUse.count
            {
                let boolS:String
                switch arrayIdentifier
                {
                case "addANDarray", "addANDarrayCol1", "addANDarrayCol2":
                    boolS =  kBooleanStringAND
                case "addORarray","addORarrayCol1", "addORarrayCol2":
                      boolS =  kBooleanStringOR
                case "addNOTarray","addNOTarrayCol1", "addNOTarrayCol2":
                      boolS =  kBooleanStringNOT
                default:
                      boolS = ""
                    break
                }
                self.appendPredicateToArray(columnIndexToSearch: csvdo.headerStringForColumnIndex(columnIndex), matchString: arrayParamsToUse[parameterIndex][kParametersArrayParametersIndex], booleanString: boolS)

            }
        }

        self.updateTableViewSelectedColumnAndParameters()
    }
    
    
    func appendPredicateToArray(columnIndexToSearch columnName: String, matchString: String, booleanString: String)
    {
        let predicate = PredicateForExtracting(columnName: columnName, string: matchString, boolean: booleanString)
        guard self.arrayPredicates.indexOf(predicate) == nil
            else
        {
            let alert = NSAlert()
            alert.alertStyle = .CriticalAlertStyle
            alert.messageText = predicate.columnNameToMatch+" : "+predicate.stringToMatch+" has already been included"
            alert.runModal()
            return
        }
        self.arrayPredicates.append(predicate)
        self.arrayPredicates.sortInPlace () {$0 < $1}
    }
    
    func removeColumnAndSelectedParameter(arrayIdentifier: String)
    {
        let selectedRowInTable = self.tvPredicates.selectedRow
        guard selectedRowInTable >= 0
            else
        {
            return
        }
        switch arrayIdentifier
        {
        case "removePredicate":
            self.arrayPredicates.removeAtIndex(selectedRowInTable)
        default:
            break
        }
        self.updateTableViewSelectedColumnAndParameters()
    }
    
    func clearPredicates(arrayIdentifier: String)
    {
        switch arrayIdentifier
        {
        case "clearPredicates":
            self.arrayPredicates.removeAll()
        default:
            break
        }
        self.updateTableViewSelectedColumnAndParameters()
    }
    

}
