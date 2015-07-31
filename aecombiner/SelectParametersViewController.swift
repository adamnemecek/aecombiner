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
    var arraySelectedColumnAndParameters = [[String]]()
    
    
    // MARK: - class constants
    
    
    // MARK: - @IBOutlet
    
    //@IBOutlet weak var tableViewCSVdata: NSTableView!
    @IBOutlet weak var tableViewSelectedColumnAndParameters: NSTableView!
    
    @IBOutlet weak var buttonRemoveSelectedParameter: NSButton!
    
    /* MARK: - Represented Object
    override func updateRepresentedObjectToCSVData(csvdata:CSVdata)
    {
        self.representedObject = csvdata
    }
*/
    // MARK: - @IBAction
    
    
    @IBAction func extractParameters(sender: AnyObject) {
        //called from Process menu
        self.extractParametersIntoSetFromColumn()
    }
    
    @IBAction func addSelectedParameter(sender: AnyObject) {
        self.addColumnAndSelectedParameter()
    }
    
    @IBAction func removeSelectedParameter(sender: NSButton) {
        self.removeColumnAndSelectedParameter()
    }
    
    
    // MARK: - CSVdataDocument
    
    
    
    // MARK: - overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //self.representedObject = CSVdata()
        self.tableViewHeaders?.reloadData()
        self.tableViewExtractedParameters?.reloadData()
    }
    
    /* override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
            self.tableViewHeaders?.reloadData()
            self.tableViewExtractedParameters?.reloadData()
            
        }
    }*/
    
    
    
    // MARK: - TableView overrides
    
    
    override func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard let tvidentifier = tableView.identifier,let csvdo = self.myCSVdataObject()  else
        {
            return 0
        }
        switch tvidentifier
        {
        case "tableViewSelectedHeaders":
            return csvdo.headers.count
        case "tableViewSelectedExtractedParameters":
            return self.arrayExtractedParameters.count
        case "tableViewSelectedColumnAndParameters":
            return self.arraySelectedColumnAndParameters.count
            
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
        case "tableViewSelectedColumnAndParameters":
            let col_parameter = self.arraySelectedColumnAndParameters[row]
            switch tableColumn!.identifier
            {
            case "column":
                cellView = tableView.makeViewWithIdentifier("selectedParameterCellC", owner: self) as! NSTableCellView
                cellView.textField!.stringValue = col_parameter[kSelectedParametersArrayColumnIndex]
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
        case "tableViewSelectedColumnAndParameters":
            self.buttonRemoveSelectedParameter.enabled = tableView.selectedRow != -1
        default:
            break;
        }
        
    }
    
    
    // MARK: - Column parameters    
    func selectedColumnAndSelectedParameter() -> (column:String, parameter:String)?
    {
        let columnIndex = self.tableViewHeaders.selectedRow
        let parameterRow = self.tableViewExtractedParameters.selectedRow
        guard let csvdo = self.myCSVdataObject() else {return nil}
        guard
            columnIndex >= 0 &&
            columnIndex < csvdo.headers.count &&
            parameterRow >= 0 &&
            parameterRow < csvdo.csvData[columnIndex].count
        else {return nil}
        let colS = csvdo.headers[columnIndex]
        let paramS = self.arrayExtractedParameters[parameterRow][kParametersArrayParametersIndex]
        return (colS,paramS)
    }
    
    func updateTableViewSelectedColumnAndParameters()
    {
        self.tableViewSelectedColumnAndParameters.reloadData()
        self.buttonRemoveSelectedParameter.enabled = false
    }
    
    func addColumnAndSelectedParameter()
    {
        guard let tuple = self.selectedColumnAndSelectedParameter()
            else
        {
            return
        }
        self.arraySelectedColumnAndParameters.append([tuple.column,tuple.parameter])
        self.updateTableViewSelectedColumnAndParameters()
    }
    
    func removeColumnAndSelectedParameter()
    {
        let selectedRowInTable = self.tableViewSelectedColumnAndParameters.selectedRow
        guard selectedRowInTable >= 0
            else
        {
            return
        }
        self.arraySelectedColumnAndParameters.removeAtIndex(selectedRowInTable)
        self.updateTableViewSelectedColumnAndParameters()
        
    }
    
    
}
