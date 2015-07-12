//
//  ViewController.swift
//  aecombiner
//
//  Created by David JM Lewis on 25/06/2015.
//  Copyright (c) 2015 djml.eu. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    

    // MARK: - class vars
    var arrayExtractedParameters = [[String]]()
    var arraySelectedColumnAndParameters = [[String]]()
    

    // MARK: - class constants
    let kParametersArrayParametersIndex = 0
    let kParametersArrayParametersValueIndex = 1
    let kSelectedParametersArrayColumnIndex = 0
    let kSelectedParametersArrayParameterIndex = 1
    let kStringEmpty = "- Empty -"
    let kStringRecodedColumnNameSuffix = "_#_"
    
    
    // MARK: - @IBOutlet

    //@IBOutlet weak var tableViewCSVdata: NSTableView!
    @IBOutlet weak var tableViewHeaders: NSTableView!
    @IBOutlet weak var tableViewSelectedColumnAndParameters: NSTableView!
    @IBOutlet weak var tableViewExtractedParameters: NSTableView!
    @IBOutlet weak var textFieldColumnRecodedName: NSTextField!
    
    
    // MARK: - @IBAction
    @IBAction func showDataWindow(sender: AnyObject) {
        guard let doc = NSDocumentController.sharedDocumentController().currentDocument else
        {
            print("No document showDataWindow")
            return
        }
        (doc as! Document).makeAndShowCSVdataWindow()
        (doc as! Document).showWindows()
    }

    @IBAction func extractParameters(sender: AnyObject) {
        //called from Process menu
        self.extractParametersIntoSetFromColumn()
    }
    
    @IBAction func addSelectedParameter(sender: AnyObject) {
        self.addColumnAndSelectedParameter()
    }

    @IBAction func recodeParametersAndAddNewColumn(sender: AnyObject) {
        self.doTheRecodeParametersAndAddNewColumn()
    }
    
    
    // MARK: - Document
    
    func documentMakeDirty()
    {
        guard let doc = NSDocumentController.sharedDocumentController().currentDocument else
        {
            print("No document documentMakeDirty")
            return
        }
        (doc as! Document).updateChangeCount(.ChangeDone)
    }
    
    
    // MARK: - overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.representedObject = CSVdata()

    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
            //self.columnsClearAndRebuild()
            //self.tableViewCSVdata.reloadData()
            self.tableViewHeaders.reloadData()
            
            
        }
    }

    

    // MARK: - TableView overrides

    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        guard let ident = control.identifier else {
            return true
        }
        switch ident
        {
        case "parametersValueCellTextField":
            guard control.tag < self.arrayExtractedParameters.count,
            let str = fieldEditor.string else
            {
                break
            }
            self.arrayExtractedParameters[control.tag][1] = str
        default:
            break
        }
        return true
    }
    
    override func controlTextDidEndEditing(obj: NSNotification) {
       // print(obj, appendNewline: true)
    }

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard let tvidentifier = tableView.identifier else
        {
            return 0
        }
        switch tvidentifier
        {
        case "tableViewCSVdata":
            return (self.representedObject as! CSVdata).csvData.count
        case "tableViewHeaders":
            return (self.representedObject as! CSVdata).headers.count
        case "tableViewExtractedParameters":
            return self.arrayExtractedParameters.count
        case "tableViewSelectedColumnAndParameters":
            return self.arraySelectedColumnAndParameters.count
            
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
            case "tableViewCSVdata":
                cellView = tableView.makeViewWithIdentifier("csvCell", owner: self) as! NSTableCellView
                // Set the stringValue of the cell's text field to the nameArray value at row
                let colIndex = tableView.columnWithIdentifier((tableColumn?.identifier)!)
                cellView.textField!.stringValue = (self.representedObject as! CSVdata).csvData[row][colIndex]
            case "tableViewHeaders":
                cellView = tableView.makeViewWithIdentifier("headersCell", owner: self) as! NSTableCellView
                cellView.textField!.stringValue = (self.representedObject as! CSVdata).headers[row]
            case "tableViewExtractedParameters":
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
    
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        let tableView = notification.object as! NSTableView
        switch tableView.identifier!
        {
        case "tableViewHeaders":
            self.resetExtractedParameters()
            self.extractParametersIntoSetFromColumn()
            
        default:
            break;
        }
        
    }
    
    
    // MARK: - Column parameters
    func resetExtractedParameters()
    {
        self.arrayExtractedParameters = [[String]]()
        self.tableViewExtractedParameters.reloadData()
        self.textFieldColumnRecodedName.stringValue = ""
    }
    
    func selectedColumnAndSelectedParameter() -> (column:String, parameter:String)?
    {
        let columnIndex = self.tableViewHeaders.selectedRow
        let parameterRow = self.tableViewExtractedParameters.selectedRow
        guard
                columnIndex >= 0 &&
                columnIndex < (self.representedObject as! CSVdata).headers.count &&
                parameterRow >= 0 &&
                parameterRow < (self.representedObject as! CSVdata).csvData[columnIndex].count
        else
        {
            print("out of range in selectedColumnAndSelectedParameter")
            return nil
        }
        let colS = (self.representedObject as! CSVdata).headers[columnIndex]
        let paramS = self.arrayExtractedParameters[parameterRow][kParametersArrayParametersIndex]
        return (colS,paramS)
    }
    
    func addColumnAndSelectedParameter()
    {
        guard let tuple = self.selectedColumnAndSelectedParameter()
        else
        {
            return
        }
        self.arraySelectedColumnAndParameters.append([tuple.column,tuple.parameter])
        self.tableViewSelectedColumnAndParameters.reloadData()
    }
    
    func selectedColumnForExtractedParametersTableView() -> Int?
    {
        let columnIndex = self.tableViewHeaders.selectedRow
        guard columnIndex >= 0 && columnIndex < (self.representedObject as! CSVdata).headers.count
            else
        {
            print("out of range in selectedColumnForExtractedParametersTableView")
            return nil
        }
        return columnIndex
    }
    
    func requestedColumnIndexIsOK(columnIndex:Int) -> Bool
    {
        return columnIndex >= 0 && columnIndex < (self.representedObject as! CSVdata).headers.count
    }
    
    func stringForRecodedColumn(columnIndex:Int) -> String
    {
        guard self.requestedColumnIndexIsOK(columnIndex) else
        {
            print("columnIndex out of range in stringForRecodedColumn")
            return kStringRecodedColumnNameSuffix
        }
        return (self.representedObject as! CSVdata).headers[columnIndex]+kStringRecodedColumnNameSuffix
    }
    
    func extractParametersIntoSetFromColumn()
    {
        //called from Process menu
        guard let columnIndex = self.selectedColumnForExtractedParametersTableView() else
        {
            print("columnIndex out of range in extractParametersIntoSetFromColumn")
            return
        }
        var set = Set<String>()
        self.textFieldColumnRecodedName.stringValue = self.stringForRecodedColumn(columnIndex)
        
        for parameter in (self.representedObject as! CSVdata).csvData
        {
            // parameter is a [string] array of row columns
            set.insert(parameter[columnIndex])
        }
        if set.count > 0
        {
            var subArray = Array(set)
            // replace blanks with string
            for var c=0;c < subArray.count; ++c
            {
                if subArray[c].isEmpty
                {
                    subArray[c] = kStringEmpty
                }
            }
            //clear the parameters array
            self.arrayExtractedParameters = [[String]]()
            for var row = 0; row<subArray.count; ++row
            {
                self.arrayExtractedParameters.append([subArray[row],""])
            }
        }
        self.tableViewExtractedParameters.reloadData()
        
    }
    
    func doTheRecodeParametersAndAddNewColumn()
    {
        guard let columnIndex = self.selectedColumnForExtractedParametersTableView() where self.arrayExtractedParameters.count > 0
            else
        {
            print("out of range in doTheRecodeParametersAndAddNewColumn")
            return
        }
        
        
        //give a name if none
        if self.textFieldColumnRecodedName.stringValue.isEmpty
        {
            self.textFieldColumnRecodedName.stringValue = self.stringForRecodedColumn(columnIndex)
        }
        
        //make a temporary dictionary
        var paramsDict = [String : String]()
        for paramNameAndValueArray in self.arrayExtractedParameters
        {
            paramsDict[paramNameAndValueArray[0]] = paramNameAndValueArray[1]
        }
        
        // must add the column to Array BEFORE adding column to table
        for var r = 0; r<(self.representedObject as! CSVdata).csvData.count; r++
        {
            var rowArray = (self.representedObject as! CSVdata).csvData[r]
            //ADD CORRECT PARAMETER AFTER LOOKUP
            let valueToRecode = rowArray[columnIndex]
            let recodedValue = (paramsDict[valueToRecode] ?? "")
            rowArray.append(recodedValue)
            (self.representedObject as! CSVdata).csvData[r] = rowArray
        }
        //add name to headers array
        (self.representedObject as! CSVdata).headers.append(self.textFieldColumnRecodedName.stringValue)
        //Safe to add column to table now
        let colName = self.textFieldColumnRecodedName.stringValue
        NSNotificationCenter.defaultCenter().postNotificationName("addColumnWithIdentifier", object: colName)

        //reload etc
        self.tableViewHeaders.reloadData()
        self.resetExtractedParameters()
        
        self.documentMakeDirty()
        
    }

}

