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
let kSortOriginal = -1
let kSortAsText = 0
let kSortAsValue = 1
let kBooleanStringAND = "2AND"
let kBooleanStringOR = "3OR"
let kBooleanStringNOT = "1NOT"

let kSubstituteValueForZeroInLogarithm = -1.00

let kGroupAddition = "Sum"
let kGroupMultiplication = "Product"
let kGroupCount = "Count"
let kGroupMean = "Mean"
let kGroupGeoMean = "Geometric Mean"
let kGroupMax = "Maximum"
let kGroupMin = "Minimum"
let kGroupRange = "Range"
let kGroupLogRange = "Log Range"
let kGroupLogSum = "Log Sum"
let kGroupAllStats = "AllStats"


let kCsvDataData_column_groupingIDs = 0// in a [[String]] of combined CVSdata 0 is the ids and 1 is the data
let kCsvDataData_column_value = 1

struct AggregatedStats {
    var minm:Double = Double(Int.max)
    var maxm:Double = 0
    var sum:Double = 0
    var product:Double = 1
    var logSum:Double = 0
    var count:Int = 0
    var logCount:Int = 0
    var skippedValues = 0
    var skippedLogs = 0
}





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
    
    func documentMakeDirty()
    {
        self.updateChangeCount(.ChangeDone)
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
        (csvDataWindowController.window?.contentViewController as? CSVdataViewController)?.associatedCSVdataDocument = self

    }
    
    // MARK: - File I/O
    
    override func dataOfType(typeName: String) throws -> NSData {
        var outError: NSError! = NSError(domain: "Migrator", code: 0, userInfo: nil)
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        outError = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        switch typeName
        {
        case "csvFile":
            if let value = self.csvDataModel.processCSVtoData(delimiter: commaDelimiter) {
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
            self.csvDataModel = CSVdata(dataCSV: data, name:self.displayName)
            if self.csvDataModel.processedDataOK {
                return
            }
            throw outError
        default:
            throw outError
        }
        
    }
    
    func exportDataTabDelimitedTo(fileURL fileURL:NSURL?)
    {
        guard let theURL = fileURL else {return}
        let data = self.csvDataModel.processCSVtoData(delimiter: tabDelimiter)
        guard let okData = data else {return}
        
        okData.writeToURL(theURL, atomically: true)
    }

    // MARK: - CSVdataViewController

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
    
    // MARK: - Grouping Combining
   
    
    
    
    
    func combineColumnsAndExtractAllStatsToNewDocument(columnIndexForGrouping columnIndexForGrouping:Int, columnIndexesToGroup: NSIndexSet)
    {
        // check OK to group
        guard
            columnIndexForGrouping >= 0 &&
            columnIndexForGrouping < self.csvDataModel.numberOfColumnsInData() &&
            columnIndexesToGroup.count > 0

        else {return}
        
        
        //extract the rows and present
        let stats = self.csvDataModel.combinedColumnsAndNewColumnName_UsingAllMethods(columnIndexForGrouping: columnIndexForGrouping, columnIndexesToGroup: columnIndexesToGroup)
        
        self.createNewDocumentFromCVSDataAndColumnName(cvsData: stats, name: "All Stats("+stats.name+") by "+self.csvDataModel.headerStringForColumnIndex(columnIndexForGrouping))
    }
    
    
    
    func combineColumnsAndExtractToNewDocument(columnIndexForGrouping columnIndexForGrouping:Int, columnIndexesToGroup: NSIndexSet, arrayOfParamatersInGroup:StringsArray1D , groupMethod:String)
    {
        //extract the rows and present
        let combinedDataAndName = self.csvDataModel.combinedColumnsAndNewColumnName_UsingSingleMethod(columnIndexForGrouping: columnIndexForGrouping, columnIndexesToGroup: columnIndexesToGroup, arrayOfParamatersInGroup: arrayOfParamatersInGroup, groupMethod: groupMethod)
        self.createNewDocumentFromExtractedRows(cvsData: combinedDataAndName.matrixOfData, headers: [self.csvDataModel.headerStringForColumnIndex(columnIndexForGrouping),combinedDataAndName.nameOfData], name: combinedDataAndName.nameOfData+" by "+self.csvDataModel.headerStringForColumnIndex(columnIndexForGrouping))
    }
    
    
   
    // MARK: - Data
    
    func chartDataSetFromColumnIndex(columnIndex columnIndex:Int)->ChartDataSet
    {
        return ChartDataSet(data: self.csvDataModel.csvData, forColumnIndex: columnIndex)
    }

    
    
    func deletedColumnAtIndex(columnIndex: Int)->Bool
    {
        guard columnIndex >= 0 && columnIndex < self.csvDataModel.numberOfColumnsInData() else {return false}
        
        // must delete the column from Array BEFORE deleting  table
        for var r = 0; r<self.csvDataModel.csvData.count; r++
        {
            var rowArray = self.csvDataModel.csvData[r]
            rowArray.removeAtIndex(columnIndex)
            self.csvDataModel.csvData[r] = rowArray
        }
        //remove from headers array
        self.csvDataModel.headers.removeAtIndex(columnIndex)
        return true
    }

    func addRecodedColumn(withTitle title:String, fromColum columnIndex:Int, usingParamsArray paramsArray:StringsMatrix2D, copyUnmatchedValues:Bool)
    {
        //make a temporary dictionary
        var paramsDict = CSVdata.paramsDictFromParamsArray(paramsArray)
        
        // must add the column to Array BEFORE adding column to table
        for r in 0..<self.csvDataModel.csvData.count//var r = 0; r<self.csvDataModel.csvData.count; r++
        {
            //ADD CORRECT PARAMETER AFTER LOOKUP
            let existingValue = self.csvDataModel.csvData[r][columnIndex]
            // use ?? to ask if lookup gives nil use alternative or if not nil use the lookup. if nil ask if clear or keep existing based on copyUnmatchedValues
            let recodedValue = paramsDict[existingValue] ?? (copyUnmatchedValues == true ? existingValue : "")
            self.csvDataModel.csvData[r].append(recodedValue)
        }
        //add name to headers array
        self.csvDataModel.headers.append(title)
    }
    
    func recodeColumnInSitu(columnToRecode columnIndex:Int, usingParamsArray paramsArray:StringsMatrix2D, copyUnmatchedValues:Bool)
    {
        //make a temporary dictionary
        var paramsDict = CSVdata.paramsDictFromParamsArray(paramsArray)
        
        for r in 0..<self.csvDataModel.csvData.count//var r = 0; r<self.csvDataModel.csvData.count; r++
        {
            //ovewrite CORRECT PARAMETER AFTER LOOKUP or skip
            let existingValue = self.csvDataModel.csvData[r][columnIndex]
            // use ?? to ask if lookup gives nil use alternative or if not nil use the lookup. if nil ask if clear or keep existing based on copyUnmatchedValues
            self.csvDataModel.csvData[r][columnIndex] = paramsDict[existingValue] ?? (copyUnmatchedValues == true ? existingValue : "")

        }
        
    }
    

    func columnsClearAndRebuild(tvCSVdata:NSTableView){
        
        while tvCSVdata.tableColumns.count > 0
        {
            tvCSVdata.removeTableColumn(tvCSVdata.tableColumns.last!)
        }
        for var c = 0; c < self.csvDataModel.numberOfColumnsInData(); c++
        {
            tvCSVdata.addTableColumn(CSVdata.columnWithUniqueIdentifierAndTitle(self.csvDataModel.headers[c]))
            
        }
        tvCSVdata.reloadData()
    }

    func updateCSVTableView()
    {
    }
    
    func requestedColumnIndexIsOK(columnIndex:Int) -> Int?
    {
        return columnIndex >= 0 && columnIndex < self.csvDataModel.numberOfColumnsInData() ? columnIndex : nil
    }

    
    func splitPredicatesByBoolean(predicatesToSplit predicatesToSplit:ArrayOfPredicatesForExtracting)->PredicatesByBoolean
    {
        var splitpreds = PredicatesByBoolean()
        for predicate in predicatesToSplit
        {
            switch predicate.booleanOperator
            {
            case kBooleanStringAND:
                splitpreds.ANDpredicates.append(predicate)
            case kBooleanStringOR:
                splitpreds.ORpredicates.append(predicate)
            case kBooleanStringNOT:
                splitpreds.NOTpredicates.append(predicate)
            default:
                break
            }
        }
        return splitpreds
    }

    
    func extractDataMatrixUsingPredicates(predicates predicates:ArrayOfPredicatesForExtracting)->StringsMatrix2D
    {
        var extractedRows = StringsMatrix2D()
        let predicatesSplitByBoolean = self.splitPredicatesByBoolean(predicatesToSplit: predicates)
        for rowOfColumns in self.csvDataModel.csvData
        {
            //assume row is matched
            var rowMatchedNOT = true
            var rowMatchedAND = true
            var rowMatchedOR = true
            
            // rowOfColumns is a [string] array of row columns
            // the predicate is a [column#][query text] both strings
            
            
            //do NOT first as if just one is matched then we reject the row
            for predicateNOT in predicatesSplitByBoolean.NOTpredicates
            {
                guard let colIndex = self.csvDataModel.columnIndexForHeaderString(predicateNOT.columnNameToMatch) else {print("self.columnIndexForHeaderString(predicateNOT.columnNameToMatch) failed");continue}//should alert here
                if rowOfColumns[colIndex] == predicateNOT.stringToMatch
                {
                    //we break this predicateNOT loop with rowMatched false, as we need to match only one NOT to reject row
                    rowMatchedNOT = false
                }
            }
            
            // if we ended the NOT loop without setting row matched false, and have AND predicates to match
            //do AND next as if just one is unmatched then we reject the row
            if rowMatchedNOT == true && predicatesSplitByBoolean.ANDpredicates.count > 0
            {
                for predicateAND in predicatesSplitByBoolean.ANDpredicates
                {
                    guard let colIndex = self.csvDataModel.columnIndexForHeaderString(predicateAND.columnNameToMatch) else {print("self.columnIndexForHeaderString(predicateAND.columnNameToMatch) failed");continue}//should alert here
                    if rowOfColumns[colIndex] != predicateAND.stringToMatch
                    {
                        //we break this ANDpredicates loop with rowMatched false, as we need to fail only one AND to reject row
                        rowMatchedAND = false
                    }
                }
            }
            
            // if we ended the NOT & AND loops without setting row matched false, and have OR predicates to match
            if rowMatchedNOT == true && rowMatchedAND == true && predicatesSplitByBoolean.ORpredicates.count > 0
            {
                //as we have OR predicates we must flip its value, so any OR can reset to true
                rowMatchedOR = false
                // check ORpredicates, just one true will exit and flip the rowMatched
                for predicateOR in predicatesSplitByBoolean.ORpredicates
                {
                    guard let colIndex = self.csvDataModel.columnIndexForHeaderString(predicateOR.columnNameToMatch) else {print("self.columnIndexForHeaderString(predicateOR.columnNameToMatch) failed");continue}//should alert here
                    if rowOfColumns[colIndex] == predicateOR.stringToMatch
                    {
                        //we break this ORpredicates loop and flip the rowMatchedOR. We only need one OR to accept row
                        rowMatchedOR = true
                        break
                    }
                }
            }
            
            // if we ended the AND and OR loops without setting row matched false, add row
            if rowMatchedNOT && rowMatchedOR && rowMatchedAND
            {
                extractedRows.append(rowOfColumns)
            }
        }
        return extractedRows
    }
    
    func extractRowsBasedOnPredicatesIntoNewFile(predicates predicates:ArrayOfPredicatesForExtracting)
    {
        let extractedData = self.extractDataMatrixUsingPredicates(predicates: predicates)
        if extractedData.count>0
        {
            self.createNewDocumentFromExtractedRows(cvsData: extractedData, headers: nil, name:nil)
        }
        
    }
    
    func createNewDocumentFromRowsInIndexSet(rows rows:NSIndexSet, docName:String)
    {
        self.createNewDocumentFromCVSDataAndColumnName(cvsData: self.csvDataModel.extractTheseRowsFromSelfAsCSVdata(rows: rows), name: docName)
    }
    
    func createNewDocumentFromExtractedRows(cvsData extractedRows:StringsMatrix2D, headers:StringsArray1D?, name: String?)
    {
        do {
            let doc = try NSDocumentController.sharedDocumentController().openUntitledDocumentAndDisplay(true)
            if doc is CSVdataDocument
            {
                let headersOrMyHeaders = headers == nil ? self.csvDataModel.headers : headers! // use my headers if none
                (doc as! CSVdataDocument).csvDataModel = CSVdata(headers: headersOrMyHeaders, csvdata: extractedRows, name:name == nil ? "" : name!)
                (doc as! CSVdataDocument).updateChangeCount(.ChangeDone)
            }
            doc.setDisplayName(name)//setDisplayName handles optionsals OK
        } catch {
            print("Error making new doc")
        }
    }
    
    func createNewDocumentFromCVSDataAndColumnName(cvsData cvsData: CSVdata, name:String)
    {
        do {
            let doc = try NSDocumentController.sharedDocumentController().openUntitledDocumentAndDisplay(true)
            if doc is CSVdataDocument
            {
                doc.setDisplayName(name)
                (doc as! CSVdataDocument).csvDataModel = cvsData
                (doc as! CSVdataDocument).updateChangeCount(.ChangeDone)
            }
        } catch {
            print("Error making new doc")
        }
    }
    
    

}

