//
//  CSVdataViewController.swift
//  aecombiner
//
//  Created by David Lewis on 12/07/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa

let kRowColumnSeparator = ","

class CSVdataViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    // MARK: - Var
    var associatedCSVdataDocument: CSVdataDocument = CSVdataDocument() {
        didSet {
            // Update the view, if already loaded.
            self.columnsClearAndRebuild()
        }
    }

    
    // MARK: - @IBOutlet
    @IBOutlet weak var tvCSVdata: NSTableView!
    @IBOutlet weak var segmentSortTextOrValue: NSSegmentedControl!
    @IBOutlet weak var labelNumRows: NSTextField!
    @IBOutlet weak var buttonTrashRows: NSButton!

    // MARK: - @IBActions
    @IBAction func mergeFile(sender: NSToolbarItem)
    {
        let panel = NSOpenPanel()
        var types = StringsArray1D()
        types.append("csv")
        types.append("txt")
        panel.allowedFileTypes = types
        if panel.runModal() == NSFileHandlingPanelOKButton
        {
            self.mergeFileFromURL(panel.URL)
        }
    }
    
    @IBAction func pasteColumns(sender: NSToolbarItem)
    {
        guard
            let csvString = NSPasteboard.generalPasteboard().stringForType(NSPasteboardTypeTabularText)
        else {return}
        self.mergeCSVdata(CSVdata(stringTAB: csvString, name: ""))
    }
    
    @IBAction func buttonTrashRowsTapped(sender: AnyObject)
    {
        if self.tvCSVdata.selectedRowIndexes.count > 0
        {
            let alert = NSAlert()
            alert.messageText = "Are you sure you want to delete these rows? This cannot be undone"
            alert.alertStyle = .CriticalAlertStyle
            alert.addButtonWithTitle("Delete")
            alert.addButtonWithTitle("Cancel")
            if alert.runModal() == NSAlertFirstButtonReturn
            {
                if self.associatedCSVdataDocument.csvDataModel.deletedRowsAtIndexes(self.tvCSVdata.selectedRowIndexes) == true
                {
                    self.tvCSVdata.reloadData()
                    self.updateRowCountLabel()
                    self.updateTrashRowsButtonEnabled()
                    self.documentMakeDirty()
                }
            }
        }
    }

    // MARK: - overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

    }
    
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        if menuItem.title == "Paste Columns Merged"
        {
            return NSPasteboard.generalPasteboard().stringForType(NSPasteboardTypeTabularText) != nil
        }
        return super.validateMenuItem(menuItem)
    }

    // MARK: - document
    func documentMakeDirty()
    {
        self.associatedCSVdataDocument.documentMakeDirty()
    }


    
    func mergeFileFromURL(url:NSURL?)
    {
        guard
            let theURL = url,
            let urlname = theURL.lastPathComponent,
            let urltype = theURL.pathExtension,
            let data = NSData(contentsOfURL: theURL)
        else {return}
        
        let csvdata:CSVdata?
        switch urltype
        {
        case "txt":
            csvdata = CSVdata(data: data, name: urlname, delimiter: .TAB)
        case "csv":
            csvdata = CSVdata(data: data, name: urlname, delimiter: .CSV)
        default:
            csvdata = nil
        }
        self.mergeCSVdata(csvdata)
    }
    
    func mergeCSVdata(csvdata: CSVdata?)
    {
        if csvdata != nil && csvdata!.notAnEmptyDataSet()
        {
            var lastColumn = self.associatedCSVdataDocument.csvDataModel.numberOfColumnsInData()//.count automatically adds 1
            var newUniqueColHeaders = StringsArray1D()
            var lookupMatrixOfNewColumns = StringsArray1D()//same length as new unique cols, has either the original column index in if matched, or a new col index if appended
            for colnum in 0..<csvdata!.numberOfColumnsInData()
            {
                let matchedIndex = self.associatedCSVdataDocument.csvDataModel.headersStringsArray1D.indexOf(csvdata!.headersStringsArray1D[colnum])
                if matchedIndex != nil
                {
                    //add the index of original array we have matched
                    lookupMatrixOfNewColumns.append(String(matchedIndex!))
                }
                else
                {
                    //add the index of the last col num, and increment the lastcolnum count, add new unique col name
                    lookupMatrixOfNewColumns.append(String(lastColumn))
                    lastColumn++
                    newUniqueColHeaders.append(csvdata!.headersStringsArray1D[colnum])
               }
            }
            
            if newUniqueColHeaders.count > 0
            {
                //append the new col names to existing headers
                self.associatedCSVdataDocument.csvDataModel.headersStringsArray1D += newUniqueColHeaders
                
                //padd the array with new blank columns
                let padSuffix = StringsArray1D(count: newUniqueColHeaders.count, repeatedValue: "")
                for row in 0..<self.associatedCSVdataDocument.csvDataModel.dataStringsMatrix2D.count
                {
                    self.associatedCSVdataDocument.csvDataModel.dataStringsMatrix2D[row] += padSuffix
                }
            }
            
            //append the new rows onto array
            for row in 0..<csvdata!.dataStringsMatrix2D.count
            {
                //make a row template to change individual cells
                var newRow = StringsArray1D(count: lastColumn, repeatedValue: "")
                for colnumber in 0..<lookupMatrixOfNewColumns.count
                {
                    guard
                        //[x] returns optionals so we force unwrap
                        let validCN = Int(lookupMatrixOfNewColumns[colnumber])
                    else {continue}
                    //replace the cell in the template row with the value in the new csvdata array, place into old columns if matched or new cols if not
                    //the colnumber is our lookup
                    newRow[validCN] = csvdata!.dataStringsMatrix2D[row][colnumber]
                }
                //append new row to existing
                self.associatedCSVdataDocument.csvDataModel.dataStringsMatrix2D.append(newRow)
            }
            
            //NOW it is safe to add table columns
            for col in 0..<newUniqueColHeaders.count
            {
                self.tvCSVdata.addTableColumn(NSTableColumn.columnWithUniqueIdentifierAndTitle(newUniqueColHeaders[col]))
            }
            
            //clean up
            self.documentMakeDirty()
            self.tvCSVdata.reloadData()
        }
    }
    
    
    // MARK: - merge by lookup
    func lookupNewColumnsFromCSVdata(lookupCSVdata lookupCSVdata:CSVdata, lookupColumn:Int, columnsToAdd:NSIndexSet)
    {
        guard
            let newUniqueColHeaders = self.associatedCSVdataDocument.csvDataModel.lookedupNewColumnsFromCSVdata(lookupCSVdata: lookupCSVdata, lookupColumn: lookupColumn, columnsToAdd: columnsToAdd)
        else {return}
        
        //NOW it is safe to add table columns
        for col in 0..<columnsToAdd.count
        {
            self.tvCSVdata.addTableColumn(NSTableColumn.columnWithUniqueIdentifierAndTitle(newUniqueColHeaders[col]))
        }
        
        //clean up
        self.documentMakeDirty()
        self.tvCSVdata.reloadData()
    
    }
    // MARK: - extracting CSV data table

    func extractRowsBasedOnPredicatesIntoNewFile(predicates predicates:ArrayOfPredicatesForExtracting)
    {
        self.associatedCSVdataDocument.csvDataModel.extractRowsBasedOnPredicatesIntoNewFile(predicates: predicates)
        self.tvCSVdata.reloadData()
        
    }
    
    // MARK: - Rows
    func deleteSelectedRows()
    {
        if self.tvCSVdata.selectedRowIndexes.count > 0
        {
            let alert = NSAlert()
            alert.messageText = "Are you sure you want to delete these rows? This cannot be undone"
            alert.alertStyle = .CriticalAlertStyle
            alert.addButtonWithTitle("Delete")
            alert.addButtonWithTitle("Cancel")
            if alert.runModal() == NSAlertFirstButtonReturn
            {
                if self.associatedCSVdataDocument.csvDataModel.deletedRowsAtIndexes(self.tvCSVdata.selectedRowIndexes) == true
                {
                    self.tvCSVdata.reloadData()
                    self.updateRowCountLabel()
                    self.updateTrashRowsButtonEnabled()
                    self.associatedCSVdataDocument.documentMakeDirty()
                }
            }
        }
    }
    
    // MARK: - Columns

    func updateRowCountLabel()
    {
        let suffix = self.associatedCSVdataDocument.csvDataModel.numberOfRowsInData() == 1 ? " row" : " rows"
        self.labelNumRows.stringValue = String(self.associatedCSVdataDocument.csvDataModel.numberOfRowsInData()) + suffix
    }
    
   func columnsClearAndRebuild(){
        
        self.associatedCSVdataDocument.columnsClearAndRebuild(self.tvCSVdata)
        self.updateRowCountLabel()
    }
    
    func renameColumnAtIndex(columnIndex: Int, newName:String)
    {
        guard
            self.associatedCSVdataDocument.csvDataModel.renamedColumnAtIndex(columnIndex: columnIndex, newName:newName)
            else {return}
        self.tvCSVdata.tableColumns[columnIndex].title = newName
        self.tvCSVdata.reloadData()
    }

    func recodedColumnInSitu(columnToRecode columnIndex:Int, usingParamsArray paramsArray:StringsMatrix2D, copyUnmatchedValues:Bool)->Bool
    {
        guard
            self.associatedCSVdataDocument.csvDataModel.recodedColumnInSitu(columnToRecode: columnIndex, usingParamsArray: paramsArray, copyUnmatchedValues:copyUnmatchedValues)
            else {return false}
        self.tvCSVdata.reloadData()
        self.tvCSVdata.scrollColumnToVisible(columnIndex)
        return true
    }
    
    func addedRecodedColumn(withTitle title:String, fromColum columnIndex:Int, usingParamsArray paramsArray:StringsMatrix2D, copyUnmatchedValues:Bool)->Bool
    {
        guard
            self.associatedCSVdataDocument.csvDataModel.addedRecodedColumn(title: title, fromColum: columnIndex, usingParamsArray: paramsArray, copyUnmatchedValues:copyUnmatchedValues)
            else {return false}
        //Safe to add column to table now
        self.addTableColumnAndScrollWithTitle(title)
        return true
    }
    
    func addedRecodedColumnByBooleanCompareWithColumn(title title:String, fromColum:Int, compareColumn:Int, booleanString:String, replacementString:String, copyUnmatchedValues:Bool)->Bool
    {
        guard
            self.associatedCSVdataDocument.csvDataModel.addedRecodedColumnByBooleanCompareWithColumn(title: title, fromColum:fromColum, compareColumn:compareColumn, booleanString:booleanString, replacementString:replacementString, copyUnmatchedValues:copyUnmatchedValues)
            else {return false}
        //Safe to add column to table now
        self.addTableColumnAndScrollWithTitle(title)
        return true
    }
    
    func addedRecodedColumnByMathsFunction_ColumnMaths(title title:String, fromColum:Int, mathsColumn:Int, functionString:String, copyUnmatchedValues:Bool)->Bool
    {
        guard
            self.associatedCSVdataDocument.csvDataModel.addedRecodedColumnByMathsFunction_ColumnMaths(title: title, fromColum: fromColum, mathsColumn: mathsColumn, functionString: functionString, copyUnmatchedValues: copyUnmatchedValues)
            else {return false}
        //Safe to add column to table now
        self.addTableColumnAndScrollWithTitle(title)
        return true
 
    }
    
    func addedRecodedColumnByMathsFunction_AbsoluteValue(title title:String, fromColum:Int, absoluteValue:Double, functionString:String, copyUnmatchedValues:Bool)->Bool
    {
        guard
            self.associatedCSVdataDocument.csvDataModel.addedRecodedColumnByMathsFunction_AbsoluteValue(title: title, fromColum: fromColum, absoluteValue: absoluteValue, functionString: functionString, copyUnmatchedValues: copyUnmatchedValues)
            else {return false}
        //Safe to add column to table now
        self.addTableColumnAndScrollWithTitle(title)
        return true
    }
    
    
    func deletedColumnAtIndex(columnIndex: Int)->Bool
    {
        guard self.associatedCSVdataDocument.csvDataModel.deletedColumnAtIndex(columnIndex) else {return false}
        
        //Safe to delete column to table now
        self.tvCSVdata.removeTableColumn(self.tvCSVdata.tableColumns[columnIndex])
        self.tvCSVdata.reloadData()
        self.documentMakeDirty()
        return true
    }
    
    func recodedDateTimeToNewColumn(withTitle title:String, fromColum:Int, formatMethod:DateTimeFormatMethod, formatString:String, copyUnmatchedValues:Bool, asString:Bool)->Bool
    {
        guard
            self.associatedCSVdataDocument.csvDataModel.recodedDateTimeToNewColumn(withTitle: title, fromColum: fromColum, formatMethod: formatMethod, formatString: formatString, asString:asString, copyUnmatchedValues: copyUnmatchedValues)
            else {return false}
        //Safe to add column to table now
        self.addTableColumnAndScrollWithTitle(title)
        return true
    }

    func calculatedDateTimeToNewColumn(withTitle title:String, startColumn:Int, endColumn:Int, formatMethod:DateTimeFormatMethod, formatString:String, roundingUnits:DateTimeRoundingUnits, copyUnmatchedValues: Bool)->Bool
    {
        guard
            self.associatedCSVdataDocument.csvDataModel.calculatedDateTimeToNewColumn(withTitle: title, startColumn: startColumn, endColumn: endColumn, formatMethod: formatMethod, formatString: formatString, roundingUnits: roundingUnits, copyUnmatchedValues: copyUnmatchedValues)
            else {return false}
        //Safe to add column to table now
        self.addTableColumnAndScrollWithTitle(title)
        return true
    }
    
    func addTableColumnAndScrollWithTitle(title:String)
    {
        self.tvCSVdata.addTableColumn(NSTableColumn.columnWithUniqueIdentifierAndTitle(title))
        self.tvCSVdata.reloadData()
        self.tvCSVdata.scrollColumnToVisible(self.tvCSVdata.numberOfColumns-1)
        self.documentMakeDirty()
    }
    // MARK: - TableView overrides
    func tableView(tableView: NSTableView, mouseDownInHeaderOfTableColumn tableColumn: NSTableColumn) {
        tableView.sortParametersOrValuesInTableViewColumn(tableColumn: tableColumn, arrayToSort: &self.associatedCSVdataDocument.csvDataModel.dataStringsMatrix2D, textOrValue: self.segmentSortTextOrValue.selectedSegment)
        
        self.tvCSVdata.reloadData()

    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        //guard let tvidentifier = tableView.identifier else {return 0}
        switch tableView
        {
        case self.tvCSVdata:
            self.updateRowCountLabel()
            return self.associatedCSVdataDocument.csvDataModel.numberOfRowsInData()
        default:
            return 0
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // Retrieve to get the @"MyView" from the pool or,
        // if no version is available in the pool, load the Interface Builder version
        var cellView = NSTableCellView()
        guard
            let id = tableColumn?.identifier
        else {return cellView}
        
        let colIndex = tableView.columnWithIdentifier(id)
        guard colIndex >= 0 else {return cellView}
        
        switch tableView
        {
        case self.tvCSVdata:
            cellView = tableView.makeViewWithIdentifier("csvCell", owner: self) as! NSTableCellView
            // Set the stringValue of the cell's text field to the nameArray value at row
            let valS = self.associatedCSVdataDocument.csvDataModel.stringValueForCell(fromColumn: colIndex, atRow: row)
            if valS != nil
            {
                cellView.textField!.stringValue = valS!
            }
            cellView.textField!.identifier = "\(row)"+kRowColumnSeparator+"\(colIndex)"
        default:
            break
        }
        
        
        // Return the cellView
        return cellView;
    }
    
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        guard
            let tableView = notification.object as? NSTableView
        else {return}
        
        switch tableView
        {
        case self.tvCSVdata:
            self.updateTrashRowsButtonEnabled()
        default:
            break;
        }
        
    }
    
    func updateTrashRowsButtonEnabled()
    {
        self.buttonTrashRows.enabled = self.tvCSVdata.selectedRowIndexes.count > 0
    }

    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        guard
            let _ = control as? NSTextField,
            let id = control.identifier,
            let row = Int(id.componentsSeparatedByString(kRowColumnSeparator)[0]),
            let column = Int(id.componentsSeparatedByString(kRowColumnSeparator)[1]),
            let str = fieldEditor.string
        else {return true}
        
        self.associatedCSVdataDocument.csvDataModel.setStringValueForCell(valueString: str, toColumn: column, inRow: row)
        self.documentMakeDirty()
        return true
    }

  

    
    
    
}
