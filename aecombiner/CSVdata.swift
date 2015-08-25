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

typealias DataMatrix = [[String]]
typealias HeadersMatrix = [String]


class CSVdata {

    var headers = HeadersMatrix()
    var csvData = DataMatrix()
    var processedDataOK = false
    
    init()
    {
        self.headers = HeadersMatrix()
        self.csvData = DataMatrix()
        self.processedDataOK = false
    }
    
    convenience init (headers:HeadersMatrix, csvdata:DataMatrix)
    {
        self.init()
        self.headers = headers
        self.csvData = csvdata
        processedDataOK = true
    }
    
    convenience init (dataCSV: NSData)
    {
        self.init()
        guard let dataAsString = NSString(data: dataCSV, encoding: NSUTF8StringEncoding) else {return}
        self.importCSVstring(dataAsString: dataAsString)
    }
    
    convenience init (dataTAB: NSData)
    {
        self.init()
        guard let dataAsString = NSString(data: dataTAB, encoding: NSUTF8StringEncoding) else {return}
        self.importTABstring(dataAsString: dataAsString)
    }
    
    convenience init (stringTAB: NSString)
    {
        self.init()
        self.importTABstring(dataAsString: stringTAB)
    }
    
    func importCSVstring(dataAsString dataAsString:NSString)
    {
        var arrayOfRowArrays = DataMatrix()
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
                arrayOfRowArrays.append(quotationMarksReplacement.join(subStrings).componentsSeparatedByString(commaDelimiter))
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
        }
    }
    
    func importTABstring(dataAsString dataAsString:NSString)
    {
        var arrayOfRowArrays = DataMatrix()
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
        }
    }

    func processCSVtoData(delimiter delimiter:String) -> NSData?
    {
        var tempArray = HeadersMatrix()
        for var row = 0; row<self.csvData.count; row++
        {
            let rowString = delimiter.join(self.csvData[row])
            tempArray.append(rowString)
        }
        tempArray.insert(delimiter.join(self.headers), atIndex: 0)
        let fileString = carriageReturn.join(tempArray)
        return fileString.dataUsingEncoding(NSUTF8StringEncoding)
    }

}
