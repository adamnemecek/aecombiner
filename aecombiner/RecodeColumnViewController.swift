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
    
    @IBOutlet weak var segmentedSortAsTextOrNumbers: NSSegmentedControl!
    //@IBOutlet weak var segmentedSortParameterOrValue: NSSegmentedControl!
    
    
    
    // MARK: - @IBAction


    @IBAction func recodeParametersAndAddNewColumn(sender: AnyObject) {
        self.doTheRecodeParametersAndAddNewColumn()
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
    

    override func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard let tvidentifier = tableView.identifier, let csvdo = self.myCSVdataViewController() else
        {
            return 0
        }
        switch tvidentifier
        {
        case "tableViewRecodeHeaders":
            return csvdo.numberOfColumnsInData()
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
            self.textFieldColumnRecodedName?.stringValue = self.stringForColumnIndex(self.tableViewHeaders.selectedRow)
      default:
            break;
        }
        
    }
    
    // MARK: - Column parameters
    func stringForRecodedColumn(columnIndex:Int) -> String
    {
        return self.stringForColumnIndex(columnIndex)+kStringRecodedColumnNameSuffix
    }
    
    override func sortParametersOrValuesInTableViewColumn(tableView tableView: NSTableView, tableColumn: NSTableColumn)
    {
        guard tableView.columnWithIdentifier(tableColumn.identifier) >= 0 else {return}
        if tableColumn.sortDescriptorPrototype == nil {tableColumn.sortDescriptorPrototype = NSSortDescriptor(key: nil, ascending: true)}

        let columnIndex = tableView.columnWithIdentifier(tableColumn.identifier)
        let ascending = tableColumn.sortDescriptorPrototype!.ascending
        let sortdirection = ascending ? kAscending : kDescending
        generic_SortArrayOfColumnsAsTextOrValues(arrayToSort: &self.arrayExtractedParameters, columnIndexToSort: columnIndex, textOrvalue: self.segmentedSortAsTextOrNumbers.selectedSegment, direction: sortdirection)
        tableColumn.sortDescriptorPrototype = NSSortDescriptor(key: nil, ascending: !ascending)
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
        guard let csvdo = self.myCSVdataViewController(), let columnIndex = self.selectedColumnFromHeadersTableView(), let set = csvdo.createSetOfParameters(fromColumn: columnIndex) else { return }
        
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
        
        self.tableViewExtractedParameters.reloadData()
        
    }
    
    func doTheRecodeParametersAndAddNewColumn()
    {
        guard self.arrayExtractedParameters.count > 0  else {return}
        guard   let csvVC = self.myCSVdataViewController(),
                let columnIndex = self.selectedColumnFromHeadersTableView()
                else {return}
        //give a name if none
        let colTitle = self.textFieldColumnRecodedName!.stringValue.isEmpty ? self.stringForRecodedColumn(columnIndex) : self.textFieldColumnRecodedName!.stringValue

        //pass it over
        csvVC.addRecodedColumn(withTitle: colTitle, fromColum: columnIndex, usingParamsArray: self.arrayExtractedParameters)
        
        //reload etc
        self.tableViewHeaders.reloadData()
        self.resetExtractedParameters()
        
        
    }

}

