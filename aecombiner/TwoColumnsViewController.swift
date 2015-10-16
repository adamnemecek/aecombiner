//
//  TwoColumnsViewController.swift
//  aecombiner
//
//  Created by David JM Lewis on 15/10/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa

class TwoColumnsViewController: ColumnsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
    override func chartSelectedDataSet()
    {
        guard
            let chartviewC = self.chartViewController,
            let csvdatamodel = self.associatedCSVmodel
            else {return}
        if self.tvHeaders.selectedRowIndexes.count == 2
        {
            let dataSet = csvdatamodel.chartDataSetFromColumnIndexes(columnIndexes: self.tvHeaders.selectedRowIndexes)
            chartviewC.plotNewChartDataSet(dataSet: dataSet, nameOfChartDataSet: csvdatamodel.headerStringForColumnIndex(self.tvHeaders.selectedRow))
        }
        
    }
    
    override func tableViewSelectionDidChange(notification: NSNotification) {
        guard let tableView = (notification.object as? NSTableView) else {return}
        
        switch tableView
        {
        case self.tvHeaders:
            self.enableButtons(enabled: tableView.selectedRowIndexes.count == 2)
        default:
            break
        }
    }

}
