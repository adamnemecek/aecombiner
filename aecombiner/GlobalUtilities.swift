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
    
    
}
