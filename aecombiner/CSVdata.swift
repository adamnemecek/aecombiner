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

class CSVdata {

    var headers = [String]()
    var csvData = [[String]]()
    var columnsCount:Int = 0
    
    class func processCSVfileToData(data: NSData) -> (noErrors:Bool, dataModel:CSVdata)
    {
        var dataModel = CSVdata()
        var processedOK = false
        var dataAsString = NSString(data: data, encoding: NSUTF8StringEncoding)
        var arrayOfRowArrays = [[String]]()
        if dataAsString != nil
        {
            dataAsString!.enumerateLinesUsingBlock({ (line, okay) -> Void in
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
                dataModel.headers = arrayOfRowArrays[0]
                dataModel.columnsCount = arrayOfRowArrays[0].count
                arrayOfRowArrays.removeAtIndex(0)
                dataModel.csvData = arrayOfRowArrays
                processedOK = true
            }
        }
        return (processedOK, dataModel)
    }

}
