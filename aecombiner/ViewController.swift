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
    
    // MARK: - @IBOutlet

    @IBOutlet weak var tableViewCSVdata: NSTableView!
    @IBOutlet weak var tableViewHeaders: NSTableView!
    @IBOutlet weak var tableViewSetOfParameters: NSTableView!
    
    
    // MARK: - @IBAction - First Responder
    @IBAction func extractParameters(sender: AnyObject) {
        //called from Process menu
        let row = self.tableViewHeaders.selectedRow
        if row >= 0 && row < (self.representedObject as! CSVdata).headers.count
        {
            self.extractParametersIntoSetFromColumn(row)
            self.tableViewSetOfParameters.reloadData()
        }
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
            self.columnsClearAndRebuild()
            self.tableViewCSVdata.reloadData()
            self.tableViewHeaders.reloadData()
            
            
        }
    }

    // MARK: - CSV data table

    func columnsClearAndRebuild(){
        
        while self.tableViewCSVdata.tableColumns.count > 0
        {
            self.tableViewCSVdata.removeTableColumn(tableViewCSVdata.tableColumns.last as! NSTableColumn)
        }
        for var c = 0; c < (self.representedObject as! CSVdata).columnsCount; c++
        {
            var col_title = (self.representedObject as! CSVdata).headers[c]
            var col = NSTableColumn(identifier: col_title)
            col.title = col_title
            self.tableViewCSVdata.addTableColumn(col)
            
        }

    }

    // MARK: - TableView overrides

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
        if tableView.identifier != nil
        {
            switch tableView.identifier!
            {
            case "tableViewCSVdata":
                cellView = tableView.makeViewWithIdentifier("csvCell", owner: self) as! NSTableCellView
                // Set the stringValue of the cell's text field to the nameArray value at row
                let colIndex = tableView.columnWithIdentifier(tableColumn?.identifier)
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
                default:
                    break
                }
                
            default:
                break;
            }
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

        default:
            break;
        }
        
    }
    
    
    
    // MARK: - Column parameters

    func extractParametersIntoSetFromColumn(columnIndex: Int)
    {
        var set = Set<String>()
        for parameter in (self.representedObject as! CSVdata).csvData
        {
            // parameter is a [string] array of row columns
            set.insert(parameter[columnIndex])
        }
        if set.count > 0
        {
            let subArray = Array(set)
            //clear the parameters array
            self.parametersArray = [[String]]()
           for var row = 0; row<subArray.count; row++
            {
                self.parametersArray.append([subArray[row],"\(row)"])
            }

        }
    }
}

