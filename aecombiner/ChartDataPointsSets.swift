//
//  ChartDataPointsSets.swift
//  aecombiner
//
//  Created by David Lewis on 31/08/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Foundation

let kDataSetDefaultName = "Untitled"


struct ChartDataPointsFromNode {
    var chartDataPoints: ChartDataPointsArray
    var nodeName:String
    init(dataPoints: ChartDataPointsArray, name:String)
    {
        chartDataPoints = dataPoints
        nodeName = name
    }
}

typealias ChartDataPointsArray = [ChartDataPoint]

struct CellCoordinate
{
    var column: Int
    var row: Int
}

struct ChartDataPoint {
    var xValue:Double
    var yValue:Double
    var colY: Int?
    var colX: Int?

    /*
    init (xvalue:Double, yvalue:Double, celly: CellCoordinate, cellx: CellCoordinate)
    {
        xValue = xvalue // usually the row in the data model
        yValue = yvalue
        cellY = celly
        cellX = cellx
    }
    */
}

class ChartDataSet {
    var maxYvalue:Double = 0.0
    var minYvalue:Double = Double(Int.max)
    var maxXvalue:Double = 0.0
    var minXvalue:Double = Double(Int.max)
    var dataPoints = ChartDataPointsArray()
    var nameOfDataSet:String = kDataSetDefaultName
    
    convenience init(data: StringsMatrix2D, forColumnIndex columnIndex:Int)
    {
        self.init()
        guard data.count > 0 && data[0].count > 0 else {
            GlobalUtilities.alertWithMessage("No data to chart",style: .WarningAlertStyle)
            return}
        
        guard columnIndex>=0 && columnIndex < data.count else {
            GlobalUtilities.alertWithMessage("The data does not have the column you want to chart",style: .WarningAlertStyle)
            return}
        
        self.alertIfErrors(self.createSetFromColumnWithErrors(data: data, columnIndex: columnIndex))
    }
    
    convenience init(data: StringsMatrix2D, columnIndexY:Int, columnIndexX:Int)
    {
        self.init()
        guard data.count > 0 && data[0].count > 0 else {
            GlobalUtilities.alertWithMessage("No data to chart",style: .WarningAlertStyle)
            return}
        
        guard columnIndexY>=0 && columnIndexY < data.count && columnIndexX>=0 && columnIndexX < data.count
            else {GlobalUtilities.alertWithMessage("The data does not have the column you want to chart",style: .WarningAlertStyle); return}
        
        self.alertIfErrors(self.createSetFromTwoColumnsWithErrors(data: data, columnIndexY: columnIndexY, columnIndexX: columnIndexX))
    }
    
    func createSetFromColumnWithErrors(data data: StringsMatrix2D, columnIndex:Int)->Int
    {
        var hadErrors = 0
        for rowN in 0..<data.count
        {
            let valS = data[rowN][columnIndex]
            guard
                !valS.isEmpty,
                let Yvalue = Double(valS)
                else {hadErrors++ ; continue}
            let Xvalue = Double(rowN)
            self.minYvalue = fmin(self.minYvalue,Yvalue)
            self.maxYvalue = fmax(self.maxYvalue,Yvalue)
            self.minXvalue = fmin(self.minXvalue,Xvalue)
            self.maxXvalue = fmax(self.maxXvalue,Xvalue)
            // we store the row number as the X value and when we sort on the Y value we can always map back to the row in the data for extracting other values. !! If we sort the CSVdata we are lost
            let point = ChartDataPoint(xValue: Xvalue, yValue: Yvalue, colY: columnIndex, colX: nil)
            self.dataPoints.append(point)
        }
        return hadErrors
    }
    
    func createSetFromTwoColumnsWithErrors(data data: StringsMatrix2D, columnIndexY:Int, columnIndexX:Int)->Int
    {
        var hadErrors = 0
        for rowN in 0..<data.count
        {
            let valY = data[rowN][columnIndexY]
            let valX = data[rowN][columnIndexX]
            guard
                !valY.isEmpty && !valX.isEmpty,
                let Yvalue = Double(valY),
                let Xvalue = Double(valX)
                else {hadErrors++ ; continue}
            self.minYvalue = fmin(self.minYvalue,Yvalue)
            self.maxYvalue = fmax(self.maxYvalue,Yvalue)
            self.minXvalue = fmin(self.minXvalue,Xvalue)
            self.maxXvalue = fmax(self.maxXvalue,Xvalue)
            // we store the row number as the X value and when we sort on the Y value we can always map back to the row in the data for extracting other values. !! If we sort the CSVdata we are lost
            let point = ChartDataPoint(xValue: Xvalue, yValue: Yvalue, colY: columnIndexY, colX: columnIndexX)
            self.dataPoints.append(point)
            print("ValX \(valX), minXvalue \(minXvalue), maxXvalue \(maxXvalue) --  ValY \(valY), minYvalue \(minYvalue), maxYvalue \(maxYvalue)")
        }
        return hadErrors
    }
    
    func alertIfErrors(hadErrors:Int)
    {
        if hadErrors>0
        {
            if self.dataPoints.count == 0
            {
                GlobalUtilities.alertWithMessage("No values could be detected\nData must be numeric to be charted",style: .WarningAlertStyle)
            }
            else
            {
                if hadErrors == 1
                {
                    GlobalUtilities.alertWithMessage("One value was rejected",style: .WarningAlertStyle)
                }
                else
                {
                    GlobalUtilities.alertWithMessage("\(hadErrors) values were rejected",style: .WarningAlertStyle)
                }
            }
            
        }
    }
}

