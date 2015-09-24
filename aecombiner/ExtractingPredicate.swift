//
//  ExtractingPredicate.swift
//  aecombiner
//
//  Created by David Lewis on 21/09/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa



class ExtractingPredicateTableCellView: NSTableCellView {
    @IBOutlet weak var textFieldLower: NSTextField!
    
}


struct ExtractingPredicate: Comparable
{
    var columnNameToMatch:String
    var stringToMatch:String
    var booleanOperator:String
    init (columnName:String,string:String,boolean:String)
    {
        booleanOperator = boolean
        stringToMatch = string
        columnNameToMatch = columnName
    }
    static func extractNSArrayFromExtractingPredicatesArray(predicatesarray predicatesarray:ExtractingPredicatesArray)->NSMutableArray
    {
        let newarray = NSMutableArray()
        for predicate in predicatesarray
        {
            let newRow = NSArray(objects: predicate.booleanOperator,predicate.stringToMatch,predicate.columnNameToMatch)
            newarray.addObject(newRow)
        }
        return newarray
    }
    static func extractExtractingPredicatesArrayFromNSArray(array:NSArray)->ExtractingPredicatesArray
    {
        
        var newarray = ExtractingPredicatesArray()
        for predicate in array
        {
            let predA = predicate as! NSArray
            let newP = ExtractingPredicate(columnName: predA.objectAtIndex(2) as! String, string: predA.objectAtIndex(1) as! String, boolean: predA.objectAtIndex(0) as! String)
            newarray.append(newP)
        }
        return newarray
    }
    
    static func saveExtractingPredicatesArrayToURL(url url:NSURL, predicatesarray:ExtractingPredicatesArray)
    {
        let nsarray = self.extractNSArrayFromExtractingPredicatesArray(predicatesarray: predicatesarray)
        nsarray.writeToURL(url, atomically: true)
    }
    
    static func loadExtractingPredicatesArrayFromURL(url url:NSURL)-> ExtractingPredicatesArray?
    {
        guard let array = NSArray(contentsOfURL: url) where array.count > 0 else {return nil}
        return self.extractExtractingPredicatesArrayFromNSArray(array)
    }
    
    
}
//you implement == type at GLOBAL level not within the body of the struct!!!
func ==(lhs: ExtractingPredicate, rhs: ExtractingPredicate) -> Bool {
    return  //(lhs.booleanOperator == rhs.booleanOperator)  && we ignore bool as u cant use the same search term in more than one bool type
        (lhs.columnNameToMatch == rhs.columnNameToMatch) &&
            (lhs.stringToMatch == rhs.stringToMatch)
}
func < (lhs: ExtractingPredicate, rhs: ExtractingPredicate) -> Bool {
    //phased approach. We test in precedence and ignore any unequalness below if the upper level is discordant
    // so it may be > at a lower level
    // we do this to ensure the ANDs cluster apart from ORs, COLUMNs from each other and so on
    if lhs.booleanOperator != rhs.booleanOperator
    {return lhs.booleanOperator < rhs.booleanOperator}
    if lhs.columnNameToMatch != rhs.columnNameToMatch
    {return lhs.columnNameToMatch < rhs.columnNameToMatch}
    return lhs.stringToMatch < rhs.stringToMatch
}

typealias ExtractingPredicatesArray = [ExtractingPredicate]

struct PredicatesByBoolean {
    var ANDpredicates = ExtractingPredicatesArray()
    var ORpredicates = ExtractingPredicatesArray()
    var NOTpredicates = ExtractingPredicatesArray()
    
}
