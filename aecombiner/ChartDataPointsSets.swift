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


struct ChartDataPoint {
    var xValue:Double
    var yValue:Double
    
    init (xvalue:Double, yvalue:Double)
    {
        xValue = xvalue // usually the row in the data model
        yValue = yvalue
    }
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
        
        var hadErrors = 0
        for rowN in 0..<data[columnIndex].count
        {
            let valS = data[columnIndex][rowN]
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
            self.dataPoints.append(ChartDataPoint(xvalue: Xvalue, yvalue: Yvalue))
        }
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

