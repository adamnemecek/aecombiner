//
//  ViewController.swift
//  aecombiner
//
//  Created by David JM Lewis on 25/06/2015.
//  Copyright (c) 2015 djml.eu. All rights reserved.
//

import Cocoa


let kParametersArray_ParametersIndex = 0
let kParametersArray_ValueIndex = 1
let kParametersArray_BooleanIndex = 2
let kSelectedParametersArrayColumnIndex = 0
let kSelectedParametersArrayParameterIndex = 1
let kStringEmpty = "- Empty -"
let kStringRecodedColumnNameSuffix = "_#_"

class RecodeColumnViewController: ColumnSortingChartingViewController, NSTabViewDelegate {
    

    // MARK: - class vars
    var arrayExtractedParameters =  MulticolumnStringsArray()

    // MARK: - class constants
    
    
    // MARK: - @IBOutlet

    @IBOutlet weak var tvExtractedParametersSingle: NSTableView!
    @IBOutlet weak var tvExtractedParametersMultiple: NSTableView!
    @IBOutlet weak var tvExtractedParametersPredicate: NSTableView!
    @IBOutlet weak var labelNumberOfParameterOrGroupingItems: NSTextField!
    
    @IBOutlet weak var textFieldSetValue: NSTextField!
    @IBOutlet weak var textFieldColumnRecodedName: NSTextField!
    @IBOutlet weak var textFieldBooleanComparator: NSTextField!

    @IBOutlet weak var tabbedVrecoding: NSTabView!
    
    @IBOutlet weak var popupHeaders: NSPopUpButton!
    @IBOutlet weak var popupBooleans: NSPopUpButton!
 
    @IBOutlet weak var buttonOverwite: NSButton!
    @IBOutlet weak var buttonSetValue: NSButton!
    @IBOutlet weak var buttonRecodeTo: NSButton!
    
    
    @IBOutlet weak var progressSetValue: NSProgressIndicator!
    
    @IBOutlet weak var checkboxCopyUnmatchedValues: NSButton!
    
    // MARK: - @IBAction

    @IBAction func setValueTapped(sender: NSButton) {
        self.setValueForSelectedRows()
        self.enableSetValueControls(false)
    }

    @IBAction func buttonRecodeToTapped(sender: AnyObject) {
        
        //let predString = self.popupBooleans.titleOfSelectedItem
        //let valS = self.textFieldBooleanComparator.stringValue
        //let pred = NSPredicate(
        
    }
    
    @IBAction func recodeParametersAndAddNewColumn(sender: AnyObject) {
        self.doTheRecodeParametersAndAddNewColumn()
    }
    
    @IBAction func recodeOverwriteTapped(sender: AnyObject) {
        self.doRecodeOverwrite()
    }
    
    @IBAction func popupHeadersButtonSelected(sender: NSPopUpButton) {
        self.popupChangedSelection(sender)
    }

    @IBAction func checkboxRecodeTapped(sender: NSButton) {
        self.doCheckBoxRecodeTapped(sender: sender)
    }
    
    @IBAction func checkBoxToggleRecodeStatusTapped(sender: NSButton) {
        self.toggleExtractedParametersArrayrecodeStatus(sender.state)
    }
    
    func toggleExtractedParametersArrayrecodeStatus(state:NSCellStateValue)
    {
        for row in 0..<self.arrayExtractedParameters.count
        {
            self.arrayExtractedParameters[row][kParametersArray_BooleanIndex] = String(state)
        }
        self.tvExtractedParametersSingle.reloadData()
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
        self.reloadTables()
   }

    func reloadTables()
    {
        self.tvExtractedParametersSingle?.reloadData()
        self.tvExtractedParametersMultiple?.reloadData()
        self.tvExtractedParametersPredicate?.reloadData()

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
    func doCheckBoxRecodeTapped(sender sender: NSButton)
    {
        guard let ident = sender.identifier else {return}
        switch ident
        {
        case "checkBoxRecode":
            guard sender.tag < self.arrayExtractedParameters.count else {break}
            self.arrayExtractedParameters[sender.tag][kParametersArray_BooleanIndex] = String(sender.state)
        default:
            break
        }
    }
    

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
            self.arrayExtractedParameters[control.tag][kParametersArray_ValueIndex] = str
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
            self.arrayExtractedParameters[index][kParametersArray_ValueIndex] = valueS
        }
        self.reloadTables()
    }

    // MARK: - TableView overrides
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        switch tableView
        {
        case self.tvExtractedParametersSingle, tvExtractedParametersMultiple, tvExtractedParametersPredicate:
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
        case self.tvExtractedParametersSingle, tvExtractedParametersMultiple, tvExtractedParametersPredicate:
                switch tableColumn!.identifier
                {
                case "parameter":
                    cellView = tableView.makeViewWithIdentifier("parametersCell", owner: self) as! NSTableCellView
                    cellView.textField!.stringValue = self.arrayExtractedParameters[row][kParametersArray_ParametersIndex]
                case "value"://parameters
                    cellView = tableView.makeViewWithIdentifier("parametersValueCell", owner: self) as! NSTableCellView
                    cellView.textField!.stringValue = self.arrayExtractedParameters[row][kParametersArray_ValueIndex]
                    cellView.textField!.tag = row
                case "bool"://parameters
                    cellView = tableView.makeViewWithIdentifier("parametersBoolCell", owner: self) as! NSTableCellView
                    for subview in cellView.subviews
                    {
                        guard
                        let box = (subview as? NSButton),
                        let value = NSCellStateValue(self.arrayExtractedParameters[row][kParametersArray_BooleanIndex])
                        else {continue}
                        box.tag = row
                        box.state =  value//== "true" ? NSOnState : NSOffState
                    }
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
        self.textFieldSetValue.resignFirstResponder()
    }
    
    
    
    // MARK: - Sorting Tables on header click
    override func tableView(tableView: NSTableView, mouseDownInHeaderOfTableColumn tableColumn: NSTableColumn) {
        // inheriteds override
        switch tableView
        {
        case self.tvExtractedParametersSingle, tvExtractedParametersMultiple, tvExtractedParametersPredicate:
            tableView.sortParametersOrValuesInTableViewColumn(tableColumn: tableColumn, arrayToSort: &self.arrayExtractedParameters, textOrValue: self.segmentedSortAsTextOrNumbers.selectedSegment)
            self.reloadTables()
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
        self.reloadTables()
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
        self.reloadTables()

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
        csvdVC.addRecodedColumn(withTitle: colTitle, fromColum: columnIndex, usingParamsArray: self.arrayExtractedParameters, copyUnmatchedValues:self.checkboxCopyUnmatchedValues.state == NSOnState)
        
        //reload etc
        
        self.resetExtractedParameters(andPopupHeaders: true)
        
    }
    
    func doRecodeOverwrite()
    {
        guard self.arrayExtractedParameters.count > 0  else { return}
        guard
            let csvdo = self.associatedCSVmodel,
            let csvdVC = self.associatedCSVdataViewController,
            let columnIndex = csvdo.validatedColumnIndex(self.popupHeaders.indexOfSelectedItem)
            else {return}

        
        //pass it over
        csvdVC.recodeColumnInSitu(columnToRecode:columnIndex, usingParamsArray: self.arrayExtractedParameters, copyUnmatchedValues:self.checkboxCopyUnmatchedValues.state == NSOnState)
        
        //reload etc
        
        self.resetExtractedParameters(andPopupHeaders: true)
        
    }


}

