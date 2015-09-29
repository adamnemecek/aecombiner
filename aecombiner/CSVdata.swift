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
typealias MulticolumnStringsArray = [[String]]
typealias SingleColumnStringsArray = [String]
typealias ParamsDictionary = [String : String]


struct NamedDataMatrix
{
    var matrixOfData: MulticolumnStringsArray
    var nameOfData: String
    init ()
    {
        matrixOfData = MulticolumnStringsArray()
        nameOfData = ""
    }
    init (matrix:MulticolumnStringsArray, name:String)
    {
        matrixOfData = matrix
        nameOfData = name
    }
}


class CSVdata {

    var headers:SingleColumnStringsArray// = SingleColumnStringsArray()
    var csvData:MulticolumnStringsArray// = MulticolumnStringsArray()
    var processedDataOK:Bool// = false
    var name:String// = ""
    
    init()
    {
        self.headers = SingleColumnStringsArray()
        self.csvData = MulticolumnStringsArray()
        self.processedDataOK = false
        self.name = ""
    }
    
    convenience init (headers:SingleColumnStringsArray, csvdata:MulticolumnStringsArray, name:String)
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
    
    func importCSVstring(dataAsString dataAsString:NSString, name:String)
    {
        var arrayOfRowArrays = MulticolumnStringsArray()
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
                arrayOfRowArrays.append(subStrings.joinWithSeparator(quotationMarksReplacement).componentsSeparatedByString(commaDelimiter))
            }
            else
            {
                arrayOfRowArrays.append(line.componentsSeparatedByString(commaDelimiter))
            }
        })
        if arrayOfRowArrays.count > 0
        {
            self.headers = arrayOfRowArrays[0]
            arrayOfRowArrays.removeAtIndex(0)
            self.csvData = arrayOfRowArrays
            self.processedDataOK = true
            self.name = name
        }
    }
    
    func importTABstring(dataAsString dataAsString:NSString, name:String)
    {
        var arrayOfRowArrays = MulticolumnStringsArray()
        dataAsString.enumerateLinesUsingBlock({ (line, okay) -> Void in
            // we dont check for tabs inside quotes
            arrayOfRowArrays.append(line.componentsSeparatedByString(tabDelimiter))
        })
        if arrayOfRowArrays.count > 0
        {
            self.headers = arrayOfRowArrays[0]
            arrayOfRowArrays.removeAtIndex(0)
            self.csvData = arrayOfRowArrays
            self.processedDataOK = true
            self.name = name
        }
    }

    func processCSVtoData(delimiter delimiter:String) -> NSData?
    {
        var tempArray = SingleColumnStringsArray()
        for var row = 0; row<self.csvData.count; row++
        {
            let rowString = self.csvData[row].joinWithSeparator(delimiter)
            tempArray.append(rowString)
        }
        tempArray.insert(self.headers.joinWithSeparator(delimiter), atIndex: 0)
        let fileString = tempArray.joinWithSeparator(carriageReturn)
        return fileString.dataUsingEncoding(NSUTF8StringEncoding)
    }

    func extractTheseRowsFromSelfAsCSVdata(rows rows:NSIndexSet)->CSVdata
    {
        var extractedRows = MulticolumnStringsArray()
        let numRows = self.csvData.count
        for rowIndex in rows
        {
            guard rowIndex<numRows else {continue}
            extractedRows.append(self.csvData[rowIndex])
        }
        return CSVdata(headers: self.headers, csvdata: extractedRows, name:"")
    }
        
    class func extractTheseRowsFromDataMatrixAsDataMatrix(rows rows:NSIndexSet, datamatrix:MulticolumnStringsArray)->MulticolumnStringsArray
    {
        var extractedRows = MulticolumnStringsArray()
        let numRows = datamatrix.count
        for rowIndex in rows
        {
            guard rowIndex<numRows else {continue}
            extractedRows.append(datamatrix[rowIndex])
        }
        return extractedRows
    }

    func singleColumnStringsArrayOfParametersFromColumn(fromColumn columnIndex:Int, replaceBlank:Bool)->SingleColumnStringsArray?
    {
        guard
            let validCI = self.validatedColumnIndex(columnIndex)
            else {return nil}
        var set = SetOfStrings()
        for row in self.csvData
        {
            // parameter is a [string] array of row columns
            set.insert(row[validCI])
        }
        if replaceBlank == true
        {
            if set.remove("") != nil
            {
                set.insert(kStringEmpty)
            }
        }
        return Array(set)
    }
    

    func dataMatrixOfParametersFromColumn(fromColumn columnIndex:Int)->MulticolumnStringsArray?
    {
        guard  let validCI = self.validatedColumnIndex(columnIndex) else {return nil}
        
        var set = SetOfStrings()
        for row in self.csvData
        {
            // parameter is a [string] array of row columns
            set.insert(row[validCI])
        }
        return set.count == 0 ? nil : CSVdata.dataMatrixWithNoBlanksFromSet(set: set)
    }
    
    class func dataMatrixWithNoBlanksFromSet(set set:SetOfStrings)->MulticolumnStringsArray
    {
        var subArray = Array(set)
        // replace blanks with string
        for var c=0;c < subArray.count; ++c
        {
            if subArray[c].isEmpty
            {
                subArray[c] = kStringEmpty
            }
        }
        
        var matrix = MulticolumnStringsArray()
        for var row = 0; row<subArray.count; ++row
        {
            matrix.append(CSVdata.makeParamValueBool(param: subArray[row]))
        }
        
        return matrix
    }
    
    class func makeParamValueBool(param param: String)->SingleColumnStringsArray
    {
        return [param,"","true"]
    }
    
    func setOfParametersFromColumnIfStringMatchedInColumn(fromColumn fromColumn:Int, matchString:String, matchColumn:Int)->SetOfStrings?
    {
        guard  let validFromC = self.validatedColumnIndex(fromColumn),
                let validMatchC = self.validatedColumnIndex(matchColumn)
            else {return nil}
        var set = SetOfStrings()
        for parameter in self.csvData
        {
            // parameter is a [string] array of row columns
            if parameter[validMatchC] == matchString
            {
                set.insert(parameter[validFromC])
            }
        }
        return set.count == 0 ? nil : set
    }

    class func createParamsDictFromParamsArray(paramsArray:MulticolumnStringsArray)->ParamsDictionary
    {
        //make a temporary dictionary
        var paramsDict = ParamsDictionary()
        for paramNameAndValueArray in paramsArray
        {
            paramsDict[paramNameAndValueArray[kParametersArray_ParametersIndex]] = paramNameAndValueArray[kParametersArray_ValueIndex]
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
                columnIndex < self.csvData[0].count
            else {return nil}
        return columnIndex
    }
    

    func numberOfColumnsInData()->Int{
        return self.headers.count
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

}
