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
            if let value = self.csvDataModel.processSelfCSVtoData(delimiter: commaDelimiter) {
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
            self.csvDataModel = CSVdata(data: data, name: self.displayName, delimiter: .CSV)
            if self.csvDataModel.processedDataOK {
                return
            }
            throw outError
        default:
            throw outError
        }
        
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
    
    // MARK: - table View
    func columnsClearAndRebuild(tvCSVdata:NSTableView)
    {
        while tvCSVdata.tableColumns.count > 0
        {
            tvCSVdata.removeTableColumn(tvCSVdata.tableColumns.last!)
        }
        for c in 0..<self.csvDataModel.numberOfColumnsInData()
        {
            tvCSVdata.addTableColumn(NSTableColumn.columnWithUniqueIdentifierAndTitle(self.csvDataModel.headerStringForColumnIndex(c)))
        }
        tvCSVdata.reloadData()
    }

    
    
    
    

}

