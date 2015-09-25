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

class RecodeColumnViewController: HeadingsViewController {
    

    // MARK: - class vars
    var arrayExtractedParameters = DataMatrix()

    // MARK: - class constants
    
    
    // MARK: - @IBOutlet

    @IBOutlet weak var tvExtractedParameters: NSTableView!
    @IBOutlet weak var labelNumberOfParameterOrGroupingItems: NSTextField!

    @IBOutlet weak var segmentedSortAsTextOrNumbers: NSSegmentedControl!
    //@IBOutlet weak var segmentedSortParameterOrValue: NSSegmentedControl!
    
    @IBOutlet weak var popupHeaders: NSPopUpButton!
 
    
    // MARK: - @IBAction


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
        self.tvExtractedParameters?.reloadData()
    }

    // MARK: - header Popups
    func populateHeaderPopups()
    {
        guard let csvdo = self.associatedCSVdataViewController else { return}
        self.popupHeaders.removeAllItems()
        self.popupHeaders.addItemsWithTitles(csvdo.headerStringsForAllColumns())
        self.popupHeaders.selectItemAtIndex(-1)
    }
    
    func popupChangedSelection(popup: NSPopUpButton)
    {
        switch popup
        {
        case self.popupHeaders:
            self.resetExtractedParameters()
            self.extractParametersIntoSetFromColumn()
            self.textFieldColumnRecodedName?.stringValue = self.headerStringForColumnIndex(popup.indexOfSelectedItem)
        default:
            break
        }
    }
    

    // MARK: - TableView overrides

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
            self.arrayExtractedParameters[control.tag][1] = str
        default:
            break
        }
        return true
    }
    

    override func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        switch tableView
        {
        case self.tvExtractedParameters:
            self.labelNumberOfParameterOrGroupingItems.stringValue = "\(self.arrayExtractedParameters.count) parameters"
            return self.arrayExtractedParameters.count
        default:
            return 0
        }
    }
    
    override func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // Retrieve to get the @"MyView" from the pool or,
        // if no version is available in the pool, load the Interface Builder version
        var cellView = NSTableCellView()
        switch tableView
        {
        case self.tvExtractedParameters:
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
    
    
    override func tableViewSelectionDidChange(notification: NSNotification) {
        guard let tableView = (notification.object as? NSTableView) else {return}
        switch tableView
        {
      default:
            break;
        }
        
    }
    
    // MARK: - Sorting Tables on header click
    override func tableView(tableView: NSTableView, mouseDownInHeaderOfTableColumn tableColumn: NSTableColumn) {
        // inheriteds override
        switch tableView
        {
        case self.tvExtractedParameters:
            self.sortParametersOrValuesInTableViewColumn(tableView: tableView, tableColumn: tableColumn, arrayToSort: &self.arrayExtractedParameters, textOrValue: self.segmentedSortAsTextOrNumbers.selectedSegment)
            self.tvExtractedParameters.reloadData()
        default: break
        }
        
    }

    
    // MARK: - Column parameters
    func stringForRecodedColumn(columnIndex:Int) -> String
    {
        return self.headerStringForColumnIndex(columnIndex)+kStringRecodedColumnNameSuffix
    }
    
    
    func resetExtractedParameters()
    {
        self.arrayExtractedParameters = DataMatrix()
        self.tvExtractedParameters?.reloadData()
        self.textFieldColumnRecodedName?.stringValue = ""
        self.labelNumberOfParameterOrGroupingItems?.stringValue = ""
    }
    
    
    
    
    func extractParametersIntoSetFromColumn()
    {
        //called from Process menu
        guard   let csvdo = self.associatedCSVdataViewController,
                let dmOfParams = csvdo.dataMatrixOfParametersFromColumn(fromColumn: self.popupHeaders.indexOfSelectedItem)
            else { return }
        
        self.arrayExtractedParameters = dmOfParams
        self.tvExtractedParameters.reloadData()
        
    }
    
    func doTheRecodeParametersAndAddNewColumn()
    {
        guard self.arrayExtractedParameters.count > 0  else {return}
        guard   let csvVC = self.associatedCSVdataViewController,
                let columnIndex = self.requestedColumnIndexIsOK(self.popupHeaders.indexOfSelectedItem)
                else {return}
        //give a name if none
        let colTitle = self.textFieldColumnRecodedName!.stringValue.isEmpty ? self.stringForRecodedColumn(columnIndex) : self.textFieldColumnRecodedName!.stringValue

        //pass it over
        csvVC.addRecodedColumn(withTitle: colTitle, fromColum: columnIndex, usingParamsArray: self.arrayExtractedParameters)
        
        //reload etc
        self.resetExtractedParameters()
        self.popupHeaders.selectItemAtIndex(-1)
        
    }

}

