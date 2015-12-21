//
//  CSVdata_Grouping.swift
//  aecombiner
//
//  Created by David JM Lewis on 05/10/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Foundation


extension CSVdata
{
    // MARK: - Grouping Combining
    
    class func groupStartValueForString(groupMethod:String) -> Double
    {
        switch groupMethod
        {
        case kGroupAddition, kGroupLogSum, kGroupCount, kGroupMean, kGroupGeoMean, kGroupMax:
            return 0.0
        case kGroupMin:
            return Double(Int.max)
        case kGroupMultiplication:
            return 1.0
        default:
            return 0.0
        }
        
    }
    
    func nameForColumnsUsingGroupMethod(columnIndexesToGroup columnIndexesToGroup: NSIndexSet, groupMethod:String)->String
    {
        //join col names to make a mega name for the combination
        //make an array first
        var namesOfCombinedColumn = StringsArray1D()
        //let sortedindexes = CSVdata.sortedArrayOfIndexesFromNSIndexSet(indexes: columnIndexesToGroup)
        for columnIndex in columnIndexesToGroup
        {
            namesOfCombinedColumn.append(self.headersStringsArray1D[columnIndex])
        }
        //join the array members with the correct maths symbol
        var nameOfNewColumn:String = ""
        switch groupMethod
        {
        case kGroupAddition:
            nameOfNewColumn = "Sum("+namesOfCombinedColumn.joinWithSeparator("+")+")"
        case kGroupLogSum:
            nameOfNewColumn = "Log Sum("+namesOfCombinedColumn.joinWithSeparator("+")+")"
        case kGroupMultiplication:
            nameOfNewColumn = "Product("+namesOfCombinedColumn.joinWithSeparator("*")+")"
        case kGroupCount:
            nameOfNewColumn = "Count("+namesOfCombinedColumn.joinWithSeparator("_")+")"
        case kGroupMean:
            nameOfNewColumn = "Mean("+namesOfCombinedColumn.joinWithSeparator("+")+")"
        case kGroupGeoMean:
            nameOfNewColumn = "GeoMean("+namesOfCombinedColumn.joinWithSeparator("_")+")"
        case kGroupMin:
            nameOfNewColumn = "Min("+namesOfCombinedColumn.joinWithSeparator("_")+")"
        case kGroupMax:
            nameOfNewColumn = "Max("+namesOfCombinedColumn.joinWithSeparator("_")+")"
        case kGroupRange:
            nameOfNewColumn = "Range("+namesOfCombinedColumn.joinWithSeparator("_")+")"
        case kGroupLogRange:
            nameOfNewColumn = "Log Range("+namesOfCombinedColumn.joinWithSeparator("_")+")"
        case kGroupAllStats:
            nameOfNewColumn = namesOfCombinedColumn.joinWithSeparator("_")
        default:
            nameOfNewColumn = namesOfCombinedColumn.joinWithSeparator("?")
        }
        return nameOfNewColumn
    }
    
    func combineColumnsAndExtractToNewDocument(columnIndexForGrouping columnIndexForGrouping:Int, columnIndexesToGroup: NSIndexSet, arrayOfParamatersInGroup:StringsArray1D , groupMethod:String)
    {
        //extract the rows and present
        let combinedDataAndName = self.combinedColumnsAndNewColumnName_UsingSingleMethod(columnIndexForGrouping: columnIndexForGrouping, columnIndexesToGroup: columnIndexesToGroup, arrayOfParamatersInGroup: arrayOfParamatersInGroup, groupMethod: groupMethod)
        self.createNewDocumentFromExtractedRows(cvsData: combinedDataAndName.matrixOfData, headers: [self.headerStringForColumnIndex(columnIndexForGrouping),combinedDataAndName.nameOfData], name: combinedDataAndName.nameOfData+" by "+self.headerStringForColumnIndex(columnIndexForGrouping))
    }

    
    func combinedColumnsAndNewColumnName_UsingSingleMethod(columnIndexForGrouping columnIndexForGrouping:Int, columnIndexesToGroup: NSIndexSet, arrayOfParamatersInGroup:StringsArray1D , groupMethod:String) -> NamedDataMatrix//(csvDataMatrix:StringsMatrix2D, nameOfColumn:String)
    {
        switch groupMethod
        {
        case kGroupMean,kGroupGeoMean, kGroupRange, kGroupLogRange:
            return self.combinedColumnsAndNewColumnName_UsingSingleMethod_MeanRange(columnIndexForGrouping: columnIndexForGrouping, columnIndexesToGroup: columnIndexesToGroup, arrayOfParamatersInGroup: arrayOfParamatersInGroup, groupMethod: groupMethod)
        default:
            return self.combinedColumnsAndNewColumnName_UsingSingleMethod_CountSumMultiplyMaxMin(columnIndexForGrouping: columnIndexForGrouping, columnIndexesToGroup: columnIndexesToGroup, arrayOfParamatersInGroup: arrayOfParamatersInGroup, groupMethod: groupMethod)
        }
    }
    

