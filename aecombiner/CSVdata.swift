//
//  CSVdata.swift
//  aecombiner
//
//  Created by David Lewis on 28/06/2015.
//  Copyright (c) 2015 djml.eu. All rights reserved.
//

import Cocoa

enum FileDelimiterType
{
    case CSV// = "CSV"
    case TAB// = "TAB"
}

struct EncodingTypes
{
    static func typesArray()->[UInt]
    {
        return [NSUTF8StringEncoding, NSASCIIStringEncoding,NSWindowsCP1252StringEncoding]
    }
    static func typeNamesArray()->[String]
    {
        return ["NSUTF8StringEncoding","NSASCIIStringEncoding","NSWindowsCP1252StringEncoding"]
    }

    
    static func typeNameFromType(type: UInt)->String
    {
        let a = EncodingTypes.typesArray().indexOf(type)
        return a == nil ? "?encoding" : EncodingTypes.typeNamesArray()[a!]
    }
}



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
typealias LookupDictionary = [String : StringsArray1D]//key ID : array of col data


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

    var headersStringsArray1D:StringsArray1D// = StringsArray1D()
    var dataStringsMatrix2D:StringsMatrix2D// = StringsMatrix2D()
    var processedDataOK:Bool// = false
    var name:String// = ""
    var encodingUsed: UInt?
    
    // MARK: - Init
    init()
    {
        self.headersStringsArray1D = StringsArray1D()
        self.dataStringsMatrix2D = StringsMatrix2D()
        self.processedDataOK = false
        self.name = ""
    }
    
    convenience init (headers:StringsArray1D, csvdata:StringsMatrix2D, name:String)
    {
        self.init()
        self.headersStringsArray1D = headers
        self.dataStringsMatrix2D = csvdata
        self.name = name
        processedDataOK = true
    }
    
    convenience init (singleColumnName:String, singleColumnSetOfData:SetOfStrings)
    {
        self.init()
        self.headersStringsArray1D = [singleColumnName]
        var datamatrix = StringsMatrix2D()
        for param in singleColumnSetOfData
        {
            datamatrix.append([param])
        }
        self.name = singleColumnName
        self.dataStringsMatrix2D = datamatrix
        processedDataOK = true
    }
    
    class func decodeDataToString(data: NSData)->(decodedString: NSString?, encodingUsed:UInt?)
    {
        var dataAsString:NSString?
        for encoding in EncodingTypes.typesArray()
        {
            dataAsString = NSString(data: data, encoding: encoding)
            if dataAsString != nil
            {
                //print(EncodingTypes.typeNameFromType(encoding))
                return (dataAsString,encoding)
            }
        }
        return (nil,nil)

    }
    
    convenience init (data: NSData, name:String, delimiter:FileDelimiterType)
    {
        self.init()
        let tuple = CSVdata.decodeDataToString(data)
        if tuple.decodedString != nil
        {
            self.encodingUsed = tuple.encodingUsed
            switch delimiter
            {
            case .CSV:
                self.importCSVstring(dataAsString: tuple.decodedString!, name:name)
            case .TAB:
                self.importTABstring(dataAsString: tuple.decodedString!, name:name)
            }
        }
    }

    convenience init (stringTAB: NSString, name:String)
    {
        self.init()
        self.importTABstring(dataAsString: stringTAB, name:name)
    }
    
    // MARK: - CLASS
    // MARK: - PVB Params
    
    
    typealias SortedArrayOfIndexes = [Int]
    class func sortedArrayOfIndexesFromNSIndexSet(indexes indexes:NSIndexSet)->SortedArrayOfIndexes
    {
        var sortedArray = SortedArrayOfIndexes()
        for index in indexes
        {
            sortedArray.append(index)
        }
        sortedArray.sortInPlace()
        return sortedArray
    }
    
    class func newParamValueBool(param param: String)->StringsArray1D
    {
        return [param,"",String(NSOnState)]
    }
    
    class func booleanFromParamArray(param param:StringsArray1D)->Bool{
        return NSCellStateValue(param[ParametersValueBoolColumnIndexes.BooleanIndex.rawValue]) == NSOnState
    }
    
    class func paramsDictFromParamsArray(paramsArray:StringsMatrix2D)->ParamsDictionary
    {
        //make a temporary dictionary
        var paramsDict = ParamsDictionary()
        for paramNameValueBool in paramsArray where self.booleanFromParamArray(param: paramNameValueBool)
        {
            paramsDict[paramNameValueBool[ParametersValueBoolColumnIndexes.ParametersIndex.rawValue]] = paramNameValueBool[ParametersValueBoolColumnIndexes.ValueIndex.rawValue]
        }
        
        //need to strip out kStringEmpty
        let blankval = paramsDict.removeValueForKey(kStringEmpty)
        if blankval != nil
        {
            paramsDict[""] = blankval
        }
        return paramsDict
    }
    

    // MARK: - Column

    func notAnEmptyDataSet()->Bool
    {
        return self.numberOfRowsInData() > 0 && self.numberOfColumnsInData() > 0
    }
    
    func numberOfColumnsInData()->Int
    {
        return self.headersStringsArray1D.count
        //self.dataStringsMatrix2D.count
    }
    
    func validatedColumnIndex(columnIndex:Int)->Int?
    {
        guard
            columnIndex >= 0 &&
            columnIndex < self.numberOfColumnsInData()
            else {print("non validatedColumnIndex \(columnIndex)"); return nil}
        return columnIndex
    }
    
    func indexOfColumnWithName(name name:String)->Int?
    {
        return self.headersStringsArray1D.indexOf(name)
    }
    
    func deletedColumnAtIndex(index:Int)->Bool
    {
        guard let validindex = self.validatedColumnIndex(index) else {return false}
        for rowN in 0..<self.numberOfRowsInData()
        {
            self.dataStringsMatrix2D[rowN].removeAtIndex(validindex)
        }
        //remove from headers array
        self.headersStringsArray1D.removeAtIndex(validindex)
        return true
        
    }

    
    func addedRecodedColumnByMathsFunction_ColumnMaths(title title:String, fromColum:Int, mathsColumn:Int, functionString:String, copyUnmatchedValues:Bool)->Bool
    {
        guard
            let fromColumV = self.validatedColumnIndex(fromColum),
            let mathsColumnValid = self.validatedColumnIndex(mathsColumn)
        else {return false}
        
        
        for rowN in 0..<self.numberOfRowsInData()
        {
            guard
                let fromS = self.stringValueForCell(fromColumn: fromColumV, atRow: rowN)
            else {self.dataStringsMatrix2D[rowN].append("Invalid Column To Inspect"); continue}
            guard
                let mathS = self.stringValueForCell(fromColumn: mathsColumnValid, atRow: rowN)
            else {self.dataStringsMatrix2D[rowN].append("Invalid Column To Compare"); continue}
            guard
                var fromD = Double(fromS),
                let mathD = Double(mathS)
            else {self.dataStringsMatrix2D[rowN].append(copyUnmatchedValues ? fromS : ""); continue}
            
            
            switch functionString
            {
            case "+":
                fromD += mathD
            case "-":
                fromD -= mathD
            case "*":
                fromD *= mathD
            case "/":
                fromD /= mathD
            default:
                break
            }
            
            self.dataStringsMatrix2D[rowN].append(String(fromD))

        }

        //add name to headers array
        self.headersStringsArray1D.append(title)

        return true
    }
    
    func addedRecodedColumnByMathsFunction_AbsoluteValue(title title:String, fromColum:Int, absoluteValue:Double, functionString:String, copyUnmatchedValues:Bool)->Bool
    {
        guard let fromColumV = self.validatedColumnIndex(fromColum) else {return false}

        for rowN in 0..<self.numberOfRowsInData()
        {
            guard
                let fromS = self.stringValueForCell(fromColumn: fromColumV, atRow: rowN)
                else {self.dataStringsMatrix2D[rowN].append("Invalid Column To Inspect"); continue}
            guard
                var fromD = Double(fromS)
            else {self.dataStringsMatrix2D[rowN].append(copyUnmatchedValues ? fromS : ""); continue}
            
            
            switch functionString
            {
            case "+":
                fromD += absoluteValue
            case "-":
                fromD -= absoluteValue
            case "*":
                fromD *= absoluteValue
            case "/":
                fromD /= absoluteValue
            default:
                break
            }
            
            self.dataStringsMatrix2D[rowN].append(String(fromD))
            
        }

        //add name to headers array
        self.headersStringsArray1D.append(title)

        return true
    }
    
    func addedRecodedColumnByBooleanCompareWithColumn(title title:String, fromColum:Int, compareColumn:Int, booleanString:String, replacementString:String, copyUnmatchedValues:Bool)->Bool
    {
        guard
            let fromColumV = self.validatedColumnIndex(fromColum),
            let compareColumnV = self.validatedColumnIndex(compareColumn)
        else {return false}
        

        for rowN in 0..<self.numberOfRowsInData()
        {
            guard
                let fromS = self.stringValueForCell(fromColumn: fromColumV, atRow: rowN)
            else {self.dataStringsMatrix2D[rowN].append("Invalid Column To Inspect"); continue}
            guard
                let compS = self.stringValueForCell(fromColumn: compareColumnV, atRow: rowN)
            else {self.dataStringsMatrix2D[rowN].append("Invalid Column To Compare"); continue}
            guard
                let fromD = Double(fromS),
                let compD = Double(compS)
            else {self.dataStringsMatrix2D[rowN].append(""); continue}
            
            let pred = NSPredicate(format: "SELF"+booleanString+"%@",NSNumber(double: compD))
            if pred.evaluateWithObject(NSNumber(double: fromD)) == true
            {
                self.dataStringsMatrix2D[rowN].append(replacementString)
            }
            else
            {
                self.dataStringsMatrix2D[rowN].append(copyUnmatchedValues ? fromS : "")
            }
        }
        
        //add name to headers array
        self.headersStringsArray1D.append(title)

        return true
    }
    
    func addedRecodedColumn(title title:String, fromColum columnIndex:Int, usingParamsArray paramsArray:StringsMatrix2D, copyUnmatchedValues:Bool)->Bool
    {
        guard let validCI = self.validatedColumnIndex(columnIndex) else {return false}
        
        //make a temporary dictionary
        var paramsDict = CSVdata.paramsDictFromParamsArray(paramsArray)
        // must add the column to Array BEFORE adding column to table
        for row in 0..<self.numberOfRowsInData()
        {
            //ADD CORRECT PARAMETER AFTER LOOKUP
            let existingValue = self.dataStringsMatrix2D[row][validCI]
            // use ?? to ask if lookup gives nil use alternative or if not nil use the lookup. if nil ask if clear or keep existing based on copyUnmatchedValues
            let recodedValue = paramsDict[existingValue] ?? (copyUnmatchedValues == true ? existingValue : "")
            //add new column
           self.dataStringsMatrix2D[row].append(recodedValue)
        }
        //add name to headers array
        self.headersStringsArray1D.append(title)
        return true
    }
    
    func recodedColumnInSitu(columnToRecode columnIndex:Int, usingParamsArray paramsArray:StringsMatrix2D, copyUnmatchedValues:Bool)->Bool
    {
        guard let validCI = self.validatedColumnIndex(columnIndex) else {return false}
        //make a temporary dictionary
        var paramsDict = CSVdata.paramsDictFromParamsArray(paramsArray)
        
        for row in 0..<self.numberOfRowsInData()
        {
            //ovewrite CORRECT PARAMETER AFTER LOOKUP or skip
            let existingValue = self.dataStringsMatrix2D[row][validCI]
            // use ?? to ask if lookup gives nil use alternative or if not nil use the lookup. if nil ask if clear or keep existing based on copyUnmatchedValues
            self.dataStringsMatrix2D[row][validCI] = paramsDict[existingValue] ?? (copyUnmatchedValues == true ? existingValue : "")
            
        }
        return true
    }
    
    // MARK: - Date Time
    class func standardDateFormatterWithFormatString(formatString:String)->NSDateFormatter
    {
        let dateFormat = NSDateFormatter()
        dateFormat.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormat.dateFormat = formatString
        dateFormat.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        return dateFormat
    }
    
    class func dataDetector()->NSDataDetector
    {
        let dataD = try? NSDataDetector(types: NSTextCheckingType.Date.rawValue)
        return dataD!
    }

    func appendDateInNewColumn(date date:NSDate, asString:Bool, rowN:Int)
    {
        if asString
        {
            self.dataStringsMatrix2D[rowN].append(date.description)
        }
        else
        {
            self.dataStringsMatrix2D[rowN].append(String(date.timeIntervalSinceReferenceDate))
        }
    }
    
    func appendedDateFromStringError(dateString dateString:String, dateFormat:NSDateFormatter, rowN:Int, asString:Bool, copyUnmatchedValues:Bool)->Int
    {
        guard let date = dateFormat.dateFromString(dateString)
            else
        {
            
            self.dataStringsMatrix2D[rowN].append(copyUnmatchedValues ? "⚠️ "+dateString : "")
            return 1
        }
        self.appendDateInNewColumn(date: date, asString: asString, rowN: rowN)
        return 0
    }
    
    func appendedDateDetectedInStringError(dateString dateString:String, dateFormat:NSDataDetector, rowN:Int, asString:Bool, copyUnmatchedValues:Bool)->Int
    {
        let detected = [dateFormat .firstMatchInString(dateString, options: [], range: NSMakeRange(0, (dateString as NSString).length))]
        for result in detected
        {
            guard
                let date = result?.date
                else
            {
                self.dataStringsMatrix2D[rowN].append(copyUnmatchedValues ? "⚠️ "+dateString : "")
                return 1
            }
            self.appendDateInNewColumn(date: date, asString: asString, rowN: rowN)
            return 0
        }
        return 1
    }
    
    func appendedCalculatedTimeFromStringError(startDateString startDateString:String, endDateString:String, dateFormat:NSDateFormatter, rowN:Int, roundingUnits:DateTimeRoundingUnits, copyUnmatchedValues:Bool, addIncrement:Double)->Int
    {
        guard
            let startdate = dateFormat.dateFromString(startDateString),
            let enddate = dateFormat.dateFromString(endDateString)
        else
        {
            self.dataStringsMatrix2D[rowN].append(copyUnmatchedValues ? startDateString+" ⚠️ "+endDateString : "")
            return 1
        }
        self.dataStringsMatrix2D[rowN].append(String(DateTimeRoundingUnits.roundedTimeAccordingToUnits(time: enddate.timeIntervalSinceDate(startdate), units: roundingUnits)+addIncrement))
        return 0
    }
    
    func appendedCalculatedTimeDetectedInStringError(startDateString startDateString:String, endDateString:String, dateFormat:NSDataDetector, rowN:Int, roundingUnits:DateTimeRoundingUnits, copyUnmatchedValues:Bool, addIncrement: Double)->Int
    {
        let detectedStart = [dateFormat .firstMatchInString(startDateString, options: [], range: NSMakeRange(0, (startDateString as NSString).length))]
        let detectedEnd = [dateFormat .firstMatchInString(endDateString, options: [], range: NSMakeRange(0, (endDateString as NSString).length))]
        var startDate: NSDate?
        var endDate: NSDate?
        
        for resultS in detectedStart
        {
            guard
                let sDate = resultS?.date
            else {continue}
            startDate = sDate
        }
        for resultE in detectedEnd
        {
            guard
                let eDate = resultE?.date
                else {continue}
            endDate = eDate
        }

        if startDate != nil && endDate != nil
        {
            self.dataStringsMatrix2D[rowN].append(String(DateTimeRoundingUnits.roundedTimeAccordingToUnits(time: endDate!.timeIntervalSinceDate(startDate!), units: roundingUnits)+addIncrement))
            return 0
        }
        self.dataStringsMatrix2D[rowN].append(copyUnmatchedValues ? startDateString+" ⚠️ "+endDateString : "")
        return 1
    }

    func recodedDateTimeToNewColumn(withTitle title:String, fromColum:Int, formatMethod:DateTimeFormatMethod, formatString:String, asString:Bool, copyUnmatchedValues:Bool)->Bool
    {
        var errors = 0
        switch formatMethod
        {
        case .DateWithTime:
            let dateFormat = CSVdata.standardDateFormatterWithFormatString(formatMethod.rawValue)
            for rowN in 0..<self.numberOfRowsInData()
            {
                errors += self.appendedDateFromStringError(dateString: self.dataStringsMatrix2D[rowN][fromColum], dateFormat: dateFormat, rowN: rowN, asString:asString, copyUnmatchedValues: copyUnmatchedValues)
            }
        case .DateOnly:
            let dateFormat = CSVdata.standardDateFormatterWithFormatString(formatMethod.rawValue)
            for rowN in 0..<self.numberOfRowsInData()
            {
                errors += self.appendedDateFromStringError(dateString: self.dataStringsMatrix2D[rowN][fromColum].componentsSeparatedByString("T")[0], dateFormat: dateFormat, rowN: rowN, asString:asString, copyUnmatchedValues: copyUnmatchedValues)
            }
        case .Custom:
            let dateFormat = CSVdata.standardDateFormatterWithFormatString(formatString)
            for rowN in 0..<self.numberOfRowsInData()
            {
                errors += self.appendedDateFromStringError(dateString: self.dataStringsMatrix2D[rowN][fromColum], dateFormat: dateFormat, rowN: rowN, asString:asString, copyUnmatchedValues: copyUnmatchedValues)
            }
       case .TextRecognition:
            let dateFormat = CSVdata.dataDetector()
            for rowN in 0..<self.numberOfRowsInData()
            {
                errors += self.appendedDateDetectedInStringError(dateString: self.dataStringsMatrix2D[rowN][fromColum].stringByReplacingOccurrencesOfString("T", withString: " at "), dateFormat: dateFormat, rowN: rowN, asString:asString, copyUnmatchedValues: copyUnmatchedValues)
            }
        }
        
        //add name to headers array
        self.headersStringsArray1D.append(title)
       return true
    }
    
    func calculatedDateTimeToNewColumn(withTitle title:String, startColumn:Int, endColumn:Int, formatMethod:DateTimeFormatMethod, formatString:String, roundingUnits:DateTimeRoundingUnits, copyUnmatchedValues:Bool, addIncrement:Double)->Bool
    {
        var errors = 0
        switch formatMethod
        {
        case .DateWithTime:
            let dateFormat = CSVdata.standardDateFormatterWithFormatString(formatMethod.rawValue)
            for rowN in 0..<self.numberOfRowsInData()
            {
                errors += self.appendedCalculatedTimeFromStringError(startDateString: self.dataStringsMatrix2D[rowN][startColumn], endDateString: self.dataStringsMatrix2D[rowN][endColumn], dateFormat: dateFormat, rowN: rowN, roundingUnits: roundingUnits, copyUnmatchedValues: copyUnmatchedValues, addIncrement: addIncrement)
            }
        case .DateOnly:
            let dateFormat = CSVdata.standardDateFormatterWithFormatString(formatMethod.rawValue)
            for rowN in 0..<self.numberOfRowsInData()
            {
                errors += self.appendedCalculatedTimeFromStringError(startDateString: self.dataStringsMatrix2D[rowN][startColumn].componentsSeparatedByString("T")[0], endDateString: self.dataStringsMatrix2D[rowN][endColumn].componentsSeparatedByString("T")[0], dateFormat: dateFormat, rowN: rowN, roundingUnits: roundingUnits, copyUnmatchedValues: copyUnmatchedValues, addIncrement: addIncrement)
            }
        case .Custom:
            let dateFormat = CSVdata.standardDateFormatterWithFormatString(formatString)
            for rowN in 0..<self.numberOfRowsInData()
            {
                errors += self.appendedCalculatedTimeFromStringError(startDateString: self.dataStringsMatrix2D[rowN][startColumn], endDateString: self.dataStringsMatrix2D[rowN][endColumn], dateFormat: dateFormat, rowN: rowN, roundingUnits: roundingUnits, copyUnmatchedValues: copyUnmatchedValues, addIncrement: addIncrement)
            }
        case .TextRecognition:
            let dateFormat = CSVdata.dataDetector()
            for rowN in 0..<self.numberOfRowsInData()
            {
                errors += self.appendedCalculatedTimeDetectedInStringError(
                    startDateString: self.dataStringsMatrix2D[rowN][startColumn].stringByReplacingOccurrencesOfString("T", withString: " at "),
                    endDateString: self.dataStringsMatrix2D[rowN][endColumn].stringByReplacingOccurrencesOfString("T", withString: " at "),
                    dateFormat: dateFormat, rowN: rowN, roundingUnits: roundingUnits, copyUnmatchedValues: copyUnmatchedValues, addIncrement: addIncrement)
            }
        }
        
        //add name to headers array
        self.headersStringsArray1D.append(title+"("+roundingUnits.rawValue+")")
        return true
    }

    // MARK: - Add to Column
    
    class func appendThisStringsArray1DToStringsMatrix2D(inout matrix2DToBeAppendedTo matrix2DToBeAppendedTo:StringsMatrix2D, array1DToAppend:StringsArray1D)
    {
        matrix2DToBeAppendedTo.append(array1DToAppend)
        
    }
    

    // MARK: - Data Matrix manipulation

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
            matrix.append(CSVdata.newParamValueBool(param: subArray[row]))
        }
        
        return matrix
    }
    

