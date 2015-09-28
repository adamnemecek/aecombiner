//
//  ViewController.swift
//  aecombiner
//
//  Created by David JM Lewis on 25/06/2015.
//  Copyright (c) 2015 djml.eu. All rights reserved.
//

import Cocoa

let kParametersArrayParametersIndex = 0
let kParametersArrayParametersValueIndex = 1
let kSelectedParametersArrayColumnIndex = 0
let kSelectedParametersArrayParameterIndex = 1
let kStringEmpty = "- Empty -"
let kStringRecodedColumnNameSuffix = "_#_"

class RecodeColumnViewController: ColumnSortingChartingViewController, NSTabViewDelegate {
    

    // MARK: - class vars
    var arrayExtractedParameters = MulticolumnStringsArray()

    // MARK: - class constants
    
    
    // MARK: - @IBOutlet

    @IBOutlet weak var tvExtractedParametersSingle: NSTableView!
    @IBOutlet weak var tvExtractedParametersMultiple: NSTableView!
    @IBOutlet weak var labelNumberOfParameterOrGroupingItems: NSTextField!
    @IBOutlet weak var textFieldColumnRecodedName: NSTextField!

    @IBOutlet weak var tabbedVrecoding: NSTabView!
    
    @IBOutlet weak var popupHeaders: NSPopUpButton!
 
    @IBOutlet weak var buttonSetValue: NSButton!
    @IBOutlet weak var textFieldSetValue: NSTextField!
    
    // MARK: - @IBAction

    @IBAction func setValueTapped(sender: NSButton) {
        self.setValueForSelectedRows()
    }

    @IBAction func recodeParametersAndAddNewColumn(sender: AnyObject) {
        self.doTheRecodeParametersAndAddNewColumn()
    }
    
    @IBAction func popupHeadersButtonSelected(sender: NSPopUpButton) {
        self.popupChangedSelection(sender)
    }