    func combinedColumnsAndNewColumnName_UsingSingleMethod_MeanRange(columnIndexForGrouping columnIndexForGrouping:Int, columnIndexesToGroup: NSIndexSet, arrayOfParamatersInGroup:StringsArray1D , groupMethod:String) -> NamedDataMatrix//(csvDataMatrix:StringsMatrix2D, nameOfColumn:String)
    {
        //let sortedcolumnindexesToGroup = CSVdata.sortedArrayOfIndexesFromNSIndexSet(indexes: columnIndexesToGroup)
        
        let groupStartValue = CSVdata.groupStartValueForString(groupMethod)
        //create a dict with the keys the params we extracted for grouping
        //make a blank array to hold the values associated with the grouping for each member of the group
        var valuesForGroup = [String : (total:Double, count:Double)]()
        var rangesForGroup = [String : (minm:Double, maxm:Double)]()
        switch groupMethod
        {
        case kGroupMean, kGroupGeoMean:
            for parameter in arrayOfParamatersInGroup
            {
                valuesForGroup[parameter] = (groupStartValue,0.0)
            }
        case kGroupRange, kGroupLogRange:
            for parameter in arrayOfParamatersInGroup
            {
                rangesForGroup[parameter] = (CSVdata.groupStartValueForString(kGroupMin),CSVdata.groupStartValueForString(kGroupMax))
            }
        default:
            break
        }
        
        for row in 0..<self.numberOfRowsInData()
        {
            guard let paramID = self.stringValueForCell(fromColumn: columnIndexForGrouping, atRow: row) else {continue}
            for columnIndexInGroup in columnIndexesToGroup
            {
                guard let rowValS = self.stringValueForCell(fromColumn: columnIndexInGroup, atRow: row) else {continue}
                switch groupMethod
                {
                case kGroupRange, kGroupLogRange:
                    guard let running = rangesForGroup[paramID],
                        let value = Double(rowValS) else {continue}
                    rangesForGroup[paramID] = (fmin(running.minm, value), fmax(running.maxm,value))
                case kGroupMean:
                    guard let running = valuesForGroup[paramID],
                        let value = Double(rowValS) else {continue}
                    valuesForGroup[paramID] = (running.total + value, running.count + 1.0)
                case kGroupGeoMean:
                    guard let running = valuesForGroup[paramID],
                        let  value = Double(rowValS) where value > 0 else {continue} //geo mean cannot handle negative numbers
                    valuesForGroup[paramID] = (running.total +  log(value), running.count + 1.0)
                default:
                    break
                }
            }
        }
        
        //reprocess dict with the calculated value
        var processedDict = [String : Double]()
        
        switch groupMethod
        {
        case kGroupRange:
            for (key,value) in rangesForGroup
            {
                processedDict[key] = value.maxm-value.minm
            }
        case kGroupLogRange:
            for (key,value) in rangesForGroup
            {
                if value.maxm-value.minm > 0
                {
                    processedDict[key] = log(value.maxm-value.minm)
                }
                else
                {
                    processedDict[key] = kSubstituteValueForZeroInLogarithm // arbitrary value - log in user guide
                }
                
            }
        case kGroupMean, kGroupGeoMean:
            for (key,value) in valuesForGroup
            {
                switch groupMethod
                {
                case kGroupMean:
                    processedDict[key] = value.total/value.count
                case kGroupGeoMean:
                    processedDict[key] = exp(value.total/value.count)
                default:
                    break
                }
            }
        default:
            break
        }
        
        
        let nameOfNewColumn = self.nameForColumnsUsingGroupMethod(columnIndexesToGroup: columnIndexesToGroup, groupMethod: groupMethod)
        
        //createTheCSVdata
        var csvDataData = StringsMatrix2D()
        for (parameter,value) in processedDict
        {
            CSVdata.appendThisStringsArray1DToStringsMatrix2D(matrix2DToBeAppendedTo: &csvDataData, array1DToAppend: ([parameter, String(value)]))
        }
        
        return NamedDataMatrix(matrix:csvDataData, name:nameOfNewColumn)
        
    }
    
    
    func combinedColumnsAndNewColumnName_UsingSingleMethod_CountSumMultiplyMaxMin(columnIndexForGrouping columnIndexForGrouping:Int, columnIndexesToGroup: NSIndexSet, arrayOfParamatersInGroup:StringsArray1D , groupMethod:String) -> NamedDataMatrix//(csvDataMatrix:StringsMatrix2D, nameOfColumn:String)
    {
        //let sortedcolumnindexesToGroup = CSVdata.sortedArrayOfIndexesFromNSIndexSet(indexes: columnIndexesToGroup)
        let groupStartValue = CSVdata.groupStartValueForString(groupMethod)
        //create a dict with the keys the params we extracted for grouping
        //make a blank array to hold the values associated with the grouping for each member of the group
        //Doubles for adding and multiplying, Ints for counting - to avoud decimal places in counts string
        var valuesForGroup = [String : Double]()
        var countsForGroup = [String : Int]()
        switch groupMethod
        {
        case kGroupAddition, kGroupLogSum, kGroupMultiplication, kGroupMax, kGroupMin:
            for parameter in arrayOfParamatersInGroup
            {
                valuesForGroup[parameter] = groupStartValue
            }
        case kGroupCount:
            for parameter in arrayOfParamatersInGroup
            {
                countsForGroup[parameter] = Int(groupStartValue)
            }
        default:
            break
        }
        
        for row in 0..<self.numberOfRowsInData()
        {
            guard let paramID = self.stringValueForCell(fromColumn: columnIndexForGrouping, atRow: row) else {continue}
            for columnIndexInGroup in columnIndexesToGroup
            {
               guard let rowValS = self.stringValueForCell(fromColumn: columnIndexInGroup, atRow: row) else {continue}
               switch groupMethod
                {
                case kGroupMin:
                    guard let running = valuesForGroup[paramID],
                        let value = Double(rowValS) else {continue}
                    valuesForGroup[paramID] = fmin(running, value)
                case kGroupMax:
                    guard let running = valuesForGroup[paramID],
                        let value = Double(rowValS) else {continue}
                    valuesForGroup[paramID] = fmax(running, value)
                case kGroupAddition:
                    guard let running = valuesForGroup[paramID],
                        let value = Double(rowValS) else {continue}
                    valuesForGroup[paramID] = running + value
                case kGroupLogSum:
                    guard let running = valuesForGroup[paramID],
                        let value = Double(rowValS)
                        where value > 0
                        else {continue}
                    valuesForGroup[paramID] = running + log(value)
                case kGroupMultiplication:
                    guard let running = valuesForGroup[paramID],
                        let value = Double(rowValS) else {continue}
                    valuesForGroup[paramID] = running * value
                case kGroupCount:
                    guard let running = countsForGroup[paramID],
                        let _ = Double(rowValS) else {continue}
                    countsForGroup[paramID] = running + 1
                default:
                    break
                }
            }
        }
        
        let nameOfNewColumn = self.nameForColumnsUsingGroupMethod(columnIndexesToGroup: columnIndexesToGroup, groupMethod: groupMethod)
        
        //createTheCSVdata
        var csvDataData = StringsMatrix2D()
        switch groupMethod
        {
        case kGroupAddition, kGroupLogSum, kGroupMultiplication, kGroupMin, kGroupMax:
            for (parameter,value) in valuesForGroup
            {
                CSVdata.appendThisStringsArray1DToStringsMatrix2D(matrix2DToBeAppendedTo: &csvDataData, array1DToAppend: ([parameter, String(value)]))

            }
        case kGroupCount:
            for (parameter,value) in countsForGroup
            {
                CSVdata.appendThisStringsArray1DToStringsMatrix2D(matrix2DToBeAppendedTo: &csvDataData, array1DToAppend: ([parameter, String(value)]))
            }
        default:
            break
        }
        
        
        return NamedDataMatrix(matrix:csvDataData, name:nameOfNewColumn)
    }
    
