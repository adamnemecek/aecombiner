//
//  CSVdata.swift
//  aecombiner
//
//  Created by David Lewis on 28/06/2015.
//  Copyright (c) 2015 djml.eu. All rights reserved.
//

import Cocoa

let quotationMarks = "\""
let quotationMarksReplacement = ""
let commaReplacement = "‚"//,
let commaDelimiter = ","
let carriageReturn = "\n"
let tabDelimiter = "\t"

typealias SetOfStrings = Set<String>
typealias StringsMatrix2D = [[String]]
typealias StringsArray1D = [String]
typealias ParamsDictionary = [String : String]


struct NamedDataMatrix
{
    var matrixOfData: StringsMatrix2D
    var nameOfData: String
    init ()
    {
        matrixOfData = StringsMatrix2D()
        nameOfData = ""
    }
    init (matrix:StringsMatrix2D, name:String)
    {
        matrixOfData = matrix
        nameOfData = name
    }
}


class CSVdata {

    var headers:StringsArray1D// = StringsArray1D()
    var csvData:StringsMatrix2D// = StringsMatrix2D()
    var processedDataOK:Bool// = false
    var name:String// = ""
    
    init()
    {
        self.headers = StringsArray1D()
        self.csvData = StringsMatrix2D()
        self.processedDataOK = false
        self.name = ""
    }
    
    convenience init (headers:StringsArray1D, csvdata:StringsMatrix2D, name:String)
    {
        self.init()
        self.headers = headers
        self.csvData = csvdata
        self.name = name
        processedDataOK = true
    }
    
    convenience init (dataCSV: NSData, name:String)
    {
        self.init()
        guard let dataAsString = NSString(data: dataCSV, encoding: NSUTF8StringEncoding) else {return}
        self.importCSVstring(dataAsString: dataAsString, name:name)
    }
    
    convenience init (dataTAB: NSData, name:String)
    {
        self.init()
        guard let dataAsString = NSString(data: dataTAB, encoding: NSUTF8StringEncoding) else {return}
        self.importTABstring(dataAsString: dataAsString, name:name)
    }
    
    convenience init (stringTAB: NSString, name:String)
    {
        self.init()
        self.importTABstring(dataAsString: stringTAB, name:name)
    }
    
    func appendThisRowToColumnsInArray(inout arrayOfColumns arrayOfColumns:StringsMatrix2D, rowArray:StringsArray1D)
    {
        switch arrayOfColumns.count
        {
        case 0: //we have to initiate things. use the headers,  put in the array for now
            self.headers = rowArray
            for col in 0..<rowArray.count
            {
                arrayOfColumns.append([rowArray[col]])
            }

        default:
            for col in 0..<rowArray.count
            {
                arrayOfColumns[col].append(rowArray[col])
            }
        }
        
    }
    
    
    
    
    class func columnWithUniqueIdentifierAndTitle(title:String)->NSTableColumn
    {
        let col =  NSTableColumn(identifier:String(NSDate().timeIntervalSince1970))
        col.title = title
        col.sortDescriptorPrototype = NSSortDescriptor(key: nil, ascending: true)
        
        return col
    }

    
    class func removeHeadersFromColumnArray(inout arrayOfColumns arrayOfColumns:StringsMatrix2D)
    {
        for col in 0..<arrayOfColumns.count
        {
            arrayOfColumns[col].removeAtIndex(0)
        }

    }
    
    func postProcessCSVdataMatrix(inout arrayOfColumns arrayOfColumns:StringsMatrix2D)
    {
        CSVdata.removeHeadersFromColumnArray(arrayOfColumns: &arrayOfColumns)
        self.csvData = arrayOfColumns
        self.processedDataOK = true
    }
    