    // MARK: - overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        
        
    }
    override func viewWillAppear() {
        super.viewWillAppear()
        // Do any additional setup after loading the view.
        self.populateHeaderPopups()
        self.tvExtractedParametersSingle?.reloadData()
        self.tvExtractedParametersMultiple?.reloadData()
   }

    // MARK: - header Popups
    func populateHeaderPopups()
    {
        guard let csvdm = self.associatedCSVmodel else { return}
        self.popupHeaders.removeAllItems()
        self.popupHeaders.addItemsWithTitles(csvdm.headerStringsForAllColumns())
        self.popupHeaders.selectItemAtIndex(-1)
    }
    
    func popupChangedSelection(popup: NSPopUpButton)
    {
        switch popup
        {
        case self.popupHeaders:
            guard
                let csvdatamodel = self.associatedCSVmodel
            else {return}
            self.resetExtractedParameters(andPopupHeaders: false)
            self.extractParametersIntoSetFromColumn()
            self.textFieldColumnRecodedName?.stringValue = csvdatamodel.headerStringForColumnIndex(popup.indexOfSelectedItem)
        default:
            break
        }
    }
    

    // MARK: - TableView Control

    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        guard let ident = control.identifier else {
            return true
        }
        switch ident
        {
        case "parametersValueCellTextField":
            guard control.tag < self.arrayExtractedParameters.count,
            let str = fieldEditor.string else
            {
                break
            }
            self.arrayExtractedParameters[control.tag][kParametersArrayParametersValueIndex] = str
        default:
            break
        }
        return true
    }
    
    func setValueForSelectedRows()
    {
        let valueS = self.textFieldSetValue.stringValue
        for index in self.tvExtractedParametersMultiple.selectedRowIndexes
        {
            self.arrayExtractedParameters[index][kParametersArrayParametersValueIndex] = valueS
        }
        self.tvExtractedParametersMultiple.reloadData()
    }

    // MARK: - TableView overrides
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        switch tableView
        {
        case self.tvExtractedParametersSingle, tvExtractedParametersMultiple:
            self.labelNumberOfParameterOrGroupingItems.stringValue = "\(self.arrayExtractedParameters.count) parameters"
            return self.arrayExtractedParameters.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // Retrieve to get the @"MyView" from the pool or,
        // if no version is available in the pool, load the Interface Builder version
        var cellView = NSTableCellView()
        switch tableView
        {
        case self.tvExtractedParametersSingle, tvExtractedParametersMultiple:
                switch tableColumn!.identifier
                {
                case "parameter":
                    cellView = tableView.makeViewWithIdentifier("parametersCell", owner: self) as! NSTableCellView
                    cellView.textField!.stringValue = self.arrayExtractedParameters[row][kParametersArrayParametersIndex]
                case "value"://parameters
                    cellView = tableView.makeViewWithIdentifier("parametersValueCell", owner: self) as! NSTableCellView
                    cellView.textField!.stringValue = self.arrayExtractedParameters[row][kParametersArrayParametersValueIndex]
                    cellView.textField!.tag = row
                default:
                    break
                }
            
            default:
                break;
            }

        
        // Return the cellView
        return cellView;
    }
    
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        guard let tableView = (notification.object as? NSTableView) else {return}
        switch tableView
        {
            case self.tvExtractedParametersMultiple:
                self.enableSetValueControls(tableView.selectedRowIndexes.count>0)
            default:
                break;
        }
        
    }
    
    func enableSetValueControls(enabled:Bool)
    {
        self.buttonSetValue.enabled = enabled
        self.textFieldSetValue.enabled = enabled
        self.textFieldSetValue.stringValue = ""
    }
    
    // MARK: - Sorting Tables on header click
    override func tableView(tableView: NSTableView, mouseDownInHeaderOfTableColumn tableColumn: NSTableColumn) {
        // inheriteds override
        switch tableView
        {
        case self.tvExtractedParametersSingle, tvExtractedParametersMultiple:
            tableView.sortParametersOrValuesInTableViewColumn(tableColumn: tableColumn, arrayToSort: &self.arrayExtractedParameters, textOrValue: self.segmentedSortAsTextOrNumbers.selectedSegment)
            self.tvExtractedParametersSingle.reloadData()
            self.tvExtractedParametersMultiple.reloadData()
        default: break
        }
        
    }

    // MARK: - Tabbed View

    func tabView(tabView: NSTabView, didSelectTabViewItem tabViewItem: NSTabViewItem?) {
        self.resetExtractedParameters(andPopupHeaders: true)
    }
    
    // MARK: - Column parameters
    func stringForRecodedColumn(columnIndex:Int) -> String
    {
        guard
            let csvdatamodel = self.associatedCSVmodel
            else {return "????"}

        return csvdatamodel.headerStringForColumnIndex(columnIndex)+kStringRecodedColumnNameSuffix
    }
    
    
    func resetExtractedParameters(andPopupHeaders andPopupHeaders:Bool)
    {
        self.arrayExtractedParameters = MulticolumnStringsArray()
        self.tvExtractedParametersSingle?.reloadData()
        self.tvExtractedParametersMultiple?.reloadData()
        self.textFieldColumnRecodedName?.stringValue = ""
        self.labelNumberOfParameterOrGroupingItems?.stringValue = ""
        self.enableSetValueControls(false)
        if andPopupHeaders
        {
            self.popupHeaders.selectItemAtIndex(-1)
        }
        
    }
    
    
    
    
    func extractParametersIntoSetFromColumn()
    {
        //called from Process menu
        guard   let datamodel = self.associatedCSVmodel,
                let dmOfParams = datamodel.dataMatrixOfParametersFromColumn(fromColumn: self.popupHeaders.indexOfSelectedItem)
            else { return }
        
        self.arrayExtractedParameters = dmOfParams
        self.tvExtractedParametersSingle.reloadData()
        self.tvExtractedParametersMultiple.reloadData()

    }
    
    func doTheRecodeParametersAndAddNewColumn()
    {
        guard self.arrayExtractedParameters.count > 0  else {return}
        guard   let csvdo = self.associatedCSVmodel,
                let csvdVC = self.associatedCSVdataViewController,
                let columnIndex = csvdo.validatedColumnIndex(self.popupHeaders.indexOfSelectedItem)
                else {return}
        //give a name if none
        let colTitle = self.textFieldColumnRecodedName!.stringValue.isEmpty ? self.stringForRecodedColumn(columnIndex) : self.textFieldColumnRecodedName!.stringValue

        //pass it over
        csvdVC.addRecodedColumn(withTitle: colTitle, fromColum: columnIndex, usingParamsArray: self.arrayExtractedParameters)
        
        //reload etc
        self.resetExtractedParameters(andPopupHeaders: true)
        
    }

}

