//
//  CSVdataDocument.swift
//  aecombiner
//
//  Created by David JM Lewis on 25/06/2015.
//  Copyright (c) 2015 djml.eu. All rights reserved.
//

import Cocoa

let kAscending = true
let kDescending = false
let kSortAsText = 0
let kSortAsValue = 1

class CSVdataDocument: NSDocument {
    var csvDataModel: CSVdata = CSVdata() {
        didSet {
            // Update the view, if already loaded.
            self.csvdataviewcontrollerForDocument()?.columnsClearAndRebuild()
        }
    }
    class func makeDocumentDirtyForView(view:NSView)
    {
        view.window?.windowController?.document?.updateChangeCount(.ChangeDone)
    }
    
    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override func windowControllerDidLoadNib(aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
        // Add any code here that needs to be executed once the windowController has loaded the document's window.
        // ?not called...
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your CSVdataDocument window.
        
        self.makeAndShowCSVdataWindow()
        
        self.showWindows()
    }

       func makeAndShowCSVdataWindow()
    {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let csvDataWindowController = storyboard.instantiateControllerWithIdentifier("CSVdataWindowController") as! CSVdataWindowController
        self.addWindowController(csvDataWindowController)
        (csvDataWindowController.window?.contentViewController as? CSVdataViewController)?.myCSVdataDocument = self

    }

    func csvdataviewcontrollerForDocument()->CSVdataViewController?
    {
        if self.windowControllers.count > 0
        {
            let vc = self.windowControllers[0].window?.contentViewController
            if vc == nil
            {
                return nil
            }
            else
            {
                return vc as? CSVdataViewController
            }
        }
        return nil
    }
    
    // MARK: - Data
    func numberOfRowsOfData()->Int
    {
        return self.csvDataModel.csvData.count
    }
    
    func numberOfColumnsInData()->Int{
        return self.csvDataModel.headers.count
    }
    
    func deleteColumnAtIndex(columnIndex: Int)
    {
        guard columnIndex >= 0 && columnIndex < self.numberOfColumnsInData() else {return}
        
        // must delete the column from Array BEFORE deleting  table
        for var r = 0; r<self.csvDataModel.csvData.count; r++
        {
            var rowArray = self.csvDataModel.csvData[r]
            rowArray.removeAtIndex(columnIndex)
            self.csvDataModel.csvData[r] = rowArray
        }
        //remove from headers array
        self.csvDataModel.headers.removeAtIndex(columnIndex)        
    }

    func addRecodedColumn(withTitle title:String, fromColum columnIndex:Int, usingParamsArray paramsArray:[[String]])
    {
        //make a temporary dictionary
        var paramsDict = [String : String]()
        for paramNameAndValueArray in paramsArray
        {
            paramsDict[paramNameAndValueArray[0]] = paramNameAndValueArray[1]
        }
        
        // must add the column to Array BEFORE adding column to table
        for var r = 0; r<self.csvDataModel.csvData.count; r++
        {
            var rowArray = self.csvDataModel.csvData[r]
            //ADD CORRECT PARAMETER AFTER LOOKUP
            let valueToRecode = rowArray[columnIndex]
            let recodedValue = (paramsDict[valueToRecode] ?? "")
            rowArray.append(recodedValue)
            self.csvDataModel.csvData[r] = rowArray
        }
        //add name to headers array
        self.csvDataModel.headers.append(title)
    }

    func columnWithUniqueIdentifierAndTitle(title:String)->NSTableColumn
    {
        let col =  NSTableColumn(identifier:String(NSDate().timeIntervalSince1970))
        col.title = title
        col.sortDescriptorPrototype = NSSortDescriptor(key: nil, ascending: false)

        return col
    }

    func columnsClearAndRebuild(tableViewCSVdata:NSTableView){
        
        while tableViewCSVdata.tableColumns.count > 0
        {
            tableViewCSVdata.removeTableColumn(tableViewCSVdata.tableColumns.last!)
        }
        for var c = 0; c < numberOfColumnsInData(); c++
        {
            tableViewCSVdata.addTableColumn(self.columnWithUniqueIdentifierAndTitle(self.csvDataModel.headers[c]))
            
        }
        tableViewCSVdata.reloadData()
    }

    func requestedColumnIndexIsOK(columnIndex:Int) -> Bool
    {
        return columnIndex >= 0 && columnIndex < self.numberOfColumnsInData()
    }

