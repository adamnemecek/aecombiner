//
//  Document.swift
//  aecombiner
//
//  Created by David JM Lewis on 25/06/2015.
//  Copyright (c) 2015 djml.eu. All rights reserved.
//

import Cocoa
let quotationMarks = "\""
let commaReplacement = "‚"//,
let commaDelimiter = ","



class Document: NSDocument {

    var cvsDataModel = CSVdata()
    
    
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
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)!
        let windowController = storyboard.instantiateControllerWithIdentifier("Document Window Controller") as! NSWindowController
        self.addWindowController(windowController)
        windowController.window?.contentViewController?.representedObject = self.cvsDataModel
    }

    override func dataOfType(typeName: String, error outError: NSErrorPointer) -> NSData? {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        outError.memory = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        return nil
    }

    override func readFromData(data: NSData, ofType typeName: String, error outError: NSErrorPointer) -> Bool {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
        outError.memory = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        switch typeName
        {
        case "csvFile":
            var readOK = self.processCSVfileToData(data)
            return readOK
        default:
            return false
        }
        
    }

    func processCSVfileToData(data: NSData) -> Bool
    {
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
                    arrayOfRowArrays.append("".join(subStrings).componentsSeparatedByString(commaDelimiter))
                }
                else
                {
                    arrayOfRowArrays.append(line.componentsSeparatedByString(commaDelimiter))
                }
            })
            if arrayOfRowArrays.count > 0
            {
                self.cvsDataModel.headers = arrayOfRowArrays[0]
                self.cvsDataModel.columnsCount = arrayOfRowArrays[0].count
                arrayOfRowArrays.removeAtIndex(0)
                self.cvsDataModel.csvData = arrayOfRowArrays
                return true
            }
        }
        return false
    }

}