/*
    class func removeHeadersFromColumnArray(inout arrayOfColumns arrayOfColumns:StringsMatrix2D)
    {
        for col in 0..<arrayOfColumns.count
        {
            arrayOfColumns[col].removeAtIndex(0)
        }

    }
 */
    // MARK: - INSTANCE
    // MARK: - Import Export

    func postProcessCSVdataMatrix(var arrayOfColumns arrayOfColumns:StringsMatrix2D, name:String)
    {
        guard arrayOfColumns.count > 0 else {return}
        
        self.headersStringsArray1D = arrayOfColumns.removeAtIndex(0)
        self.dataStringsMatrix2D = arrayOfColumns
        self.processedDataOK = self.checkIntegrityOfFile()
        self.name = name
   }
    
    func checkIntegrityOfFile()->Bool
    {
        let numHeaderCols = self.headersStringsArray1D.count
        for row in 0..<self.numberOfRowsInData()
        {
            if self.dataStringsMatrix2D[row].count != numHeaderCols
            {
                GlobalUtilities.alertWithMessage("The file does not have the same number of columns in the headers and the rows", style: .CriticalAlertStyle)
                return false
            }
        }
        return true
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
                //let newRow = (subStrings.joinWithSeparator(quotationMarksReplacement).componentsSeparatedByString(commaDelimiter))
                arrayOfColumnArrays.append((subStrings.joinWithSeparator(quotationMarksReplacement).componentsSeparatedByString(commaDelimiter)))
            }
            else
            {
                //let newRow = (line.componentsSeparatedByString(commaDelimiter))
                arrayOfColumnArrays.append((line.componentsSeparatedByString(commaDelimiter)))
          }
        })
        
        self.postProcessCSVdataMatrix(arrayOfColumns: arrayOfColumnArrays, name: name)
    }
    
    func importTABstring(dataAsString dataAsString:NSString, name:String)
    {
        var arrayOfColumnArrays = StringsMatrix2D()
        dataAsString.enumerateLinesUsingBlock({ (line, okay) -> Void in
            // we dont check for tabs inside quotes
            //let newRow = (line.componentsSeparatedByString(tabDelimiter))
            arrayOfColumnArrays.append((line.componentsSeparatedByString(tabDelimiter)))
        })

        self.postProcessCSVdataMatrix(arrayOfColumns: arrayOfColumnArrays, name: name)
}

    func processSelfCSVtoData(delimiter delimiter:String) -> NSData?
    {
        guard
            self.notAnEmptyDataSet()
        else {return nil}
        
        var tempDataArray = StringsArray1D()
        //add headers string
        tempDataArray.append(self.headersStringsArray1D.joinWithSeparator(delimiter))
        //build the rows strings one by one and append
        for rowN in 0..<self.numberOfRowsInData()
        {
            tempDataArray.append(self.dataStringsMatrix2D[rowN].joinWithSeparator(delimiter))
        }
        
        //let fileString = tempDataArray.joinWithSeparator(carriageReturn)
        return tempDataArray.joinWithSeparator(carriageReturn).dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    class func processThisCSVtoData(csvData csvData:CSVdata, delimiter:String) -> NSData?
    {
        guard
            csvData.notAnEmptyDataSet()
            else {return nil}
        
        var tempDataArray = StringsArray1D()
        //add headers string
        tempDataArray.append(csvData.headersStringsArray1D.joinWithSeparator(delimiter))
        //build the rows strings one by one and append
        for rowN in 0..<csvData.numberOfRowsInData()
        {
            tempDataArray.append(csvData.dataStringsMatrix2D[rowN].joinWithSeparator(delimiter))
        }
        
        //let fileString = tempDataArray.joinWithSeparator(carriageReturn)
        return tempDataArray.joinWithSeparator(carriageReturn).dataUsingEncoding(NSUTF8StringEncoding)
    }

    
    
    func exportDataTabDelimitedTo(fileURL fileURL:NSURL?)
    {
        guard let theURL = fileURL else {return}
        let data = self.processSelfCSVtoData(delimiter: tabDelimiter)
        guard let okData = data else {return}
        
        okData.writeToURL(theURL, atomically: true)
    }

    
    // MARK: - Merge
    
    
    func appendTheseParametersIntoColumn(params params:SetOfStrings, intoColumn:Int, padValue:String)
    {
        guard
            let matchColumnInMydata = self.validatedColumnIndex(intoColumn)
        else {return}
        for param in params
        {
            var padSuffix = StringsArray1D(count: self.numberOfColumnsInData(), repeatedValue: padValue)
            padSuffix[matchColumnInMydata] = param
            self.dataStringsMatrix2D.append(padSuffix)
        }
    }
    
    func mergeCSVdataAndReturnUniqueHeaders(csvdataToMerge: CSVdata?)->StringsArray1D
    {
        if csvdataToMerge != nil && csvdataToMerge!.notAnEmptyDataSet()
        {
            var lastColumn = self.numberOfColumnsInData()//.count automatically adds 1
            var newUniqueColHeaders = StringsArray1D()
            var lookupMatrixOfNewColumns = StringsArray1D()//same length as new unique cols, has either the original column index in if matched, or a new col index if appended
            for colnum in 0..<csvdataToMerge!.numberOfColumnsInData()
            {
                let matchedIndex = self.headersStringsArray1D.indexOf(csvdataToMerge!.headersStringsArray1D[colnum])
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
                    newUniqueColHeaders.append(csvdataToMerge!.headersStringsArray1D[colnum])
                }
            }
            
            if newUniqueColHeaders.count > 0
            {
                //append the new col names to existing headers
                self.headersStringsArray1D += newUniqueColHeaders
                
                //padd the array with new blank columns
                let padSuffix = StringsArray1D(count: newUniqueColHeaders.count, repeatedValue: "")
                for row in 0..<self.dataStringsMatrix2D.count
                {
                    self.dataStringsMatrix2D[row] += padSuffix
                }
            }
            
            //append the new rows onto array
            for row in 0..<csvdataToMerge!.dataStringsMatrix2D.count
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
                    newRow[validCN] = csvdataToMerge!.dataStringsMatrix2D[row][colnumber]
                }
                //append new row to existing
                self.dataStringsMatrix2D.append(newRow)
            }
            
            //send back the headers
            return newUniqueColHeaders
        }
        else
        {
            return StringsArray1D()
        }
    }

    
    // MARK: - Extract Rows
    class func extractTheseRowsFromDataMatrixAsDataMatrix(rows rows:NSIndexSet, datamatrix:StringsMatrix2D)->StringsMatrix2D
    {
        guard datamatrix.count  > 0 else {return StringsMatrix2D()}
        let extractedRows = ((datamatrix as NSArray).objectsAtIndexes(rows) as? StringsMatrix2D)
        return extractedRows == nil ? StringsMatrix2D() : extractedRows!
    }
    
    func extractTheseRowsFromSelfAsCSVdata(rows rows:NSIndexSet)->CSVdata
    {
        guard self.notAnEmptyDataSet() else {return CSVdata()}
        
        let extractedRows = CSVdata.extractTheseRowsFromDataMatrixAsDataMatrix(rows: rows, datamatrix: self.dataStringsMatrix2D)
        return CSVdata(headers: self.headersStringsArray1D, csvdata: extractedRows, name:"")
    }
    
    func extractRowsBasedOnPredicatesIntoNewFile(predicates predicates:ArrayOfPredicatesForExtracting)
    {
        let extractedDataIndexes = self.extractIndexSetOfMatchedRowsUsingPredicates(predicates: predicates)
        if extractedDataIndexes.count>0
        {
            self.createNewDocumentFromRowsInIndexSet(rows: extractedDataIndexes, docName: "")
        }
        
    }

    func extractIndexSetOfMatchedRowsUsingPredicates(predicates predicates:ArrayOfPredicatesForExtracting)->NSMutableIndexSet
    {
        let extractedRowIndexes = NSMutableIndexSet()
        let predicatesSplitByBoolean = PredicateForExtracting.splitPredicatesByBoolean(predicatesToSplit: predicates)
        
        for rowN in 0..<self.numberOfRowsInData()
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
                guard let colIndex = self.columnIndexForHeaderString(predicateNOT.columnNameToMatch) else {print("self.columnIndexForHeaderString(predicateNOT.columnNameToMatch) failed");continue}//should alert here
                if self.stringValueForCell(fromColumn: colIndex, atRow: rowN) == predicateNOT.stringToMatch
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
                    guard let colIndex = self.columnIndexForHeaderString(predicateAND.columnNameToMatch) else {print("self.columnIndexForHeaderString(predicateAND.columnNameToMatch) failed");continue}//should alert here
                    if self.stringValueForCell(fromColumn: colIndex, atRow: rowN) != predicateAND.stringToMatch
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
                    guard let colIndex = self.columnIndexForHeaderString(predicateOR.columnNameToMatch) else {print("self.columnIndexForHeaderString(predicateOR.columnNameToMatch) failed");continue}//should alert here
                    if self.stringValueForCell(fromColumn: colIndex, atRow: rowN) == predicateOR.stringToMatch
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
                extractedRowIndexes.addIndex(rowN)
            }
        }
        return extractedRowIndexes
    }
    
    func extractDataMatrixUsingPredicates(predicates predicates:ArrayOfPredicatesForExtracting)->StringsMatrix2D
    {
        return self.extractTheseRowsFromSelfAsCSVdata(rows: self.extractIndexSetOfMatchedRowsUsingPredicates(predicates: predicates)).dataStringsMatrix2D
    }

    // MARK: - Extract From Column
    
    func lookupDictionaryFromColumn(lookupColumn lookupColumn:Int, mergeColumnsIndexes:SortedArrayOfIndexes)->LookupDictionary?
    {
        guard
            mergeColumnsIndexes.count > 0
        else {return nil}
        
        //make a temporary dictionary
        var paramsDict = LookupDictionary()
        //go down the rows collecting the keys and the column data to merge
        for row in 0..<self.numberOfRowsInData()
        {
            guard
                let lookupKey = self.stringValueForCell(fromColumn: lookupColumn, atRow: row)
            else {continue}
            paramsDict[lookupKey] = self.stringsArray1DFromSortedColumns(columns: mergeColumnsIndexes, atRow: row)
        }
        
        return paramsDict
    }

    func lookedupNewColumnsFromCSVdata(lookupCSVdata lookupCSVdata:CSVdata, lookupColumn:Int, columnsToAdd:NSIndexSet)->StringsArray1D?
    {
        let sortedIndexes = CSVdata.sortedArrayOfIndexesFromNSIndexSet(indexes: columnsToAdd)
        guard
            let matchColumnInMydata = self.headersStringsArray1D.indexOf(lookupCSVdata.headersStringsArray1D[lookupColumn]),
            let lookupdict = lookupCSVdata.lookupDictionaryFromColumn(lookupColumn: lookupColumn, mergeColumnsIndexes: sortedIndexes),
            let newHeaders = lookupCSVdata.headersArrayForSortedIndexes(sortedIndexes)
        else {return nil}

        //add new columns - we shoudl check uniqueness
        for c in 0..<newHeaders.count
        {
            self.headersStringsArray1D.append(newHeaders[c])
        }
        
        //add the new col data or a dummy by lookup
        let dummyExtension = StringsArray1D(count: newHeaders.count, repeatedValue: "")
        for row in 0..<self.numberOfRowsInData()
        {
            guard
                let keyValueForRow = self.stringValueForCell(fromColumn: matchColumnInMydata, atRow: row),
                let colData = lookupdict[keyValueForRow]
            else
            {
                // unable to match so add a dummy data extension
                self.dataStringsMatrix2D[row] += dummyExtension
                //for c in 0..<dummyExtension.count
                //{
                //    self.dataStringsMatrix2D[row].append(dummyExtension[c])
                //}
                continue
            }
            //matched so add the new columns data
            self.dataStringsMatrix2D[row] += colData
            //for c in 0..<colData.count
            //{
            //    self.dataStringsMatrix2D[row].append(colData[c])
            //}
            //print("\(self.dataStringsMatrix2D[row]) <<< \(colData)")
        }
        return newHeaders
    }
    
    func stringsArray1DFromSortedColumns(columns columns:SortedArrayOfIndexes, atRow:Int)->StringsArray1D?
    {
        guard
            columns.count > 0
            else {return nil}
        var collectedCols = StringsArray1D()
        //let sortedCols = CSVdata.sortedArrayOfIndexesFromNSIndexSet(indexes: columns)
        for col in 0..<columns.count
        {
            let val = self.stringValueForCell(fromColumn: columns[col], atRow: atRow)
            if val != nil
            {
                collectedCols.append(val!)
            }
            else
            {
                collectedCols.append("")
            }
        }
        return collectedCols
    }
    
    func setOfParametersFromColumn(fromColumn columnIndex:Int, replaceBlank:Bool)->SetOfStrings?
    {
        guard let validCI = self.validatedColumnIndex(columnIndex) else {return nil}
        var set = SetOfStrings()
        for rowN in 0..<self.numberOfRowsInData()
        {
            guard
                let stringV = self.stringValueForCell(fromColumn: validCI, atRow: rowN)
            else {continue}
            set.insert(stringV)
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

    func stringsArray1DOfParametersFromColumn(fromColumn columnIndex:Int, replaceBlank:Bool)->StringsArray1D?
    {
        guard let set = self.setOfParametersFromColumn(fromColumn: columnIndex, replaceBlank: replaceBlank) else {return nil}
        
        return Array(set)
    }
    
    func copyColumnsToString(fromColumnIndexes fromColumnIndexes:NSIndexSet)->String?
    {
        guard
            fromColumnIndexes.count > 0
        else {return nil}
        
        var newCSVdata = StringsArray1D()
        var newheaders = StringsArray1D()
        //let sortedCols = CSVdata.sortedArrayOfIndexesFromNSIndexSet(indexes: fromColumnIndexes)
        for col in fromColumnIndexes
        {
            newheaders.append(self.headersStringsArray1D[col])
        }
        newCSVdata.append(newheaders.joinWithSeparator(tabDelimiter))
        for row in 0..<self.dataStringsMatrix2D.count
        {
            var newRow = StringsArray1D()
            for colindex in fromColumnIndexes
            {
                guard
                    let newval = self.stringValueForCell(fromColumn: colindex, atRow: row)
                else {continue}
                newRow.append(newval)
            }
            newCSVdata.append(newRow.joinWithSeparator(tabDelimiter))
        }
        return newCSVdata.joinWithSeparator(carriageReturn)
    }
    
    func dataMatrixOfParametersFromColumn(fromColumn columnIndex:Int)->StringsMatrix2D?
    {
        guard let set = self.setOfParametersFromColumn(fromColumn: columnIndex, replaceBlank: false) else {return nil}
            //bit dumb we say replaceBlank: false and then do indataMatrixWithNoBlanksFromSet
        
        return set.count == 0 ? nil : CSVdata.dataMatrixWithNoBlanksFromSet(set: set)
    }
    
    func dataMatrixOfParametersWithNoBlanksFromColumnIfStringMatchedInColumn(fromColumn columnToExtractIndex:Int, matchString:String, matchColumn:Int)->StringsMatrix2D?
    {
        guard let set = self.setOfParametersFromColumnIfStringMatchedInColumn(fromColumn:columnToExtractIndex, matchString:matchString, matchColumn:matchColumn) else {return nil}
        
        return set.count == 0 ? nil : CSVdata.dataMatrixWithNoBlanksFromSet(set: set)
    }
    

    func setOfParametersFromColumnIfStringMatchedInColumn(fromColumn fromColumn:Int, matchString:String, matchColumn:Int)->SetOfStrings?
    {
        guard
            let validFromC = self.validatedColumnIndex(fromColumn),
            let validMatchC = self.validatedColumnIndex(matchColumn)
            else {return nil}
        guard numberOfRowsInData() > 0 else {return nil}
        
        var set = SetOfStrings()
        for rowN in 0..<self.numberOfRowsInData()
        {
            guard
                let matchV = self.stringValueForCell(fromColumn: validMatchC, atRow: rowN) where matchV == matchString,
                let stringV = self.stringValueForCell(fromColumn: validFromC, atRow: rowN)
            else {continue}
            set.insert(stringV)
        }
        
        return set.count == 0 ? nil : set
    }

    // MARK: - Rows
    func validatedRowIndexForColumn(rowIndex:Int, columnIndex:Int)->Int?
    {
        guard
            columnIndex < self.numberOfColumnsInData() &&
            rowIndex >= 0 &&
            rowIndex < self.numberOfRowsInData()
        else {print("non validatedRowIndex col \(columnIndex) row - \(rowIndex)"); return nil}
        return rowIndex
    }
    

    func numberOfRowsInData()->Int{
        return self.dataStringsMatrix2D.count
    }
    
    
    func deletedRowsAtIndexes(indexes:NSIndexSet)->Bool
    {
        guard self.notAnEmptyDataSet() else {return false}
        for var i = indexes.lastIndex; i != NSNotFound; i = indexes.indexLessThanIndex(i)
        {
            self.dataStringsMatrix2D.removeAtIndex(i)
        }
        return true
    }
    
    // MARK: - Header Names
    func headerStringsForAllColumns()->[String]
    {
        return self.headersStringsArray1D
    }
    
    func headersArrayForSortedIndexes(colIndexes:SortedArrayOfIndexes)->StringsArray1D?
    {
        var headersarray = StringsArray1D()
        //let sortedCols = CSVdata.sortedArrayOfIndexesFromNSIndexSet(indexes: colIndexes)
        for index in 0..<colIndexes.count
        {
            guard
                let validCI = self.validatedColumnIndex(colIndexes[index])
                else {return nil}
            headersarray.append(self.headersStringsArray1D[validCI])
        }
        return headersarray
    }
    
    func headerStringForColumnIndex(columnIndex:Int) -> String
    {
        guard let index = self.validatedColumnIndex(columnIndex) else {return "???"}
        return (self.headersStringsArray1D[index])
    }
    
    func renamedColumnAtIndex(columnIndex columnIndex: Int, newName:String)->Bool
    {
        guard !newName.isEmpty else {return false}
        guard let index = self.validatedColumnIndex(columnIndex) else {return false}
        self.headersStringsArray1D[index] = newName
        return true
    }

    func columnIndexForHeaderString(headerString:String)->Int?
    {
        return self.headersStringsArray1D.indexOf(headerString)
    }
    
    func extractedPredicatesArrayWithMissingColumnNamesHighlighted(arrayToCheck:ArrayOfPredicatesForExtracting)->ArrayOfPredicatesForExtracting
    {
        var checkedArray = ArrayOfPredicatesForExtracting()
        for var predicate in arrayToCheck
        {
            guard (self.headersStringsArray1D.indexOf(predicate.columnNameToMatch) == nil) else {checkedArray.append(predicate); continue}
            predicate.columnNameToMatch = "⚠️ "+predicate.columnNameToMatch
            checkedArray.append(predicate)
        }
        return checkedArray
    }

    // MARK: - Table View
    func cellForHeadersTable(tableView tableView: NSTableView, row: Int) ->NSTableCellView
    {
        let cellView = tableView.makeViewWithIdentifier("headersCell", owner: self) as! NSTableCellView
        cellView.textField!.stringValue = self.headerStringForColumnIndex(row)
        return cellView
    }

    // MARK: - Data Access
    func stringValueForCell(fromColumn fromColumn:Int, atRow:Int)->String?
    {
        return self.dataStringsMatrix2D[atRow][fromColumn]
    }
    
    func stringValueForCellAfterValidation(fromColumn fromColumn:Int, atRow:Int)->String?
    {
        guard
            let validCI = self.validatedColumnIndex(fromColumn),
            let validRI = self.validatedRowIndexForColumn(atRow, columnIndex: fromColumn)
        else {return nil}
        
        return self.dataStringsMatrix2D[validRI][validCI]
        
    }

    func setStringValueForCell(valueString valueString:String, toColumn:Int, inRow:Int)
    {
        self.dataStringsMatrix2D[inRow][toColumn] = valueString
    }
    
    func setStringValueForCellAfterValidation(valueString valueString:String, toColumn:Int, inRow:Int)
    {
        guard
            let validCI = self.validatedColumnIndex(toColumn),
            let validRI = self.validatedRowIndexForColumn(inRow, columnIndex: toColumn)
            else {return}
        self.dataStringsMatrix2D[validRI][validCI] = valueString
    }
    
    // MARK: - Document
    class func createNewDocumentFromCVSDataAndColumnName(cvsData cvsData: CSVdata, name:String)
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
    
    func createNewDocumentFromRowsInIndexSet(rows rows:NSIndexSet, docName:String)
    {
        CSVdata.createNewDocumentFromCVSDataAndColumnName(cvsData: self.extractTheseRowsFromSelfAsCSVdata(rows: rows), name: docName)
    }
    
    func createNewDocumentFromExtractedRows(cvsData extractedRows:StringsMatrix2D, headers:StringsArray1D?, name: String?)
    {
        do {
            let doc = try NSDocumentController.sharedDocumentController().openUntitledDocumentAndDisplay(true)
            if doc is CSVdataDocument
            {
                let headersOrMyHeaders = headers == nil ? self.headersStringsArray1D : headers! // use my headers if none
                (doc as! CSVdataDocument).csvDataModel = CSVdata(headers: headersOrMyHeaders, csvdata: extractedRows, name:name == nil ? "" : name!)
                (doc as! CSVdataDocument).updateChangeCount(.ChangeDone)
            }
            doc.setDisplayName(name)//setDisplayName handles optionsals OK
        } catch {
            print("Error making new doc")
        }
    }
    
    // MARK: - ChartDataSet
    func chartDataSetFromColumnIndexes(columnIndexes columnIndexes:NSIndexSet)->ChartDataSet
    {
        switch columnIndexes.count
        {
        case 0:
            return ChartDataSet()
        case 1:
            return ChartDataSet(data: self.dataStringsMatrix2D, forColumnIndex: columnIndexes.firstIndex)
        case 2:
            return ChartDataSet(data: self.dataStringsMatrix2D, columnIndexY: columnIndexes.firstIndex, columnIndexX: columnIndexes.lastIndex)
        default:
            return ChartDataSet()
        }
    }

}
