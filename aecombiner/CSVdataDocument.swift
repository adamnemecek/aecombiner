//
//  CSVdataDocument.swift
//  aecombiner
//
//  Created by David JM Lewis on 25/06/2015.
//  Copyright (c) 2015 djml.eu. All rights reserved.
//

import Cocoa

let kAscending = 1
let kDescending = 0
let kSortOriginal = -1
let kSortAsText = 0
let kSortAsValue = 1

let kGroupAddition = "Sum"
let kGroupMultiplication = "Factorial"
let kGroupCount = "Count"
let kGroupMean = "Mean"
let kGroupGeoMean = "Geometric Mean"


let kCsvDataData_column_groupingIDs = 0// in a [[String]] of combined CVSdata 0 is the ids and 1 is the data
let kCsvDataData_column_value = 1


func generic_SortArrayOfColumnsAsTextOrValues(inout arrayToSort arrayToSort:DataMatrix, columnIndexToSort:Int, textOrvalue:Int, direction: Int)
{
    switch (direction, textOrvalue)
    {
    case (kAscending,kSortAsValue):
        arrayToSort.sortInPlace {Double($0[columnIndexToSort])>Double($1[columnIndexToSort])}
    case (kDescending,kSortAsValue):
        arrayToSort.sortInPlace {Double($0[columnIndexToSort])<Double($1[columnIndexToSort])}
    case (kAscending,kSortAsText):
        arrayToSort.sortInPlace {($0[columnIndexToSort] as NSString).localizedCaseInsensitiveCompare($1[columnIndexToSort]) == .OrderedAscending}
    case (kDescending,kSortAsText):
        arrayToSort.sortInPlace {($0[columnIndexToSort] as NSString).localizedCaseInsensitiveCompare($1[columnIndexToSort]) == .OrderedDescending}
    default:
        return
    }
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
            self.csvDataModel = CSVdata(dataCSV: data)
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
    
    // MARK: - Data
    func chartDataSetFromColumnIndex(columnIndex columnIndex:Int)->ChartDataSet
    {
        return ChartDataSet(data: self.csvDataModel.csvData, forColumnIndex: columnIndex)
    }

    
    func groupStartValueForString(groupMethod:String) -> Double
    {
        switch groupMethod
        {
        case kGroupAddition, kGroupCount, kGroupMean:
            return 0.0
        case kGroupMultiplication, kGroupGeoMean:
            return 1.0
        default:
            return 0.0
        }

    }
    
    
    func combinedColumnForMeansAndNewColumnName(columnIndexForGrouping columnIndexForGrouping:Int, columnIndexesToGroup: NSIndexSet, arrayOfParamatersInGroup: [String], groupMethod:String) -> (cvsDataData:DataMatrix, nameOfColumn:String)
    {
        let groupStartValue = self.groupStartValueForString(groupMethod)
        //create a dict with the keys the params we extracted for grouping
        //make a blank array to hold the values associated with the grouping for each member of the group
        var dictionaryOfParametersAndCombinedValues = [String : (total:Double, count:Double)]()
        for parameter in arrayOfParamatersInGroup
        {
            dictionaryOfParametersAndCombinedValues[parameter] = (groupStartValue,0.0)
        }
        for row in self.csvDataModel.csvData
        {
            let paramID = row[columnIndexForGrouping]
            for columnIndexInGroup in columnIndexesToGroup
            {
                switch groupMethod
                {
                case kGroupMean:
                    guard let running = dictionaryOfParametersAndCombinedValues[paramID],
                    let value = Double(row[columnIndexInGroup]) else {continue}
                    dictionaryOfParametersAndCombinedValues[paramID] = (running.total + value, running.count + 1.0)
                case kGroupGeoMean:
                    guard let running = dictionaryOfParametersAndCombinedValues[paramID],
                    let  value = Double(row[columnIndexInGroup]) where value > 0 else {continue} //geo mean cannot handle negative numbers or zero
                    dictionaryOfParametersAndCombinedValues[paramID] = (running.total * value, running.count + 1.0)
               default:
                    break
                }
            }
        }
        
        //reprocess dict with the calculated value
        var processedDict = [String : Double]()
        for (key,value) in dictionaryOfParametersAndCombinedValues
        {
            switch groupMethod
            {
            case kGroupMean:
                processedDict[key] = value.total/value.count
            case kGroupGeoMean:
                processedDict[key] = pow(value.total, (1.0/value.count))
            default:
                break
            }

        }
        
        let nameOfNewColumn = self.nameForColumnsUsingGroupMethod(columnIndexesToGroup: columnIndexesToGroup, groupMethod: groupMethod)
        
        //createTheCSVdata
        var csvDataData = DataMatrix()
        for (parameter,value) in processedDict
        {
            csvDataData.append([parameter, String(value)])
        }
        
        return (csvDataData, nameOfNewColumn)

    }
    
    func nameForColumnsUsingGroupMethod(columnIndexesToGroup columnIndexesToGroup: NSIndexSet, groupMethod:String)->String
    {
        //join col names to make a mega name for the combination
        //make an array first
        var namesOfCombinedColumn = HeadersMatrix()
        for columnIndex in columnIndexesToGroup
        {
            namesOfCombinedColumn.append(self.csvDataModel.headers[columnIndex])
        }
        //join the array members with the correct maths symbol
        var nameOfNewColumn:String = ""
        switch groupMethod
        {
        case kGroupAddition:
            nameOfNewColumn = "Sum("+"+".join(namesOfCombinedColumn)+")"
        case kGroupMultiplication:
            nameOfNewColumn = "Factorial("+"*".join(namesOfCombinedColumn)+")"
        case kGroupCount:
            nameOfNewColumn = "Count("+"_".join(namesOfCombinedColumn)+")"
        case kGroupMean:
            nameOfNewColumn = "Mean("+"+".join(namesOfCombinedColumn)+")"
        case kGroupGeoMean:
            nameOfNewColumn = "GeoMean("+"*".join(namesOfCombinedColumn)+")"
        default:
            nameOfNewColumn = "?".join(namesOfCombinedColumn)
        }
        return nameOfNewColumn
    }
    
    
    func combinedColumnsAndNewColumnName(columnIndexForGrouping columnIndexForGrouping:Int, columnIndexesToGroup: NSIndexSet, arrayOfParamatersInGroup: [String], groupMethod:String) -> (cvsDataData:DataMatrix, nameOfColumn:String)
    {
        guard groupMethod != kGroupMean && groupMethod != kGroupGeoMean
            else {return self.combinedColumnForMeansAndNewColumnName(columnIndexForGrouping: columnIndexForGrouping, columnIndexesToGroup: columnIndexesToGroup, arrayOfParamatersInGroup: arrayOfParamatersInGroup, groupMethod: groupMethod)}
        
        
        let groupStartValue = self.groupStartValueForString(groupMethod)
        //create a dict with the keys the params we extracted for grouping
        //make a blank array to hold the values associated with the grouping for each member of the group
        //Doubles for adding and multiplying, Ints for counting - to avoud decimal places in counts string
        var dictionaryOfParametersAndCombinedValues = [String : Double]()
        var dictionaryOfParametersAndCounts = [String : Int]()
        switch groupMethod
        {
        case kGroupAddition, kGroupMultiplication:
            for parameter in arrayOfParamatersInGroup
            {
                dictionaryOfParametersAndCombinedValues[parameter] = groupStartValue
            }
        case kGroupCount:
            for parameter in arrayOfParamatersInGroup
            {
                dictionaryOfParametersAndCounts[parameter] = Int(groupStartValue)
            }
        default:
            break
        }

        for row in self.csvDataModel.csvData
        {
            let paramID = row[columnIndexForGrouping]
            for columnIndexInGroup in columnIndexesToGroup
            {
                switch groupMethod
                {
                case kGroupAddition:
                    guard let running = dictionaryOfParametersAndCombinedValues[paramID],
                    let value = Double(row[columnIndexInGroup]) else {continue}
                    dictionaryOfParametersAndCombinedValues[paramID] = running + value
                case kGroupMultiplication:
                    guard let running = dictionaryOfParametersAndCombinedValues[paramID],
                    let value = Double(row[columnIndexInGroup]) else {continue}
                    dictionaryOfParametersAndCombinedValues[paramID] = running * value
                case kGroupCount:
                    guard let running = dictionaryOfParametersAndCounts[paramID] else {continue}
                    dictionaryOfParametersAndCounts[paramID] = running + 1
                default:
                    break
                }
            }
        }
        
        let nameOfNewColumn = self.nameForColumnsUsingGroupMethod(columnIndexesToGroup: columnIndexesToGroup, groupMethod: groupMethod)
        
        //createTheCSVdata
        var csvDataData = DataMatrix()
        switch groupMethod
        {
        case kGroupAddition, kGroupMultiplication:
            for (parameter,value) in dictionaryOfParametersAndCombinedValues
            {
                csvDataData.append([parameter, String(value)])
            }
        case kGroupCount:
            for (parameter,value) in dictionaryOfParametersAndCounts
            {
                csvDataData.append([parameter, String(value)])
            }
        default:
            break
        }
        
        
        return (csvDataData, nameOfNewColumn)
    }
    
    func combineColumnsAndExtractToNewDocument(columnIndexForGrouping columnIndexForGrouping:Int, columnIndexesToGroup: NSIndexSet, arrayOfParamatersInGroup: [String], groupMethod:String)
    {
        //extract the rows and present
        let combinedDataAndName = self.combinedColumnsAndNewColumnName(columnIndexForGrouping: columnIndexForGrouping, columnIndexesToGroup: columnIndexesToGroup, arrayOfParamatersInGroup: arrayOfParamatersInGroup, groupMethod: groupMethod)
        self.createNewDocumentFromExtractedRows(cvsData: combinedDataAndName.cvsDataData, headers: [self.csvDataModel.headers[columnIndexForGrouping],combinedDataAndName.nameOfColumn])
    }
    
    
    func numberOfRowsOfData()->Int
    {
        return self.csvDataModel.csvData.count
    }
    
    func numberOfColumnsInData()->Int{
        return self.csvDataModel.headers.count
    }
    
    func deletedColumnAtIndex(columnIndex: Int)->Bool
    {
        guard columnIndex >= 0 && columnIndex < self.numberOfColumnsInData() else {return false}
        
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

    func addRecodedColumn(withTitle title:String, fromColum columnIndex:Int, usingParamsArray paramsArray:DataMatrix)
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
        col.sortDescriptorPrototype = NSSortDescriptor(key: nil, ascending: true)

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

    func updateCSVTableView()
    {
    }
    
    func requestedColumnIndexIsOK(columnIndex:Int) -> Bool
    {
        return columnIndex >= 0 && columnIndex < self.numberOfColumnsInData()
    }

    func sortCSVrowsInColumnAsTextOrValues(columnIndexToSort columnIndexToSort:Int, textOrvalue:Int, direction: Int)
    {
        generic_SortArrayOfColumnsAsTextOrValues(arrayToSort: &self.csvDataModel.csvData, columnIndexToSort: columnIndexToSort, textOrvalue: textOrvalue, direction: direction)
    }

    func dataModelExtractedWithPredicates(ANDpredicates ANDpredicates:DataMatrix, ORpredicates:DataMatrix)->DataMatrix
    {
        var extractedRows = DataMatrix()
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
        return extractedRows
    }
    
    func extractRowsBasedOnPredicatesIntoNewFile(ANDpredicates ANDpredicates:DataMatrix, ORpredicates:DataMatrix)
    {
        let extractedData = self.dataModelExtractedWithPredicates(ANDpredicates: ANDpredicates, ORpredicates: ORpredicates)
        if extractedData.count>0
        {
            self.createNewDocumentFromExtractedRows(cvsData: extractedData, headers: self.csvDataModel.headers)
        }
        
    }
    
    func createNewDocumentFromExtractedRows(cvsData extractedRows:DataMatrix, headers:HeadersMatrix)
    {
        do {
            let doc = try NSDocumentController.sharedDocumentController().openUntitledDocumentAndDisplay(true)
            if doc is CSVdataDocument
            {
                (doc as! CSVdataDocument).csvDataModel = CSVdata(headers: headers, csvdata: extractedRows)
                (doc as! CSVdataDocument).updateChangeCount(.ChangeDone)
            }
        } catch {
            print("Error making new doc")
        }
    }

    func setOfParametersFromColumn(fromColumn columnIndex:Int)->Set<String>?
    {
        var set = Set<String>()
        for parameter in self.csvDataModel.csvData
        {
            // parameter is a [string] array of row columns
            set.insert(parameter[columnIndex])
        }
        return set.count == 0 ? nil : set
    }

    func headerStringForColumnIndex(columnIndex:Int?) -> String
    {
        guard let index = columnIndex where columnIndex >= 0 && columnIndex < self.numberOfColumnsInData() else {return "???"}
        return (self.csvDataModel.headers[index])
    }
    


}

