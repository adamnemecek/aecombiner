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

    var parametersArray = [[String]]()

    // MARK: - class constants
    let kParametersTableParametersColumnIndex = 0
    let kParametersTableParametersValuesColumnIndex = 1
    let kParametersArrayParametersIndex = 0
    let kParametersArrayParametersValueIndex = 1
    let kStringEmpty = "- Empty -"
    let kStringRecodedColumnNameSuffix = "_#_"
    
    
    // MARK: - @IBOutlet

    @IBOutlet weak var tableViewCSVdata: NSTableView!
    @IBOutlet weak var tableViewHeaders: NSTableView!
    @IBOutlet weak var tableViewSetOfParameters: NSTableView!
    @IBOutlet weak var textFieldColumnRecodedName: NSTextField!
    
    
    // MARK: - @IBAction
    @IBAction func extractParameters(sender: AnyObject) {
        //called from Process menu
        self.extractParametersIntoSetFromColumn()
    }
    

    @IBAction func recodeParametersAndAddNewColumn(sender: AnyObject) {
        self.doTheRecodeParametersAndAddNewColumn()
    }
    
    
    // MARK: - Document
    func documentMakeDirty()
    {
        guard let doc = NSDocumentController.sharedDocumentController().currentDocument else
        {
            return
        }
        (doc as! Document).updateChangeCount(.ChangeDone)
    }
    
    
    // MARK: - overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.representedObject = CSVdata()
        //let nc = NSNotificationCenter.defaultCenter()
        //nc.addObserver(self, selector: Selector("editingDidEnd:"), name: NSControlTextDidEndEditingNotification, object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self selector:@selector(editingDidEnd:) name:NSControlTextDidEndEditingNotification object:nil)

    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
            self.columnsClearAndRebuild()
            self.tableViewCSVdata.reloadData()
            self.tableViewHeaders.reloadData()
            
            
        }
    }

    // MARK: - CSV data table
    
    func columnsClearAndRebuild(){
        
        while self.tableViewCSVdata.tableColumns.count > 0
        {
            self.tableViewCSVdata.removeTableColumn(tableViewCSVdata.tableColumns.last!)
        }
        for var c = 0; c < (self.representedObject as! CSVdata).columnsCount; c++
        {
            let col_title = (self.representedObject as! CSVdata).headers[c]
            let col = NSTableColumn(identifier: col_title)
            col.title = col_title
            self.tableViewCSVdata.addTableColumn(col)
            
        }

    }

    // MARK: - TableView overrides

    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        guard let ident = control.identifier else {
            return true
        }
        switch ident
        {
        case "parametersValueCell":
            guard control.tag < self.parametersArray.count,
            let str = fieldEditor.string else
            {
                break
            }
            self.parametersArray[control.tag][1] = str
        default:
            break
        }
        return true
    }
    
    override func controlTextDidEndEditing(obj: NSNotification) {
       // print(obj, appendNewline: true)
    }

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if tableView.identifier != nil
        {
            switch tableView.identifier!
            {
            case "tableViewCSVdata":
                return (self.representedObject as! CSVdata).csvData.count
            case "tableViewHeaders":
                return (self.representedObject as! CSVdata).headers.count
            case "tableViewSetOfParameters":
                return self.parametersArray.count
                
            default:
                return 0
            }
        }
        return 0
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
            case "tableViewSetOfParameters":
                switch tableView.columnWithIdentifier(tableColumn!.identifier)
                {
                case kParametersTableParametersColumnIndex://parameters
                    cellView = tableView.makeViewWithIdentifier("parametersCell", owner: self) as! NSTableCellView
                    cellView.textField!.stringValue = self.parametersArray[row][kParametersArrayParametersIndex]
                case kParametersTableParametersValuesColumnIndex://parameters
                    cellView = tableView.makeViewWithIdentifier("parametersValueCell", owner: self) as! NSTableCellView
                    cellView.textField!.stringValue = self.parametersArray[row][kParametersArrayParametersValueIndex]
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
    
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        let tableView = notification.object as! NSTableView
        switch tableView.identifier!
        {
        case "tableViewHeaders":
            self.parametersArray = [[String]]()
            self.tableViewSetOfParameters.reloadData()
            self.textFieldColumnRecodedName.stringValue = ""
        default:
            break;
        }
        
    }
    
    
    // MARK: - Column parameters

    func extractParametersIntoSetFromColumn()
    {
        //called from Process menu
        let columnIndex = self.tableViewHeaders.selectedRow
        if columnIndex >= 0 && columnIndex < (self.representedObject as! CSVdata).headers.count
        {
            var set = Set<String>()
            self.textFieldColumnRecodedName.stringValue = (self.representedObject as! CSVdata).headers[columnIndex]+kStringRecodedColumnNameSuffix
            
            for parameter in (self.representedObject as! CSVdata).csvData
            {
                // parameter is a [string] array of row columns
                set.insert(parameter[columnIndex])
            }
            if set.count > 0
            {
                var subArray = Array(set)
                // replace blanks with string
                for var c=0;c < subArray.count; c++
                {
                    if subArray[c].characters.count == 0
                    {
                        subArray[c] = kStringEmpty
                    }
                }
                //clear the parameters array
                self.parametersArray = [[String]]()
                for var row = 0; row<subArray.count; row++
                {
                    self.parametersArray.append([subArray[row],"0"])
                }
            }
            self.tableViewSetOfParameters.reloadData()
        }
    }
    
    func doTheRecodeParametersAndAddNewColumn()
    {
        if self.parametersArray.count > 0
        {
            //give a name
            if self.textFieldColumnRecodedName.stringValue == ""
            {
                self.textFieldColumnRecodedName.stringValue = "Recoded"
            }
            //add name to headers array
            (self.representedObject as! CSVdata).headers.append(self.textFieldColumnRecodedName.stringValue)
            //add a column to the count
            (self.representedObject as! CSVdata).columnsCount++
            
            //make a temporary dictionary
            var paramsDict = [String : String]()
            for paramNameAndValueArray in self.parametersArray
            {
                paramsDict[paramNameAndValueArray[0]] = paramNameAndValueArray[1]
            }
            
            // must add the column to Array BEFORE adding column to table
            for var r = 0; r<(self.representedObject as! CSVdata).csvData.count; r++
            {
                var rowArray = (self.representedObject as! CSVdata).csvData[r]
                ADD CORRECT PARAMETER AFTER LOOKUP
                
                rowArray.append("*")
                (self.representedObject as! CSVdata).csvData[r] = rowArray
            }
            //Safe to add column to table now
            let col = NSTableColumn(identifier: self.textFieldColumnRecodedName.stringValue)
            col.title = self.textFieldColumnRecodedName.stringValue
            self.tableViewCSVdata.addTableColumn(col)
            
            //reload etc
            self.tableViewCSVdata.reloadData()
            self.documentMakeDirty()
        }
    }

}

