//
//  ViewController.swift
//  aecombiner
//
//  Created by David JM Lewis on 25/06/2015.
//  Copyright (c) 2015 djml.eu. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    var parametersSet = Set<String>()
    
    @IBOutlet weak var tableViewCSVdata: NSTableView!
    @IBOutlet weak var tableViewHeaders: NSTableView!
    @IBOutlet weak var tableViewSetOfParameters: NSTableView!
    
    
    
    
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

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if tableView.identifier != nil
        {
            switch tableView.identifier!
            {
            case "tableViewCSVdata":
                return (self.representedObject as! CSVdata).csvData.count
            case "tableViewHeaders":
                return (self.representedObject as! CSVdata).headers.count
                
                
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
            var params = self.extractParametersIntoSetFromColumnWithHeading("")
        default:
            break;
        }
        
    }
    
    func extractParametersIntoSetFromColumnWithHeading(heading: String) -> Set<String>
    {
        var set = Set<String>()
        
        return set
        
    }
}

