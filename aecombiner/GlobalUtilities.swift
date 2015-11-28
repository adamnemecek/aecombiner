//
//  GlobalFunctions.swift
//  aecombiner
//
//  Created by David Lewis on 20/09/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa

struct GlobalUtilities
{
    
    static func alertWithMessage(message:String, style: NSAlertStyle)
    {
        let alert = NSAlert()
        alert.messageText = message
        alert.alertStyle = style
        alert.runModal()
    }
    
}

extension NSTableColumn
{
    class func columnWithUniqueIdentifierAndTitle(title:String)->NSTableColumn
    {
        let col =  NSTableColumn(identifier:String(NSDate().timeIntervalSince1970))
        col.title = title
        col.sizeToFit()
        col.minWidth = col.width
        col.maxWidth = CGFloat.max
        col.sortDescriptorPrototype = NSSortDescriptor(key: nil, ascending: true)
        return col
    }
    
}

extension NSTableView
{
    func sortParametersOrValuesInTableViewColumn(tableColumn tableColumn: NSTableColumn, inout arrayToSort:StringsMatrix2D, textOrValue:Int)
    {
        guard arrayToSort.count > 0 else {return}
        let columnIndexToSort = self.columnWithIdentifier(tableColumn.identifier)
        guard
            columnIndexToSort >= 0 && columnIndexToSort < arrayToSort[0].count
            else {return}
        
        if tableColumn.sortDescriptorPrototype == nil
        {
            tableColumn.sortDescriptorPrototype = NSSortDescriptor(key: nil, ascending: true)
        }
        
        let sortdirection = tableColumn.sortDescriptorPrototype!.ascending
        
        switch (sortdirection, textOrValue)
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
        
        tableColumn.sortDescriptorPrototype = NSSortDescriptor(key: nil, ascending: !sortdirection)
    }
    
    func sortParametersAsStringsArray1DInTableViewColumn(tableColumn tableColumn: NSTableColumn, inout arrayToSort:StringsArray1D, textOrValue:Int)
    {
        guard arrayToSort.count > 0 else {return}
        let columnIndexToSort = self.columnWithIdentifier(tableColumn.identifier)
        guard columnIndexToSort >= 0 else {return}
        
        if tableColumn.sortDescriptorPrototype == nil
        {
            tableColumn.sortDescriptorPrototype = NSSortDescriptor(key: nil, ascending: true)
        }
        
        let sortdirection = tableColumn.sortDescriptorPrototype!.ascending
        
        switch (sortdirection, textOrValue)
        {
        case (kAscending,kSortAsValue):
            arrayToSort.sortInPlace {Double($0)>Double($1)}
        case (kDescending,kSortAsValue):
            arrayToSort.sortInPlace {Double($0)<Double($1)}
        case (kAscending,kSortAsText):
            arrayToSort.sortInPlace {($0 as NSString).localizedCaseInsensitiveCompare($1) == .OrderedAscending}
        case (kDescending,kSortAsText):
            arrayToSort.sortInPlace {($0 as NSString).localizedCaseInsensitiveCompare($1) == .OrderedDescending}
        default:
            return
        }
        
        tableColumn.sortDescriptorPrototype = NSSortDescriptor(key: nil, ascending: !sortdirection)
    }
    
    func sizeColumnsToFitWidestValueAndHeader(csvdata csvdata:CSVdata, cellIdentifier:String)
    {
        guard
            let  cellView = self.makeViewWithIdentifier(cellIdentifier, owner: self) as? NSTableCellView
            else {return}
        var maxwidth:CGFloat
        for originalColumn in self.tableColumns
        {
            maxwidth = cellView.sizeToFitString(originalColumn.title)
            let colIndex = self.columnWithIdentifier(originalColumn.identifier)
            for row in 0..<csvdata.numberOfRowsInData()
            {
                maxwidth = fmax(maxwidth, cellView.sizeToFitString(csvdata.stringValueForCell(fromColumn: colIndex, atRow: row)))
            }
            originalColumn.width = maxwidth+3.0
        }

        self.reloadData()

    }

}

extension NSTableCellView
{
    func sizeToFitString(text:String?)->CGFloat
    {
        if text == nil || self.textField == nil {return 0.0}

        self.textField!.stringValue = text!
        self.textField!.sizeToFit()
        return self.textField!.frame.size.width
    }
}