    override func dataOfType(typeName: String) throws -> NSData {
        var outError: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        outError = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        switch typeName
        {
        case "csvFile":
            if let value = self.csvDataModel.processCSVtoData() {
                return value
            }
            throw outError
        default:
            throw outError
        }
    }

    override func readFromData(data: NSData, ofType typeName: String) throws {
        var outError: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
        outError = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        switch typeName
        {
        case "csvFile":
            self.csvDataModel = CSVdata(data: data)
            if self.csvDataModel.processedDataOK {
                return
            }
            throw outError
        default:
            throw outError
        }
        
    }

    func sortParametersOrValues(indexToSort indexToSort:Int, textOrvalue:Int, ascending: Bool)
    {
        switch (ascending, textOrvalue)
        {
        case (kAscending,kSortAsValue):
            self.csvDataModel.csvData.sortInPlace({ (leftRow, rightRow) -> Bool in
                return Double(leftRow[indexToSort])>Double(rightRow[indexToSort])
            })
        case (kDescending,kSortAsValue):
            self.csvDataModel.csvData.sortInPlace({ (leftRow, rightRow) -> Bool in
                return Double(leftRow[indexToSort])<Double(rightRow[indexToSort])
            })
        case (kAscending,kSortAsText):
            self.csvDataModel.csvData.sortInPlace({ (leftRow, rightRow) -> Bool in
                return leftRow[indexToSort]>rightRow[indexToSort]
            })
        case (kDescending,kSortAsText):
            self.csvDataModel.csvData.sortInPlace({ (leftRow, rightRow) -> Bool in
                return leftRow[indexToSort]<rightRow[indexToSort]
            })
        default:
            return
        }
    }

    func extractRowsBasedOnParameters(ANDpredicates ANDpredicates:[[String]], ORpredicates:[[String]])
    {
        var extractedRows = [[String]]()
        for rowOfColumns in self.csvDataModel.csvData
        {
            //assume row is matched
            var rowMatchedAND = true
            var rowMatchedOR = true
            
            // rowOfColumns is a [string] array of row columns
            // the predicate is a [column#][query text]
            //do AND first as if just one is unmatched then we reject the row
            for predicateAND in ANDpredicates
            {
                if rowOfColumns[Int(predicateAND[0])!] != predicateAND[1]
                {
                    //we break this ANDpredicates loop with rowMatched false
                    rowMatchedAND = false
                    break
                }
            }
            
            // if we ended the AND loop without setting row matched false, and have OR predicates to match
            if rowMatchedAND == true && ORpredicates.count > 0
            {
                //as we have OR predicates we must flip its value, so any OR can reset to true
                rowMatchedOR = false
                // check ORpredicates, just one true will exit and flip the rowMatched
                for predicateOR in ORpredicates
                {
                    if rowOfColumns[Int(predicateOR[0])!] == predicateOR[1]
                    {
                        //we break this ORpredicates loop and flip the rowMatchedOR
                        rowMatchedOR = true
                        break
                    }
                }
            }
            
            // if we ended the AND and OR loops without setting row matched false, add row
            if rowMatchedOR && rowMatchedAND
            {
                extractedRows.append(rowOfColumns)
            }
        }
        
        if extractedRows.count > 0
        {
            self.createNewDocumentFromExtractedRows(extractedRows)
        }        
    }
    
    func createNewDocumentFromExtractedRows(extractedRows:[[String]])
    {
        do {
            let doc = try NSDocumentController.sharedDocumentController().openUntitledDocumentAndDisplay(true)
            if doc is CSVdataDocument
            {
                (doc as! CSVdataDocument).csvDataModel = CSVdata(headers: self.csvDataModel.headers, csvdata: extractedRows)
                (doc as! CSVdataDocument).updateChangeCount(.ChangeDone)
            }
        } catch {
            print("Error making new doc")
        }
    }

    func createSetOfParameters(fromColumn columnIndex:Int)->Set<String>?
    {
        var set: Set<String>? = Set<String>()
        for parameter in self.csvDataModel.csvData
        {
            // parameter is a [string] array of row columns
            set!.insert(parameter[columnIndex])
        }
        if set!.count == 0
        {
            set = nil
        }
        return set
    }

    func stringForColumnIndex(columnIndex:Int?) -> String
    {
        guard let index = columnIndex where columnIndex >= 0 && columnIndex < self.numberOfColumnsInData() else {return "???"}
        return (self.csvDataModel.headers[index])
    }

}