    func importCSVstring(dataAsString dataAsString:NSString, name:String)
    {
        var arrayOfColumnArrays = StringsMatrix2D()// [col num][row num]
        dataAsString.enumerateLinesUsingBlock({ (line, okay) -> Void in
            //check for "" and replace , inside them
            if line.rangeOfString(quotationMarks) != nil
            {
                // ‚
                var subStrings = line.componentsSeparatedByString(quotationMarks)
                // we assume the file is properly formed with "" in pairs
                //odd indexed substrings are the substrings between "", even substrings are OUTSIDE the ""
                // empty strings used to pad start and end
                //replace , with special , inside the ''
                for var substringIndex=1; substringIndex < subStrings.count; substringIndex += 2
                {
                    subStrings[substringIndex] = subStrings[substringIndex].stringByReplacingOccurrencesOfString(commaDelimiter, withString: commaReplacement)
                }
                let newRow = (subStrings.joinWithSeparator(quotationMarksReplacement).componentsSeparatedByString(commaDelimiter))
                self.appendThisRowToColumnsInArray(arrayOfColumns: &arrayOfColumnArrays , rowArray: newRow)
            }
            else
            {
                let newRow = (line.componentsSeparatedByString(commaDelimiter))
                self.appendThisRowToColumnsInArray(arrayOfColumns: &arrayOfColumnArrays , rowArray: newRow)
          }
        })
        if arrayOfColumnArrays.count > 0
        {
            self.postProcessCSVdataMatrix(arrayOfColumns: &arrayOfColumnArrays)
            self.name = name
        }
    }
    
    func importTABstring(dataAsString dataAsString:NSString, name:String)
    {
        var arrayOfColumnArrays = StringsMatrix2D()
        dataAsString.enumerateLinesUsingBlock({ (line, okay) -> Void in
            // we dont check for tabs inside quotes
            let newRow = (line.componentsSeparatedByString(tabDelimiter))
            self.appendThisRowToColumnsInArray(arrayOfColumns: &arrayOfColumnArrays , rowArray: newRow)
        })
        if arrayOfColumnArrays.count > 0
        {
            self.postProcessCSVdataMatrix(arrayOfColumns: &arrayOfColumnArrays)
            self.name = name
        }
    }

    func processCSVtoData(delimiter delimiter:String) -> NSData?
    {
        guard self.numberOfColumnsInData() > 0 else {return nil}
        
        var tempDataArray = StringsArray1D()
        //add headers string
        tempDataArray.append(self.headers.joinWithSeparator(delimiter))
        //build the rows strings one by one and append
        for rowN in 0..<self.csvData[0].count//hope we have same number of rows in each col!
        {
            var tempRowArray = StringsArray1D()
            for colNo in 0..<self.numberOfColumnsInData()
            {
                let valS = self.csvData[colNo][rowN]
                tempRowArray.append(valS)
            }
            tempDataArray.append(tempRowArray.joinWithSeparator(delimiter))
        }
        
        let fileString = tempDataArray.joinWithSeparator(carriageReturn)
        return fileString.dataUsingEncoding(NSUTF8StringEncoding)
    }

    func extractTheseRowsFromSelfAsCSVdata(rows rows:NSIndexSet)->CSVdata
    {
        guard self.numberOfColumnsInData() > 0 else {return CSVdata()}
        
        let extractedRows = CSVdata.extractTheseRowsFromDataMatrixAsDataMatrix(rows: rows, datamatrix: self.csvData)
        return CSVdata(headers: self.headers, csvdata: extractedRows, name:"")
    }
        
    class func extractTheseRowsFromDataMatrixAsDataMatrix(rows rows:NSIndexSet, datamatrix:StringsMatrix2D)->StringsMatrix2D
    {
        guard datamatrix.count  > 0 else {return StringsMatrix2D()}
        
        let numCols = datamatrix.count
        let numRows = datamatrix[0].count
        var extractedRows = StringsMatrix2D()
        for rowIndex in rows
        {
            guard rowIndex<numRows else {continue}
            var tempRow = StringsArray1D()
            for colIndex in 0..<numCols
            {
                tempRow.append(datamatrix[colIndex][rowIndex])
            }
            extractedRows.append(tempRow)
        }

