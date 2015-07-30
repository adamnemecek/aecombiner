//
//  ViewController.swift
//  aecombiner
//
//  Created by David JM Lewis on 25/06/2015.
//  Copyright (c) 2015 djml.eu. All rights reserved.
//

import Cocoa

class RecodeColumnViewController: HeadingsViewController {
    

    // MARK: - class vars
    var arrayExtractedParameters = [[String]]()
    

    // MARK: - class constants
    let kParametersArrayParametersIndex = 0
    let kParametersArrayParametersValueIndex = 1
    let kSelectedParametersArrayColumnIndex = 0
    let kSelectedParametersArrayParameterIndex = 1
    let kStringEmpty = "- Empty -"
    let kStringRecodedColumnNameSuffix = "_#_"
    
    
    // MARK: - @IBOutlet

    @IBOutlet weak var tableViewExtractedParameters: NSTableView!
    
    @IBOutlet weak var segmentedTextNumbers: NSSegmentedControl!
    @IBOutlet weak var segmentedParameterValue: NSSegmentedControl!
    
    
    
    // MARK: - @IBAction


    @IBAction func recodeParametersAndAddNewColumn(sender: AnyObject) {
        self.doTheRecodeParametersAndAddNewColumn()
    }
    
    @IBAction func sortExtractedParameters(sender: NSButton) {
        self.sortParameters(sender.tag)
        sender.tag = sender.tag == 0 ? 1 : 0
    }
    
    
    
    // MARK: - overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableViewExtractedParameters?.reloadData()


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

    override func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard let tvidentifier = tableView.identifier else
        {
            return 0
        }
        switch tvidentifier
        {
        case "tableViewRecodeHeaders":
            return self.myCSVdataObject().headers.count
        case "tableViewExtractedParameters":
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
            case "tableViewRecodeHeaders":
                cellView = self.cellForHeadersTable(tableView: tableView, row: row)
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
        case "tableViewRecodeHeaders":
            self.resetExtractedParameters()
            self.extractParametersIntoSetFromColumn()
        default:
            break;
        }
        
    }
    
    
    // MARK: - Column parameters
    func stringForRecodedColumn(columnIndex:Int) -> String
    {
        return self.stringForColumnName(columnIndex)+kStringRecodedColumnNameSuffix
    }
    

    func sortParameters(direction:Int)
    {
        //let wayToSort = (direction, textOrNum:self.segmentedTextNumbers.selectedSegment)
        let indexToSort = self.segmentedParameterValue.selectedSegment
        
        switch (direction, self.segmentedTextNumbers.selectedSegment)
        {
        case (0,1):
            self.arrayExtractedParameters.sortInPlace({ (leftTuple, rightTuple) -> Bool in
                return Double(leftTuple[indexToSort])>Double(rightTuple[indexToSort])
            })
        case (1,1):
            self.arrayExtractedParameters.sortInPlace({ (leftTuple, rightTuple) -> Bool in
                return Double(leftTuple[indexToSort])<Double(rightTuple[indexToSort])
            })
        case (0,0):
            self.arrayExtractedParameters.sortInPlace({ (leftTuple, rightTuple) -> Bool in
                return leftTuple[indexToSort]>rightTuple[indexToSort]
            })
        case (1,0):
            self.arrayExtractedParameters.sortInPlace({ (leftTuple, rightTuple) -> Bool in
                return leftTuple[indexToSort]<rightTuple[indexToSort]
            })
        default:
            return
        }
        
        self.tableViewExtractedParameters.reloadData()
    }
    
    func resetExtractedParameters()
    {
        self.arrayExtractedParameters = [[String]]()
        self.tableViewExtractedParameters?.reloadData()
        self.textFieldColumnRecodedName?.stringValue = ""
    }
    
    
    func extractParametersIntoSetFromColumn()
    {
        //called from Process menu
        guard let columnIndex = self.selectedColumnFromHeadersTableView() else
        {
            print("columnIndex out of range in extractParametersIntoSetFromColumn")
            return
        }
        var set = Set<String>()
        self.textFieldColumnRecodedName?.stringValue = self.stringForRecodedColumn(columnIndex)
        
        for parameter in self.myCSVdataObject().csvData
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
        guard let columnIndex = self.selectedColumnFromHeadersTableView() where self.arrayExtractedParameters.count > 0
            else
        {
            print("out of range in doTheRecodeParametersAndAddNewColumn")
            return
        }
        
        
        //give a name if none
        if (self.textFieldColumnRecodedName?.stringValue.isEmpty != nil)
        {
            self.textFieldColumnRecodedName?.stringValue = self.stringForRecodedColumn(columnIndex)
        }
        
        //make a temporary dictionary
        var paramsDict = [String : String]()
        for paramNameAndValueArray in self.arrayExtractedParameters
        {
            paramsDict[paramNameAndValueArray[0]] = paramNameAndValueArray[1]
        }
        
        // must add the column to Array BEFORE adding column to table
        for var r = 0; r<self.myCSVdataObject().csvData.count; r++
        {
            var rowArray = self.myCSVdataObject().csvData[r]
            //ADD CORRECT PARAMETER AFTER LOOKUP
            let valueToRecode = rowArray[columnIndex]
            let recodedValue = (paramsDict[valueToRecode] ?? "")
            rowArray.append(recodedValue)
            self.myCSVdataObject().csvData[r] = rowArray
        }
        //add name to headers array
        self.myCSVdataObject().headers.append((self.textFieldColumnRecodedName?.stringValue)!)
        //Safe to add column to table now
        let colName = self.textFieldColumnRecodedName?.stringValue
        NSNotificationCenter.defaultCenter().postNotificationName("addColumnWithIdentifier", object: colName)

        //reload etc
        self.tableViewHeaders.reloadData()
        self.resetExtractedParameters()
        
        self.documentMakeDirty()
        
    }

}

