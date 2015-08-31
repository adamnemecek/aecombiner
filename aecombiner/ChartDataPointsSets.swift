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
    
    convenience init(data: DataMatrix, forColumnIndex columnIndex:Int)
    {
        self.init()
        guard columnIndex>0 && columnIndex<data.count else {return}
        
        for var r:Int = 0; r<data.count; r++
        {
            let row = data[r]
            guard
                row[columnIndex].characters.count>0,
                let Yvalue = Double(row[columnIndex])
                else {continue}
            let Xvalue = Double(r)
            self.minYvalue = fmin(self.minYvalue,Yvalue)
            self.maxYvalue = fmax(self.maxYvalue,Yvalue)
            self.minXvalue = fmin(self.minXvalue,Xvalue)
            self.maxXvalue = fmax(self.maxXvalue,Xvalue)
            // we store the row number as the X value and when we sort on the Y value we can always map back to the row in the data for extracting other values. !! If we sort the CSVdata we are lost
            self.dataPoints.append(ChartDataPoint(xvalue: Xvalue, yvalue: Yvalue))
        }
    }
}

