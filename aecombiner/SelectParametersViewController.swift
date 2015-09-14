//
//  SelectParametersViewController.swift
//  aecombiner
//
//  Created by David JM Lewis on 17/07/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa




class SelectParametersViewController: RecodeColumnViewController {
    
    
    // MARK: - class vars
    var arrayANDpredicates = DataMatrix()
    var arrayORpredicates = DataMatrix()
    var arrayCol1Params = DataMatrix()
    var arrayCol2Params = DataMatrix()
    
    
    
    // MARK: - @IBOutlet
    
    @IBOutlet weak var tabv1Col2Col: NSTabView!
    
    @IBOutlet weak var tv2colHeaders1: NSTableView!
    @IBOutlet weak var tv2colHeaders2: NSTableView!
    @IBOutlet weak var tv2colParameters2: NSTableView!
    @IBOutlet weak var tv2colParameters1: NSTableView!
    @IBOutlet weak var tvHeadersForChart: NSTableView!
    @IBOutlet weak var tvANDparameters: NSTableView!
    @IBOutlet weak var tvORparameters: NSTableView!
    
    @IBOutlet weak var buttonRemoveORParameter: NSButton!
    @IBOutlet weak var buttonRemoveANDParameter: NSButton!
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
        self.clearANDorORarray(sender.identifier!)
    }
    
    
    @IBAction func extractRowsBasedOnPredicatesIntoNewFile(sender: NSButton) {
        guard let cdvc = self.associatedCSVdataViewController else {return}
        
        cdvc.extractRowsBasedOnPredicatesIntoNewFile(ANDpredicates: self.arrayANDpredicates, ORpredicates: self.arrayORpredicates)
    }
    
    @IBAction func extractRowsBasedOnPredicatesIntoModelForChart(sender: NSButton) {
        guard let cdvc = self.associatedCSVdataViewController else {return}
        
        self.extractedDataMatrixForChart = cdvc.extractedDataMatrixForChartWithPredicates(ANDpredicates: self.arrayANDpredicates, ORpredicates: self.arrayORpredicates)
        
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
    
    override func sortParametersOrValuesInTableViewColumn(tableView tableView: NSTableView, tableColumn: NSTableColumn)
    {
        guard let tvidentifier = tableView.identifier else {return}
        switch tvidentifier
        {
        case "tvSelectedHeaders":
            break
        case "tvSelectedExtractedParameters":
            super.sortParametersOrValuesInTableViewColumn(tableView: tableView, tableColumn: tableColumn)
        case "tvANDparameters":
            break
        case "tvORparameters":
            break
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
        case "tvSelectedExtractedParameters":
            return self.arrayExtractedParameters.count
        case "tv2colParameters1":
            return self.arrayCol1Params.count
        case "tv2colParameters2":
            return self.arrayCol2Params.count
        case "tvANDparameters":
            return self.arrayANDpredicates.count
        case "tvORparameters":
            return self.arrayORpredicates.count
            
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
        case "tvSelectedExtractedParameters":
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
            
        case "tvANDparameters", "tvORparameters":
            let col_parameter = tvidentifier == "tvANDparameters" ? self.arrayANDpredicates[row] : self.arrayORpredicates[row]
            let columnNumber = Int(col_parameter[kSelectedParametersArrayColumnIndex])
            
            switch tableColumn!.identifier
            {
            case "column":
                cellView = tableView.makeViewWithIdentifier("selectedParameterCellC", owner: self) as! NSTableCellView
                cellView.textField!.stringValue = self.headerStringForColumnIndex(columnNumber)
            case "parameter":
                cellView = tableView.makeViewWithIdentifier("selectedParameterCellP", owner: self) as! NSTableCellView
                cellView.textField!.stringValue = col_parameter[kSelectedParametersArrayParameterIndex]
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

        case "tvANDparameters":
            self.buttonRemoveANDParameter.enabled = tableView.selectedRow != -1
        case "tvORparameters":
            self.buttonRemoveORParameter.enabled = tableView.selectedRow != -1
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
        switch arrayIdentifier
        {
        case "removeANDarray", "clearANDarray", "addANDarray","addANDarrayCol1","addANDarrayCol2":
            self.tvANDparameters.reloadData()
            self.buttonRemoveANDParameter.enabled = false
        case "removeORarray", "clearORarray", "addORarray","addORarrayCol1","addORarrayCol2":
            self.tvORparameters.reloadData()
            self.buttonRemoveORParameter.enabled = false
        default:
            break
        }

    }
    
    func addColumnAndSelectedParameter(arrayIdentifier: String)
    {
        guard let csvdo = self.associatedCSVdataViewController else {return}
        let columnIndex: Int
        let parameterRows: NSIndexSet

        switch arrayIdentifier
        {
        case "addANDarray","addORarray":
            columnIndex = self.tvHeaders.selectedRow
            parameterRows = self.tvExtractedParameters.selectedRowIndexes
        case "addANDarrayCol1","addORarrayCol1":
            columnIndex = self.tv2colHeaders1.selectedRow
            parameterRows = self.tv2colParameters1.selectedRowIndexes
        case "addANDarrayCol2","addORarrayCol2":
            columnIndex = self.tv2colHeaders2.selectedRow
            parameterRows = self.tv2colParameters2.selectedRowIndexes
        default:
            columnIndex = -1
            parameterRows = NSIndexSet()
        }

        
        guard
            columnIndex >= 0 &&
            columnIndex < csvdo.numberOfColumnsInData() &&
            parameterRows.count > 0
            else {return}
        
        for parameterIndex in parameterRows
        {
            if parameterIndex >= 0 && parameterIndex < self.arrayExtractedParameters.count
            {
                switch arrayIdentifier
                {
                case "addANDarray", "addANDarrayCol1", "addANDarrayCol2":
                    self.arrayANDpredicates.append([String(columnIndex),self.arrayExtractedParameters[parameterIndex][kParametersArrayParametersIndex]])
                case "addORarray","addORarrayCol1", "addORarrayCol2":
                    self.arrayORpredicates.append([String(columnIndex),self.arrayExtractedParameters[parameterIndex][kParametersArrayParametersIndex]])
                default:
                    break
                }
            }
        }

        self.updateTableViewSelectedColumnAndParameters(arrayIdentifier)
    }
    
    func removeColumnAndSelectedParameter(arrayIdentifier: String)
    {
        let selectedRowInTable = arrayIdentifier == "removeANDarray" ? self.tvANDparameters.selectedRow : self.tvORparameters.selectedRow
        guard selectedRowInTable >= 0
            else
        {
            return
        }
        switch arrayIdentifier
        {
        case "removeANDarray":
            self.arrayANDpredicates.removeAtIndex(selectedRowInTable)
        case "removeORarray":
            self.arrayORpredicates.removeAtIndex(selectedRowInTable)
        default:
            break
        }
        self.updateTableViewSelectedColumnAndParameters(arrayIdentifier)
    }
    
    func clearANDorORarray(arrayIdentifier: String)
    {
        switch arrayIdentifier
        {
        case "clearANDarray":
            self.arrayANDpredicates.removeAll()
        case "clearORarray":
            self.arrayORpredicates.removeAll()
        default:
            break
        }
        self.updateTableViewSelectedColumnAndParameters(arrayIdentifier)
    }
    

}