    func combinedColumnsAndNewColumnName_UsingAllMethods(columnIndexForGrouping columnIndexForGrouping:Int, columnIndexesToGroup: NSIndexSet, columnIndexToRecord:Int?)->CSVdata//(cvsdata:CSVdata, name:String)
    {
        guard let arrayOfParamatersInColumnToGroupBy = self.stringsArray1DOfParametersFromColumn(fromColumn: columnIndexForGrouping, replaceBlank: true)
            else {return CSVdata()}
        
        //create a dict with the keys the params we extracted for grouping
        //make a blank array to hold the values associated with the grouping for each member of the group
        //Doubles for adding and multiplying, Ints for counting - to avoud decimal places in counts string
        var statsForGroup = [String : AggregatedStats]()
        for parameter in arrayOfParamatersInColumnToGroupBy
        {
            statsForGroup[parameter] = AggregatedStats()
        }
 
        //let sortedcolumnindexesToGroup = CSVdata.sortedArrayOfIndexesFromNSIndexSet(indexes: columnIndexesToGroup)

        for row in 0..<self.numberOfRowsInData()
        {
            guard let paramID = self.stringValueForCell(fromColumn: columnIndexForGrouping, atRow: row) else {continue}
            for columnIndexInGroup in columnIndexesToGroup
            {
                guard
                    let rowValS = self.stringValueForCell(fromColumn: columnIndexInGroup, atRow: row),
                    var running = statsForGroup[paramID]
                else {continue}
                
                guard
                    let value = Double(rowValS)
                else {running.skippedValues++; continue}
                
                running.minm = fmin(running.minm, value)
                running.maxm = fmax(running.maxm, value)
                running.sum += value
                running.product *= value
                running.count += 1
                if value > 0
                {
                    running.logSum += log(value)
                    running.logCount += 1
                }
                else { running.skippedLogs++ }
                
                //add recording
                if columnIndexToRecord != nil && self.stringValueForCell(fromColumn: columnIndexToRecord!, atRow: row) != nil
                {
                    running.recordedValues.append([self.stringValueForCell(fromColumn: columnIndexToRecord!, atRow: row)!:value])
                }

                //allocate
                statsForGroup[paramID] = running
                print(running.recordedValues)
            }
        }
        let nameOfColumn:String = self.nameForColumnsUsingGroupMethod(columnIndexesToGroup: columnIndexesToGroup, groupMethod: kGroupAllStats)
        let headers:StringsArray1D = [self.headerStringForColumnIndex(columnIndexForGrouping),"Count("+nameOfColumn+")","Sum("+nameOfColumn+")","Log Sum("+nameOfColumn+")","Product("+nameOfColumn+")","Max("+nameOfColumn+")","Min("+nameOfColumn+")","Range("+nameOfColumn+")","Log Range("+nameOfColumn+")","Mean("+nameOfColumn+")","GeoMean("+nameOfColumn+")","Skipped Values("+nameOfColumn+")","Skipped Logs("+nameOfColumn+")"]
        
        //createTheCSVdata
        var finalDatamatrix = StringsMatrix2D()
        for (parameter,stats) in statsForGroup
        {
            var rowS = StringsArray1D()
            rowS.append(parameter)
            rowS.append(String(stats.count))
            rowS.append(String(stats.sum))
            rowS.append(String(stats.logSum))
            rowS.append(String(stats.product))
            rowS.append(String(stats.maxm))
            rowS.append(String(stats.minm))
            rowS.append(String(stats.maxm-stats.minm))
            if stats.maxm-stats.minm > 0
            {
                rowS.append(String(log(stats.maxm-stats.minm)))
            }
            else
            {
                rowS.append("max-min<=0")
            }
            rowS.append(String(stats.sum/Double(stats.count)))
            rowS.append(String(exp(stats.logSum/Double(stats.logCount))))
            rowS.append(String(stats.skippedValues))
            rowS.append(String(stats.skippedLogs))
            CSVdata.appendThisStringsArray1DToStringsMatrix2D(matrix2DToBeAppendedTo: &finalDatamatrix, array1DToAppend: rowS)
        }
        return CSVdata(headers: headers, csvdata: finalDatamatrix, name: nameOfColumn)
    }
    
    func combineColumnsAndExtractAllStatsToNewDocument(columnIndexForGrouping columnIndexForGrouping:Int, columnIndexesToGroup: NSIndexSet, columnIndexToRecord:Int?)
    {
        // check OK to group
        guard
            columnIndexForGrouping >= 0 &&
                columnIndexForGrouping < self.numberOfColumnsInData() &&
                columnIndexesToGroup.count > 0
            
            else {return}
        
        
        //extract the rows and present
        let stats = self.combinedColumnsAndNewColumnName_UsingAllMethods(columnIndexForGrouping: columnIndexForGrouping, columnIndexesToGroup: columnIndexesToGroup, columnIndexToRecord: columnIndexToRecord)
        
        CSVdata.createNewDocumentFromCVSDataAndColumnName(cvsData: stats, name: "All Stats("+stats.name+") by "+self.headerStringForColumnIndex(columnIndexForGrouping))
    }



}