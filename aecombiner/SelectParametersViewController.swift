//
//  SelectParametersViewController.swift
//  aecombiner
//
//  Created by David JM Lewis on 17/07/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa

class GroupingPredicateTableCellView: NSTableCellView {
    @IBOutlet weak var textFieldLower: NSTextField!

}


struct GroupingPredicate: Comparable
{
    var columnNameToMatch:String
    var stringToMatch:String
    var booleanOperator:String
    init (columnName:String,string:String,boolean:String)
    {
        booleanOperator = boolean
        stringToMatch = string
        columnNameToMatch = columnName
    }
}
//you implement == type at GLOBAL level not within the body of the struct!!!
func ==(lhs: GroupingPredicate, rhs: GroupingPredicate) -> Bool {
    return  //(lhs.booleanOperator == rhs.booleanOperator)  && we ignore bool as u cant use the same search term in more than one bool type
            (lhs.columnNameToMatch == rhs.columnNameToMatch) &&
            (lhs.stringToMatch == rhs.stringToMatch)
}
func < (lhs: GroupingPredicate, rhs: GroupingPredicate) -> Bool {
    //phased approach. We test in precedence and ignore any unequalness below if the upper level is discordant
    // so it may be > at a lower level 
    // we do this to ensure the ANDs cluster apart from ORs, COLUMNs from each other and so on
    if lhs.booleanOperator != rhs.booleanOperator
    {return lhs.booleanOperator < rhs.booleanOperator}
    if lhs.columnNameToMatch != rhs.columnNameToMatch
    {return lhs.columnNameToMatch < rhs.columnNameToMatch}
    return lhs.stringToMatch < rhs.stringToMatch
}

typealias GroupingPredicatesArray = [GroupingPredicate]

struct PredicatesByBoolean {
    var ANDpredicates = GroupingPredicatesArray()
    var ORpredicates = GroupingPredicatesArray()
    var NOTpredicates = GroupingPredicatesArray()
    
}

class SelectParametersViewController: RecodeColumnViewController {
    
    
    // MARK: - class vars
    var arrayCol1Params = DataMatrix()
    var arrayCol2Params = DataMatrix()
    var arrayPredicates = GroupingPredicatesArray()
    
    
    // MARK: - @IBOutlet
    
    @IBOutlet weak var tabv1Col2Col: NSTabView!
    
    @IBOutlet weak var tv2colHeaders1: NSTableView!
    @IBOutlet weak var tv2colHeaders2: NSTableView!
    @IBOutlet weak var tv2colParameters2: NSTableView!
    @IBOutlet weak var tv2colParameters1: NSTableView!
    @IBOutlet weak var tvHeadersForChart: NSTableView!
    @IBOutlet weak var tvPredicates: NSTableView!
    
    @IBOutlet weak var buttonRemovePredicate: NSButton!
    @IBOutlet weak var buttonChartExtractedRows: NSButton!

    
    
    /* MARK: - Represented Object
    override func updateRepresentedObjectToCSVData(csvdata:CSVdata)
    {
        self.representedObject = csvdata
    }
*/
    // MARK: - @IBAction
    
    
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
        guard let cdvc = self.associatedCSVdataViewController else {return}
        
        self.extractedDataMatrixForChart = cdvc.extractedDataMatrixForChartWithPredicates(predicates: self.arrayPredicates)
        