        return extractedRows
    }
    
    
    func setOfParametersFromColumn(fromColumn columnIndex:Int, replaceBlank:Bool)->SetOfStrings?
    {
        guard let validCI = self.validatedColumnIndex(columnIndex) else {return nil}
        var set = SetOfStrings()
        for rowN in 0..<self.csvData[validCI].count
        {
            // parameter is a [string] array of row columns
            set.insert(self.csvData[validCI][rowN])
        }
        if replaceBlank == true
        {
            if set.remove("") != nil
            {
                set.insert(kStringEmpty)
            }
        }
        return set
    }

    func StringsArray1DOfParametersFromColumn(fromColumn columnIndex:Int, replaceBlank:Bool)->StringsArray1D?
    {
        guard let set = self.setOfParametersFromColumn(fromColumn: columnIndex, replaceBlank: replaceBlank) else {return nil}
        
        return Array(set)
    }
    

    func dataMatrixOfParametersFromColumn(fromColumn columnIndex:Int)->StringsMatrix2D?
    {
        guard let set = self.setOfParametersFromColumn(fromColumn: columnIndex, replaceBlank: false) else {return nil}
            //bit dumb we say replaceBlank: false and then do indataMatrixWithNoBlanksFromSet
        
        return set.count == 0 ? nil : CSVdata.dataMatrixWithNoBlanksFromSet(set: set)
    }
    
    class func dataMatrixWithNoBlanksFromSet(var set set:SetOfStrings)->StringsMatrix2D
    {
        if set.remove("") != nil
        {
            set.insert(kStringEmpty)
        }

        var subArray = Array(set)
        
        var matrix = StringsMatrix2D()
        for row in 0..<subArray.count
        {
            matrix.append(CSVdata.makeParamValueBool(param: subArray[row]))
        }
        
        return matrix
    }
    
    class func makeParamValueBool(param param: String)->StringsArray1D
    {
        return [param,"",String(NSOnState)]
    }
    
    func setOfParametersFromColumnIfStringMatchedInColumn(fromColumn fromColumn:Int, matchString:String, matchColumn:Int)->SetOfStrings?
    {
        guard
            let validFromC = self.validatedColumnIndex(fromColumn),
            let validMatchC = self.validatedColumnIndex(matchColumn)
            else {return nil}
        guard numberOfRowsInData() > 0 else {return nil}
        
        var set = SetOfStrings()
        for rowN in 0..<self.csvData[validMatchC].count
        {
            if self.csvData[validMatchC][rowN] == matchString
            {
                set.insert(self.csvData[validFromC][rowN])
            }
        }
        
        return set.count == 0 ? nil : set
    }

    class func doRecodeThisParam(param param:StringsArray1D)->Bool{
        return NSCellStateValue(param[kParametersArray_BooleanIndex]) == NSOnState
    }
    
    class func createParamsDictFromParamsArray(paramsArray:StringsMatrix2D)->ParamsDictionary
    {
        //make a temporary dictionary
        var paramsDict = ParamsDictionary()
        for paramNameValueBool in paramsArray where self.doRecodeThisParam(param: paramNameValueBool)
        {
            paramsDict[paramNameValueBool[kParametersArray_ParametersIndex]] = paramNameValueBool[kParametersArray_ValueIndex]
        }
        
        //need to strip out kStringEmpty
        let blankval = paramsDict.removeValueForKey(kStringEmpty)
        if blankval != nil
        {
            paramsDict[""] = blankval
        }
        return paramsDict
    }
    

    // MARK: - Headers
    func validatedColumnIndex(columnIndex:Int)->Int?
    {
        guard
            self.csvData.count>0 &&
                columnIndex >= 0 &&
                columnIndex < self.numberOfColumnsInData()
            else {return nil}
        return columnIndex
    }
    
    func validatedRowIndex(rowIndex:Int)->Int?
    {
        guard
            self.csvData.count>0 &&
                rowIndex >= 0 &&
                rowIndex < self.numberOfRowsInData()
            else {return nil}
        return rowIndex
    }
    

    func numberOfColumnsInData()->Int{
        return self.headers.count
    }
    
    func numberOfRowsInData()->Int{
        guard self.csvData.count > 0 else {return 0}
        return self.csvData[0].count
        // just hope all cols same length
    }
    
