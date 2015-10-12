//
//  PredicateForExtracting.swift
//  aecombiner
//
//  Created by David Lewis on 21/09/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa



class ExtractingPredicateTableCellView: NSTableCellView {
    @IBOutlet weak var textFieldLower: NSTextField!
    
}


struct PredicateForExtracting: Comparable
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
    
    static func splitPredicatesByBoolean(predicatesToSplit predicatesToSplit:ArrayOfPredicatesForExtracting)->PredicatesByBoolean
    {
        var splitpreds = PredicatesByBoolean()
        for predicate in predicatesToSplit
        {
            switch predicate.booleanOperator
            {
            case kBooleanStringAND:
                splitpreds.ANDpredicates.append(predicate)
            case kBooleanStringOR:
                splitpreds.ORpredicates.append(predicate)
            case kBooleanStringNOT:
                splitpreds.NOTpredicates.append(predicate)
            default:
                break
            }
        }
        return splitpreds
    }
    

    static func extractNSArrayFromExtractingPredicatesArray(predicatesarray predicatesarray:ArrayOfPredicatesForExtracting)->NSMutableArray
    {
        let newarray = NSMutableArray()
        for predicate in predicatesarray
        {
            let newRow = NSArray(objects: predicate.booleanOperator,predicate.stringToMatch,predicate.columnNameToMatch)
            newarray.addObject(newRow)
        }
        return newarray
    }
    static func extractExtractingPredicatesArrayFromNSArray(array:NSArray)->ArrayOfPredicatesForExtracting
    {
        
        var newarray = ArrayOfPredicatesForExtracting()
        for predicate in array
        {
            let predA = predicate as! NSArray
            let newP = PredicateForExtracting(columnName: predA.objectAtIndex(2) as! String, string: predA.objectAtIndex(1) as! String, boolean: predA.objectAtIndex(0) as! String)
            newarray.append(newP)
        }
        return newarray
    }
    
    static func saveExtractingPredicatesArrayToURL(url url:NSURL, predicatesarray:ArrayOfPredicatesForExtracting)
    {
        let nsarray = self.extractNSArrayFromExtractingPredicatesArray(predicatesarray: predicatesarray)
        nsarray.writeToURL(url, atomically: true)
    }
    
    static func loadExtractingPredicatesArrayFromURL(url url:NSURL)-> ArrayOfPredicatesForExtracting?
    {
        guard let array = NSArray(contentsOfURL: url) where array.count > 0 else {return nil}
        return self.extractExtractingPredicatesArrayFromNSArray(array)
    }
    
    static func createArrayFromExtractedParametersToGroup(params params:StringsMatrix2D)->StringsArray1D
    {
        //create an array with the keys the params we extracted for grouping
        var arrayOfExtractedParametersToGroupBy = StringsArray1D()
        for parameter in params
        {
            arrayOfExtractedParametersToGroupBy.append(parameter[ParametersValueBoolColumnIndexes.ParametersIndex.rawValue])
        }
        return arrayOfExtractedParametersToGroupBy
        
    }

}
//you implement == type at GLOBAL level not within the body of the struct!!!
func ==(lhs: PredicateForExtracting, rhs: PredicateForExtracting) -> Bool {
    return  //(lhs.booleanOperator == rhs.booleanOperator)  && we ignore bool as u cant use the same search term in more than one bool type
        (lhs.columnNameToMatch == rhs.columnNameToMatch) &&
            (lhs.stringToMatch == rhs.stringToMatch)
}
func < (lhs: PredicateForExtracting, rhs: PredicateForExtracting) -> Bool {
    //phased approach. We test in precedence and ignore any unequalness below if the upper level is discordant
    // so it may be > at a lower level
    // we do this to ensure the ANDs cluster apart from ORs, COLUMNs from each other and so on
    if lhs.booleanOperator != rhs.booleanOperator
    {return lhs.booleanOperator < rhs.booleanOperator}
    if lhs.columnNameToMatch != rhs.columnNameToMatch
    {return lhs.columnNameToMatch < rhs.columnNameToMatch}
    return lhs.stringToMatch < rhs.stringToMatch
}

typealias ArrayOfPredicatesForExtracting = [PredicateForExtracting]

struct PredicatesByBoolean {
    var ANDpredicates = ArrayOfPredicatesForExtracting()
    var ORpredicates = ArrayOfPredicatesForExtracting()
    var NOTpredicates = ArrayOfPredicatesForExtracting()
    
}
