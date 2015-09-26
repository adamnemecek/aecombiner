//
//  CSVdataViewController.swift
//  aecombiner
//
//  Created by David Lewis on 12/07/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa

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

    // MARK: - @IBActions
    
    @IBAction func rebuildColumns(sender: AnyObject) {
        self.columnsClearAndRebuild() 
    }
    
    

    // MARK: - overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "addColumnWithIdentifier:", name: "addColumnWithIdentifier", object: nil)

    }
    
    // MARK: - document
    func documentMakeDirty()
    {
        //CSVdataDocument.makeDocumentDirtyForView(self.view)
        self.associatedCSVdataDocument.updateChangeCount(.ChangeDone)
    }

    
    // MARK: - extracting CSV data table

    func extractRowsBasedOnPredicatesIntoNewFile(predicates predicates:ExtractingPredicatesArray)
    {
        self.associatedCSVdataDocument.extractRowsBasedOnPredicatesIntoNewFile(predicates: predicates)
        self.tvCSVdata.reloadData()
    }
    
    func extractDataMatrixUsingPredicates(predicates predicates:ExtractingPredicatesArray)->MulticolumnStringsArray
    {
        return self.associatedCSVdataDocument.extractDataMatrixUsingPredicates(predicates: predicates)
    }
    
    func chartDataSetFromColumnIndex(columnIndex columnIndex:Int)->ChartDataSet
    {
        return self.associatedCSVdataDocument.chartDataSetFromColumnIndex(columnIndex: columnIndex)
    }
    
    func combinedColumnsAndNewColumnName(columnIndexForGrouping columnIndexForGrouping:Int, columnIndexesToGroup: NSIndexSet, arrayOfParamatersInGroup:SingleColumnStringsArray , groupMethod:String) -> NamedDataMatrix//(csvDataMatrix:MulticolumnStringsArray, nameOfColumn:String)
    {
        return self.associatedCSVdataDocument.combinedColumnsAndNewColumnName(columnIndexForGrouping: columnIndexForGrouping, columnIndexesToGroup: columnIndexesToGroup, arrayOfParamatersInGroup: arrayOfParamatersInGroup, groupMethod: groupMethod)
    }
    
    func dataMatrixOfParametersFromColumn(fromColumn columnIndex:Int)->MulticolumnStringsArray?
    {
        return self.associatedCSVdataDocument.dataMatrixOfParametersFromColumn(fromColumn: columnIndex)
    }
    
    func setOfParametersFromColumnIfStringMatchedInColumn(fromColumn fromColumn:Int, matchString:String, matchColumn:Int)->SetOfStrings?
    {
        return self.associatedCSVdataDocument.setOfParametersFromColumnIfStringMatchedInColumn(fromColumn: fromColumn, matchString: matchString, matchColumn: matchColumn)
    }
    
    func dataMatrixFromAssociatedCSVdataDocument()->MulticolumnStringsArray?
    {
        return self.associatedCSVdataDocument.csvDataModel.csvData
    }
    
    // MARK: -  creating docs
   func createNewDocumentFromExtractedRows(cvsData extractedRows:MulticolumnStringsArray, headers:SingleColumnStringsArray?, name: String?)
    {
        self.associatedCSVdataDocument.createNewDocumentFromExtractedRows(cvsData: extractedRows, headers: headers, name: name)
    }
    
    func combineColumnsAndExtractToNewDocument(columnIndexForGrouping columnIndexForGrouping:Int, columnIndexesToGroup: NSIndexSet, arrayOfParamatersInGroup:SingleColumnStringsArray , groupMethod:String)
    {
        self.associatedCSVdataDocument.combineColumnsAndExtractToNewDocument(columnIndexForGrouping: columnIndexForGrouping, columnIndexesToGroup: columnIndexesToGroup, arrayOfParamatersInGroup: arrayOfParamatersInGroup, groupMethod: groupMethod)
        
    }
    
   func combineColumnsAndExtractAllStatsToNewDocument(columnIndexForGrouping columnIndexForGrouping:Int, columnIndexesToGroup: NSIndexSet, arrayOfParamatersInGroup:SingleColumnStringsArray )
    {
        self.associatedCSVdataDocument.combineColumnsAndExtractAllStatsToNewDocument(columnIndexForGrouping: columnIndexForGrouping, columnIndexesToGroup: columnIndexesToGroup)
    }
    

    // MARK: - Columns
    
    func numberOfColumnsInData()->Int{
        return self.associatedCSVdataDocument.numberOfColumnsInData()
    }
    
    func headerStringsForAllColumns()->[String]
    {
        return self.associatedCSVdataDocument.headerStringsForAllColumns()
    }

    func headerStringForColumnIndex(columnIndex:Int?) -> String
    {
        return self.associatedCSVdataDocument.headerStringForColumnIndex(columnIndex)
    }
    
    func checkedExtractingPredicatesArray(arrayToCheck:ExtractingPredicatesArray)->ExtractingPredicatesArray
    {
        return self.associatedCSVdataDocument.checkedExtractingPredicatesArray(arrayToCheck)
    }
    
    func requestedColumnIndexIsOK(columnIndex:Int) -> Int?
    {
        return self.associatedCSVdataDocument.requestedColumnIndexIsOK(columnIndex)
    }
    


    
   func columnsClearAndRebuild(){
        
        self.associatedCSVdataDocument.columnsClearAndRebuild(self.tvCSVdata)
        self.labelNumRows.stringValue = String(self.associatedCSVdataDocument.numberOfRowsOfData())
    }
    
    func renameColumnAtIndex(columnIndex: Int, newName:String)
    {
        guard columnIndex >= 0 && !newName.isEmpty else {return}
        self.associatedCSVdataDocument.csvDataModel.headers[columnIndex] = newName
        self.tvCSVdata.tableColumns[columnIndex].title = newName
        self.tvCSVdata.reloadData()
    }

    
    func addRecodedColumn(withTitle title:String, fromColum columnIndex:Int, usingParamsArray paramsArray:MulticolumnStringsArray)
    {
        self.associatedCSVdataDocument.addRecodedColumn(withTitle: title, fromColum: columnIndex, usingParamsArray: paramsArray)
        
        //Safe to add column to table now
        self.tvCSVdata.addTableColumn(self.associatedCSVdataDocument.columnWithUniqueIdentifierAndTitle(title))
        self.tvCSVdata.reloadData()
        self.tvCSVdata.scrollColumnToVisible(self.tvCSVdata.numberOfColumns-1)
        self.documentMakeDirty()
    }
    
    func deleteColumnAtIndex(columnIndex: Int)
    {
        guard self.associatedCSVdataDocument.deletedColumnAtIndex(columnIndex) else {return}
        
        //Safe to delete column to table now
        self.tvCSVdata.removeTableColumn(self.tvCSVdata.tableColumns[columnIndex])
        self.tvCSVdata.reloadData()
        self.documentMakeDirty()

    }
    
    
    func addColumnWithIdentifier(notification: NSNotification)
    {
        guard let title = notification.object as? String else {return}
        self.tvCSVdata.addTableColumn(self.associatedCSVdataDocument.columnWithUniqueIdentifierAndTitle(title))
        self.tvCSVdata.reloadData()
        self.tvCSVdata.scrollColumnToVisible(self.tvCSVdata.numberOfColumns-1)
    }


    // MARK: - TableView overrides
    func tableView(tableView: NSTableView, mouseDownInHeaderOfTableColumn tableColumn: NSTableColumn) {
        let columnIndex = tableView.columnWithIdentifier(tableColumn.identifier)
        guard columnIndex >= 0 else {return}
        if tableColumn.sortDescriptorPrototype == nil
        {
            tableColumn.sortDescriptorPrototype = NSSortDescriptor(key: nil, ascending: true)
        }

        let sortdirection = tableColumn.sortDescriptorPrototype!.ascending
        self.associatedCSVdataDocument.sortCSVrowsInColumnAsTextOrValues(columnIndexToSort: columnIndex, textOrvalue: self.segmentSortTextOrValue.selectedSegment, direction:sortdirection)
        tableColumn.sortDescriptorPrototype = NSSortDescriptor(key: nil, ascending: !sortdirection)
        self.tvCSVdata.reloadData()

    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        guard let tvidentifier = tableView.identifier else
        {
            return 0
        }
        switch tvidentifier
        {
        case "tvCSVdata":
            return self.associatedCSVdataDocument.numberOfRowsOfData()
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
        case "tvCSVdata":
            cellView = tableView.makeViewWithIdentifier("csvCell", owner: self) as! NSTableCellView
            // Set the stringValue of the cell's text field to the nameArray value at row
            let colIndex = tableView.columnWithIdentifier((tableColumn?.identifier)!)
            cellView.textField!.stringValue = self.associatedCSVdataDocument.csvDataModel.csvData[row][colIndex]
            
        default:
            break;
        }
        
        
        // Return the cellView
        return cellView;
    }
    
    /*
    func tableViewSelectionDidChange(notification: NSNotification) {
        let tableView = notification.object as! NSTableView
        switch tableView.identifier!
        {

        default:
            break;
        }
        
    }
    */

    
  

    
    
    
}