    func headerStringsForAllColumns()->[String]
    {
        return self.headers
    }
    
    func headerStringForColumnIndex(columnIndex:Int) -> String
    {
        guard let index = self.validatedColumnIndex(columnIndex) else {return "???"}
        return (self.headers[index])
    }
    
    func renameColumnAtIndex(columnIndex columnIndex: Int, newName:String)
    {
        guard !newName.isEmpty else {return}
        guard let index = self.validatedColumnIndex(columnIndex) else {return}
        self.headers[index] = newName
    }

    func columnIndexForHeaderString(headerString:String)->Int?
    {
        return self.headers.indexOf(headerString)
    }
    
    func checkedExtractingPredicatesArray(arrayToCheck:ArrayOfPredicatesForExtracting)->ArrayOfPredicatesForExtracting
    {
        var checkedArray = ArrayOfPredicatesForExtracting()
        for var predicate in arrayToCheck
        {
            guard (self.headers.indexOf(predicate.columnNameToMatch) == nil) else {checkedArray.append(predicate); continue}
            predicate.columnNameToMatch = "⚠️ "+predicate.columnNameToMatch
            checkedArray.append(predicate)
        }
        return checkedArray
    }

    func cellForHeadersTable(tableView tableView: NSTableView, row: Int) ->NSTableCellView
    {
        let cellView = tableView.makeViewWithIdentifier("headersCell", owner: self) as! NSTableCellView
        cellView.textField!.stringValue = self.headerStringForColumnIndex(row)
        return cellView
    }

    func stringValueForCell(fromColumn fromColumn:Int, atRow:Int)->String
    {
        guard
            let validCI = self.validatedColumnIndex(fromColumn),
            let validRI = self.validatedRowIndex(atRow)
            else {return ""}
        
        return self.csvData[validCI][validRI]
        
    }
    

    // MARK: - Grouping Combining
    class func groupStartValueForString(groupMethod:String) -> Double
    {
        switch groupMethod
        {
        case kGroupAddition, kGroupLogSum, kGroupCount, kGroupMean, kGroupGeoMean, kGroupMax:
            return 0.0
        case kGroupMin:
            return Double(Int.max)
        case kGroupMultiplication:
            return 1.0
        default:
            return 0.0
        }
        
    }
    
    func nameForColumnsUsingGroupMethod(columnIndexesToGroup columnIndexesToGroup: NSIndexSet, groupMethod:String)->String
    {
        //join col names to make a mega name for the combination
        //make an array first
        var namesOfCombinedColumn = StringsArray1D()
        for columnIndex in columnIndexesToGroup
        {
            namesOfCombinedColumn.append(self.headers[columnIndex])
        }
        //join the array members with the correct maths symbol
        var nameOfNewColumn:String = ""
        switch groupMethod
        {
        case kGroupAddition:
            nameOfNewColumn = "Sum("+namesOfCombinedColumn.joinWithSeparator("+")+")"
        case kGroupLogSum:
            nameOfNewColumn = "Log Sum("+namesOfCombinedColumn.joinWithSeparator("+")+")"
        case kGroupMultiplication:
            nameOfNewColumn = "Product("+namesOfCombinedColumn.joinWithSeparator("*")+")"
        case kGroupCount:
            nameOfNewColumn = "Count("+namesOfCombinedColumn.joinWithSeparator("_")+")"
        case kGroupMean:
            nameOfNewColumn = "Mean("+namesOfCombinedColumn.joinWithSeparator("+")+")"
        case kGroupGeoMean:
            nameOfNewColumn = "GeoMean("+namesOfCombinedColumn.joinWithSeparator("_")+")"
        case kGroupMin:
            nameOfNewColumn = "Min("+namesOfCombinedColumn.joinWithSeparator("_")+")"
        case kGroupMax:
            nameOfNewColumn = "Max("+namesOfCombinedColumn.joinWithSeparator("_")+")"
        case kGroupRange:
            nameOfNewColumn = "Range("+namesOfCombinedColumn.joinWithSeparator("_")+")"
        case kGroupLogRange:
            nameOfNewColumn = "Log Range("+namesOfCombinedColumn.joinWithSeparator("_")+")"
        case kGroupAllStats:
            nameOfNewColumn = namesOfCombinedColumn.joinWithSeparator("_")
        default:
            nameOfNewColumn = namesOfCombinedColumn.joinWithSeparator("?")
        }
        return nameOfNewColumn
    }

