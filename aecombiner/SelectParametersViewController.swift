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
    
    
    
    // MARK: - class constants
    
    
    // MARK: - @IBOutlet
    
    //@IBOutlet weak var tableViewCSVdata: NSTableView!
    @IBOutlet weak var tableViewANDparameters: NSTableView!
    @IBOutlet weak var buttonRemoveANDParameter: NSButton!
    @IBOutlet weak var tableViewORparameters: NSTableView!
    @IBOutlet weak var buttonRemoveORParameter: NSButton!
    
    @IBOutlet weak var buttonChartExtractedRows: NSButton!
    @IBOutlet weak var tableViewHeadersForChart: NSTableView!

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
        guard let cdvc = self.associatedCSVdataViewController() else {return}
        
        cdvc.extractRowsBasedOnPredicatesIntoNewFile(ANDpredicates: self.arrayANDpredicates, ORpredicates: self.arrayORpredicates)
    }
    
    @IBAction func extractRowsBasedOnPredicatesIntoModelForChart(sender: NSButton) {
        guard let cdvc = self.associatedCSVdataViewController() else {return}
        
        self.extractedDataMatrixForChart = cdvc.extractedDataMatrixForChartWithPredicates(ANDpredicates: self.arrayANDpredicates, ORpredicates: self.arrayORpredicates)
        
        self.buttonChartExtractedRows.enabled = self.extractedDataMatrixForChart.count>0
        self.chartExtractedRows(sender)
    }
    
    // MARK: - ChartViewControllerDelegate
    
    override func extractRowsIntoNewCSVdocumentWithIndexesFromChartDataSet(indexes: NSMutableIndexSet, nameOfDataSet: String) {
        guard let csvdatavc = self.associatedCSVdataViewController() else {return}
        // we use self.extractedDataMatrixForChart
        let extractedDataMatrix = CSVdata.extractTheseRowsFromDataMatrixAsDataMatrix(rows: indexes, datamatrix: self.extractedDataMatrixForChart)
        csvdatavc.createNewDocumentFromExtractedRows(cvsData: extractedDataMatrix, headers: nil, name: nameOfDataSet)
    }

    func chartExtractedRows(sender: NSButton) {
        guard
            let chartviewC = self.chartViewController,
            let columnIndex = self.selectedColumnFromHeadersTableView(self.tableViewHeadersForChart)
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
        self.tableViewHeaders?.reloadData()
        self.tableViewExtractedParameters?.reloadData()
        self.tableViewHeadersForChart?.reloadData()
    }
    
    override func sortParametersOrValuesInTableViewColumn(tableView tableView: NSTableView, tableColumn: NSTableColumn)
    {
        guard let tvidentifier = tableView.identifier else {return}
        switch tvidentifier
        {
        case "tableViewSelectedHeaders":
            break
        case "tableViewSelectedExtractedParameters":
            super.sortParametersOrValuesInTableViewColumn(tableView: tableView, tableColumn: tableColumn)
        case "tableViewANDparameters":
            break
        case "tableViewORparameters":
            break
        default:
            break
        }
    
    }

    
    // MARK: - TableView overrides
    
    
    override func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard let tvidentifier = tableView.identifier,let csvdo = self.associatedCSVdataViewController()  else {return 0}
        switch tvidentifier
        {
        case "tableViewSelectedHeaders":
            return csvdo.numberOfColumnsInData()
        case "tableViewHeadersForChart":
            return csvdo.numberOfColumnsInData()
        case "tableViewSelectedExtractedParameters":
            return self.arrayExtractedParameters.count
        case "tableViewANDparameters":
            return self.arrayANDpredicates.count
        case "tableViewORparameters":
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
        case "tableViewHeadersForChart":
            cellView = self.cellForHeadersTable(tableView: tableView, row: row)
        case "tableViewSelectedHeaders":
            cellView = self.cellForHeadersTable(tableView: tableView, row: row)
        case "tableViewSelectedExtractedParameters":
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
        case "tableViewANDparameters", "tableViewORparameters":
            let col_parameter = tvidentifier == "tableViewANDparameters" ? self.arrayANDpredicates[row] : self.arrayORpredicates[row]
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
        case "tableViewSelectedHeaders":
            self.resetExtractedParameters()
            self.extractParametersIntoSetFromColumn()
        case "tableViewANDparameters":
            self.buttonRemoveANDParameter.enabled = tableView.selectedRow != -1
        case "tableViewORparameters":
            self.buttonRemoveORParameter.enabled = tableView.selectedRow != -1
        case "tableViewHeadersForChart":
            break
        default:
            break;
        }
        
    }
    
    
    // MARK: - Column parameters    
    
    func updateTableViewSelectedColumnAndParameters(arrayIdentifier: String)
    {
        switch arrayIdentifier
        {
        case "removeANDarray", "addANDarray", "clearANDarray":
            self.tableViewANDparameters.reloadData()
            self.buttonRemoveANDParameter.enabled = false
        case "removeORarray", "addORarray", "clearORarray":
            self.tableViewORparameters.reloadData()
            self.buttonRemoveORParameter.enabled = false
        default:
            break
        }

    }
    
    func addColumnAndSelectedParameter(arrayIdentifier: String)
    {
        guard let csvdo = self.associatedCSVdataViewController() else {return}
        let columnIndex = self.tableViewHeaders.selectedRow
        let parameterRows = self.tableViewExtractedParameters.selectedRowIndexes

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
                case "addANDarray":
                    self.arrayANDpredicates.append([String(columnIndex),self.arrayExtractedParameters[parameterIndex][kParametersArrayParametersIndex]])
                case "addORarray":
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
        let selectedRowInTable = arrayIdentifier == "removeANDarray" ? self.tableViewANDparameters.selectedRow : self.tableViewORparameters.selectedRow
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