        self.buttonChartExtractedRows.enabled = self.extractedDataMatrixForChart.count>0
        self.chartExtractedRows(sender)
    }
    
    // MARK: - ChartViewControllerDelegate
    
    override func extractRowsIntoNewCSVdocumentWithIndexesFromChartDataSet(indexes: NSMutableIndexSet, nameOfDataSet: String) {
        guard let csvdatavc = self.associatedCSVdataViewController else {return}
        // we use self.extractedDataMatrixForChart
        let extractedDataMatrix = CSVdata.extractTheseRowsFromDataMatrixAsDataMatrix(rows: indexes, datamatrix: self.extractedDataMatrixForChart)
        csvdatavc.createNewDocumentFromExtractedRows(cvsData: extractedDataMatrix, headers: nil, name: nameOfDataSet)
    }

    func chartExtractedRows(sender: NSButton) {
        guard
            let chartviewC = self.chartViewController,
            let columnIndex = self.selectedColumnFromHeadersTableView(self.tvHeadersForChart)
            else {return}
        let dataset = ChartDataSet(data: self.extractedDataMatrixForChart, forColumnIndex: columnIndex)
        chartviewC.plotNewChartDataSet(dataSet: dataset, nameOfChartDataSet: self.headerStringForColumnIndex(columnIndex))

    }
    
    // MARK: - overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //self.representedObject = CSVdata()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.tvHeaders?.reloadData()
        self.tv2colHeaders1?.reloadData()
        self.tv2colHeaders2?.reloadData()
        self.tvHeadersForChart?.reloadData()
        
        self.tvExtractedParameters?.reloadData()

    }
    // MARK: - Sorting Tables on header click
    override func tableView(tableView: NSTableView, mouseDownInHeaderOfTableColumn tableColumn: NSTableColumn) {
        // inheriteds override
        guard let tvidentifier = tableView.identifier else {return}
        switch tvidentifier
        {
        case "tvSelectedHeaders":
            break
        case "tv1colParameters":
            self.sortParametersOrValuesInTableViewColumn(tableView: tableView, tableColumn: tableColumn, arrayToSort: &self.arrayExtractedParameters, textOrValue: self.segmentedSortAsTextOrNumbers.selectedSegment)
            tableView.reloadData()
        case "tv2colParameters1":
            self.sortParametersOrValuesInTableViewColumn(tableView: tableView, tableColumn: tableColumn, arrayToSort: &self.arrayCol1Params, textOrValue: self.segmentedSortAsTextOrNumbers.selectedSegment)
            tableView.reloadData()
        case "tv2colParameters2":
            self.sortParametersOrValuesInTableViewColumn(tableView: tableView, tableColumn: tableColumn, arrayToSort: &self.arrayCol2Params, textOrValue: self.segmentedSortAsTextOrNumbers.selectedSegment)
            tableView.reloadData()
            
        default:
            break
        }

    }

    
    // MARK: - TableView overrides
    
    
    override func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard let tvidentifier = tableView.identifier,let csvdo = self.associatedCSVdataViewController  else {return 0}
        switch tvidentifier
        {
        case "tvSelectedHeaders", "tv2colHeaders1", "tv2colHeaders2",  "tvHeadersForChart":
            return csvdo.numberOfColumnsInData()
        case "tv1colParameters":
            return self.arrayExtractedParameters.count
        case "tv2colParameters1":
            return self.arrayCol1Params.count
        case "tv2colParameters2":
            return self.arrayCol2Params.count
        case "tvPredicates":
            return self.arrayPredicates.count
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
        case "tvSelectedHeaders", "tvHeadersForChart", "tv2colHeaders1", "tv2colHeaders2":
            cellView = self.cellForHeadersTable(tableView: tableView, row: row)
        case "tv1colParameters":
            switch tableColumn!.identifier
            {
            case "parameter":
                cellView = tableView.makeViewWithIdentifier("parametersCell", owner: self) as! NSTableCellView
                cellView.textField!.stringValue = self.arrayExtractedParameters[row][kParametersArrayParametersIndex]
            case "value"://parameters
                cellView = tableView.makeViewWithIdentifier("parametersValueCell", owner: self) as! NSTableCellView
                cellView.textField!.stringValue = self.arrayExtractedParameters[row][kParametersArrayParametersValueIndex]
                cellView.textField!.tag = row
            default:
                break
            }
            
        case "tv2colParameters1":
            cellView = tableView.makeViewWithIdentifier("parametersCell", owner: self) as! NSTableCellView
            cellView.textField!.stringValue = self.arrayCol1Params[row][kParametersArrayParametersIndex]
        case "tv2colParameters2":
            cellView = tableView.makeViewWithIdentifier("parametersCell", owner: self) as! NSTableCellView
            cellView.textField!.stringValue = self.arrayCol2Params[row][kParametersArrayParametersIndex]
            
        case "tvPredicates":
            let predcellView = tableView.makeViewWithIdentifier("parameterImageCell", owner: self) as! GroupingPredicateTableCellView
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
    
    
    override func tableViewSelectionDidChange(notification: NSNotification) {
        let tableView = notification.object as! NSTableView
        switch tableView.identifier!
        {
        case "tvSelectedHeaders":
            self.resetExtractedParameters()
            self.extractParametersIntoSetFromColumn()
            
            
        case "tv2colHeaders1":
            self.resetCol1ExtractedParameters()
            self.extractCol1ParametersIntoSetFromColumn()
        case "tv2colParameters1":
            self.tv2colHeaders2?.reloadData()
            self.resetCol2ExtractedParameters()
        case "tv2colHeaders2":
            self.resetCol2ExtractedParameters()
            self.extractCol2ParametersIntoSetFromHeaders2()

        case "tvPredicates":
            self.buttonRemovePredicate.enabled = tableView.selectedRow != -1
        case "tvHeadersForChart":
            break
        default:
            break;
        }
        
    }
    
    
    // MARK: - Column 1 2 parameters
    
    func resetCol1ExtractedParameters()
    {
        self.arrayCol1Params = DataMatrix()
        self.arrayCol2Params = DataMatrix()
        self.tv2colParameters1?.reloadData()
        self.tv2colParameters2?.reloadData()
        self.tv2colHeaders2?.reloadData()
    }
    
    func resetCol2ExtractedParameters()
    {
        self.arrayCol2Params = DataMatrix()
        self.tv2colParameters2?.reloadData()
    }
    
    func extractCol1ParametersIntoSetFromColumn()
    {
        guard let csvdo = self.associatedCSVdataViewController, let columnIndex = self.selectedColumnFromHeadersTableView(self.tv2colHeaders1), let set = csvdo.setOfParametersFromColumn(fromColumn: columnIndex) else { return }
        
        self.arrayCol1Params = dataMatrixWithNoBlanksFromSet(set: set)
        self.tv2colParameters1.reloadData()
        
    }

    func param1SelectedIndex()->Int?
    {
        let index = self.tv2colParameters1.selectedRow
        return  index >= 0 && index < self.arrayCol1Params.count ? index : nil
    }

    
    func extractCol2ParametersIntoSetFromHeaders2()
    {
        guard
            let csvdo = self.associatedCSVdataViewController,
            let columnToMatchIndex = self.selectedColumnFromHeadersTableView(self.tv2colHeaders1),
            let columnToExtractIndex = self.selectedColumnFromHeadersTableView(self.tv2colHeaders2),
            let safeParam1Index = self.param1SelectedIndex()
        else { return }

        let matchStr = self.arrayCol1Params[safeParam1Index][kParametersArrayParametersIndex]
        guard
            let set = csvdo.setOfParametersFromColumnIfStringMatchedInColumn(fromColumn:columnToExtractIndex, matchString:matchStr, matchColumn:columnToMatchIndex)
        else { return }
        self.arrayCol2Params = dataMatrixWithNoBlanksFromSet(set: set)
        self.tv2colParameters2.reloadData()

        
    }

    
    // MARK: - AND OR tables

    func updateTableViewSelectedColumnAndParameters(arrayIdentifier: String)
    {
        self.tvPredicates.reloadData()
        self.buttonRemovePredicate.enabled = false
    }
    
    func addColumnAndSelectedParameter(arrayIdentifier: String)
    {
        guard let csvdo = self.associatedCSVdataViewController else {return}
        let columnIndex: Int
        let parameterRows: NSIndexSet
        let arrayParamsToUse: DataMatrix
        
        switch arrayIdentifier
        {
        case "addANDarray","addORarray","addNOTarray":
            columnIndex = self.tvHeaders.selectedRow
            parameterRows = self.tvExtractedParameters.selectedRowIndexes
            arrayParamsToUse = self.arrayExtractedParameters
        case "addANDarrayCol1","addORarrayCol1","addNOTarrayCol1":
            columnIndex = self.tv2colHeaders1.selectedRow
            parameterRows = self.tv2colParameters1.selectedRowIndexes
            arrayParamsToUse = self.arrayCol1Params
        case "addANDarrayCol2","addORarrayCol2","addNOTarrayCol2":
            columnIndex = self.tv2colHeaders2.selectedRow
            parameterRows = self.tv2colParameters2.selectedRowIndexes
            arrayParamsToUse = self.arrayCol2Params
        default:
            columnIndex = -1
            parameterRows = NSIndexSet()
            arrayParamsToUse = DataMatrix()
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

        self.updateTableViewSelectedColumnAndParameters(arrayIdentifier)
    }
    
    
    func appendPredicateToArray(columnIndexToSearch columnName: String, matchString: String, booleanString: String)
    {
        let predicate = GroupingPredicate(columnName: columnName, string: matchString, boolean: booleanString)
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
        self.updateTableViewSelectedColumnAndParameters(arrayIdentifier)
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
        self.updateTableViewSelectedColumnAndParameters(arrayIdentifier)
    }
    

}