    func combinedColumnForMeansAndNewColumnName(columnIndexForGrouping columnIndexForGrouping:Int, columnIndexesToGroup: NSIndexSet, arrayOfParamatersInGroup:StringsArray1D , groupMethod:String) -> NamedDataMatrix//(csvDataMatrix:StringsMatrix2D, nameOfColumn:String)
    {
        let groupStartValue = CSVdata.groupStartValueForString(groupMethod)
        //create a dict with the keys the params we extracted for grouping
        //make a blank array to hold the values associated with the grouping for each member of the group
        var valuesForGroup = [String : (total:Double, count:Double)]()
        var rangesForGroup = [String : (minm:Double, maxm:Double)]()
        switch groupMethod
        {
        case kGroupMean, kGroupGeoMean:
            for parameter in arrayOfParamatersInGroup
            {
                valuesForGroup[parameter] = (groupStartValue,0.0)
            }
        case kGroupRange, kGroupLogRange:
            for parameter in arrayOfParamatersInGroup
            {
                rangesForGroup[parameter] = (CSVdata.groupStartValueForString(kGroupMin),CSVdata.groupStartValueForString(kGroupMax))
            }
        default:
            break
        }
        
        for row in 0..<self.numberOfRowsInData()
        {
            let paramID = self.stringValueForCell(fromColumn: columnIndexForGrouping, atRow: row)
            for columnIndexInGroup in columnIndexesToGroup
            {
                let rowValS = self.stringValueForCell(fromColumn: columnIndexInGroup, atRow: row)
                switch groupMethod
                {
                case kGroupRange, kGroupLogRange:
                    guard let running = rangesForGroup[paramID],
                        let value = Double(rowValS) else {continue}
                    rangesForGroup[paramID] = (fmin(running.minm, value), fmax(running.maxm,value))
                case kGroupMean:
                    guard let running = valuesForGroup[paramID],
                        let value = Double(rowValS) else {continue}
                    valuesForGroup[paramID] = (running.total + value, running.count + 1.0)
                case kGroupGeoMean:
                    guard let running = valuesForGroup[paramID],
                        let  value = Double(rowValS) where value > 0 else {continue} //geo mean cannot handle negative numbers
                    valuesForGroup[paramID] = (running.total +  log(value), running.count + 1.0)
                default:
                    break
                }
            }
        }
        
        //reprocess dict with the calculated value
        var processedDict = [String : Double]()
        
        switch groupMethod
        {
        case kGroupRange:
            for (key,value) in rangesForGroup
            {
                processedDict[key] = value.maxm-value.minm
            }
        case kGroupLogRange:
            for (key,value) in rangesForGroup
            {
                if value.maxm-value.minm > 0
                {
                    processedDict[key] = log(value.maxm-value.minm)
                }
                else
                {
                    processedDict[key] = kSubstituteValueForZeroInLogarithm // arbitrary value - log in user guide
                }
                
            }
        case kGroupMean, kGroupGeoMean:
            for (key,value) in valuesForGroup
            {
                switch groupMethod
                {
                case kGroupMean:
                    processedDict[key] = value.total/value.count
                case kGroupGeoMean:
                    processedDict[key] = exp(value.total/value.count)
                default:
                    break
                }
            }
        default:
            break
        }
        
        
        let nameOfNewColumn = self.nameForColumnsUsingGroupMethod(columnIndexesToGroup: columnIndexesToGroup, groupMethod: groupMethod)
        
        //createTheCSVdata
        var csvDataData = StringsMatrix2D()
        for (parameter,value) in processedDict
        {
            csvDataData.append([parameter, String(value)])
        }
        
        return NamedDataMatrix(matrix:csvDataData, name:nameOfNewColumn)
        
    }

    
    
}
