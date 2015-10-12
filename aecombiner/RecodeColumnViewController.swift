//
//  ViewController.swift
//  aecombiner
//
//  Created by David JM Lewis on 25/06/2015.
//  Copyright (c) 2015 djml.eu. All rights reserved.
//

import Cocoa

let kStringEmpty = "- Empty -"
let kStringRecodedColumnNameSuffix = "_#_"

enum ParametersValueBoolColumnIndexes: Int
{
    case ParametersIndex = 0
    case ValueIndex = 1
    case BooleanIndex = 2
}

enum RecodeTabViewTitles:String
{
    case Single = "Single"
    case Multiple = "Multiple"
    case Boolean = "Boolean"
    case DateTime = "Date-Time"
}

enum DateTimeRecodeMethod:String
{
    case Integer = "radio_ConvertInteger"
    case TimeSinceColumn = "radio_TimeSinceColumn"
    case String = "radio_ConvertString"
}

enum DateTimeRoundingUnits:String
{
    case Seconds = "Seconds"
    case Minutes = "Minutes"
    case Hours = "Hours"
    case Days = "Days"
    static func roundedTimeAccordingToUnits(time time:NSTimeInterval, units:DateTimeRoundingUnits)->NSTimeInterval
    {
        switch units
        {
        case .Days: return time/86400.0
        case .Hours: return time/3600.0
        case .Minutes: return time/60.0
        case .Seconds: return time
        }
    }
}


enum DateTimeFormatMethod:String
{
    case DateWithTime = "yyyy'-'MM'-'dd'T'HH':'mm"
    case DateOnly = "yyyy'-'MM'-'dd"
    case Custom = "Custom:"
    case TextRecognition = "Text Recognition"
}

enum DateFormatInformation:String
{
    case DateWithTime = "Requires complete Year-Month-Day Hour:Minute"
    case DateOnly = "Requires complete Year-Month-Day, ignores time and uses 00:00 instead"
    case Custom = "Requires exact match with defined format"
    case TextRecognition = "Requires complete Year-Month-Day, uses 12:00 if time missing"
}


class RecodeColumnViewController: ColumnSortingChartingViewController, NSTabViewDelegate {
    
    // MARK: - class constants

    // MARK: - class vars
    var arrayExtractedParameters =  StringsMatrix2D()
    var radio_DateTimeMethod_Selected = DateTimeRecodeMethod.TimeSinceColumn
    
    
    
    // MARK: - @IBOutlet

    @IBOutlet weak var tvExtractedParametersSingle: NSTableView!
    @IBOutlet weak var tvExtractedParametersMultiple: NSTableView!
    @IBOutlet weak var tvExtractedParametersPredicate: NSTableView!
    
    @IBOutlet weak var labelNumberOfParameterOrGroupingItems: NSTextField!
    @IBOutlet weak var labelDateFormatInfo: NSTextField!
    
    @IBOutlet weak var textFieldSetValue: NSTextField!
    @IBOutlet weak var textFieldColumnRecodedName: NSTextField!
    @IBOutlet weak var textFieldBooleanComparator: NSTextField!
    @IBOutlet weak var textFieldDateFormatString: NSTextField!

    @IBOutlet weak var tabbedVrecoding: NSTabView!
    
    @IBOutlet weak var popupHeaders: NSPopUpButton!
    @IBOutlet weak var popupBooleans: NSPopUpButton!
    @IBOutlet weak var popupDateFormatMethod: NSPopUpButton!
    @IBOutlet weak var popupHeadersDateEnd: NSPopUpButton!
    @IBOutlet weak var popupDateTimeRoundingUnits: NSPopUpButton!
 
    @IBOutlet weak var buttonOverwite: NSButton!
    @IBOutlet weak var buttonSetValue: NSButton!
    @IBOutlet weak var buttonRecodeTo: NSButton!
    
    @IBOutlet weak var progressSetValue: NSProgressIndicator!
    
    @IBOutlet weak var checkboxCopyUnmatchedValues: NSButton!
    
    // MARK: - @IBAction

    @IBAction func radioTimeDateTapped(sender: NSButton) {
        guard
            let id = sender.identifier,
            let method = DateTimeRecodeMethod(rawValue: id)
        else {return}
        self.radio_DateTimeMethod_Selected = method
    }
    
    @IBAction func popupDateFormatTapped(sender: AnyObject) {
        guard
            let title = self.popupDateFormatMethod.selectedItem?.title,
            let format = DateTimeFormatMethod(rawValue: title)
        else {return}
        switch format
        {
        case .Custom:
            self.textFieldDateFormatString.enabled = true
            self.textFieldDateFormatString.hidden = false
            self.labelDateFormatInfo.stringValue = DateFormatInformation.Custom.rawValue

        case .DateOnly:
            self.textFieldDateFormatString.hidden = false
            self.textFieldDateFormatString.hidden = false
           self.textFieldDateFormatString.stringValue  = title
            self.labelDateFormatInfo.stringValue = DateFormatInformation.DateOnly.rawValue

        case .DateWithTime:
            self.textFieldDateFormatString.hidden = false
            self.textFieldDateFormatString.hidden = false
            self.textFieldDateFormatString.stringValue  = title
            self.labelDateFormatInfo.stringValue = DateFormatInformation.DateWithTime.rawValue

        case .TextRecognition:
            self.textFieldDateFormatString.enabled = true
            self.textFieldDateFormatString.hidden = true
            self.labelDateFormatInfo.stringValue = DateFormatInformation.TextRecognition.rawValue
            
        }
    }
    
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
        for row in 0..<self.arrayExtractedParameters.count
        {
            self.arrayExtractedParameters[row][ParametersValueBoolColumnIndexes.BooleanIndex.rawValue] = String(sender.state)
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
        self.textFieldDateFormatString.stringValue  = DateTimeFormatMethod.DateWithTime.rawValue
        self.labelDateFormatInfo.stringValue = DateFormatInformation.DateWithTime.rawValue
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
        self.popupHeadersDateEnd.removeAllItems()
        self.popupHeadersDateEnd.addItemsWithTitles(csvdm.headerStringsForAllColumns())
        self.popupHeadersDateEnd.selectItemAtIndex(0)
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
            self.arrayExtractedParameters[sender.tag][ParametersValueBoolColumnIndexes.BooleanIndex.rawValue] = String(sender.state)
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
            self.arrayExtractedParameters[control.tag][ParametersValueBoolColumnIndexes.ValueIndex.rawValue] = str
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
            self.arrayExtractedParameters[index][ParametersValueBoolColumnIndexes.ValueIndex.rawValue] = valueS
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
                    cellView.textField!.stringValue = self.arrayExtractedParameters[row][ParametersValueBoolColumnIndexes.ParametersIndex.rawValue]
                case "value"://parameters
                    cellView = tableView.makeViewWithIdentifier("parametersValueCell", owner: self) as! NSTableCellView
                    cellView.textField!.stringValue = self.arrayExtractedParameters[row][ParametersValueBoolColumnIndexes.ValueIndex.rawValue]
                    cellView.textField!.tag = row
                case "bool"://parameters
                    cellView = tableView.makeViewWithIdentifier("parametersBoolCell", owner: self) as! NSTableCellView
                    for subview in cellView.subviews
                    {
                        guard
                        let box = (subview as? NSButton),
                        let value = NSCellStateValue(self.arrayExtractedParameters[row][ParametersValueBoolColumnIndexes.BooleanIndex.rawValue])
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
        self.buttonOverwite.hidden = tabView.selectedTabViewItem!.label == RecodeTabViewTitles.DateTime.rawValue
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
        self.arrayExtractedParameters = StringsMatrix2D()
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
        guard
            let id = self.tabbedVrecoding.selectedTabViewItem?.label,
        let tabTitle = RecodeTabViewTitles(rawValue: id)
        else {return}

        switch tabTitle
        {
        case .DateTime:
            self.recodeDateTime_FromOneColumn(overwrite: false)
        case .Single, .Multiple, .Boolean:
            guard
                let csvdo = self.associatedCSVmodel,
                let csvdVC = self.associatedCSVdataViewController,
                let columnIndex = csvdo.validatedColumnIndex(self.popupHeaders.indexOfSelectedItem)
                else {return}
            guard self.arrayExtractedParameters.count > 0  else {return}
            //give a name if none
            let colTitle = self.columnAddedSafeTitle(fromColumnIndex: columnIndex)
            
            guard
                //pass it over
                csvdVC.addedRecodedColumn(withTitle: colTitle, fromColum: columnIndex, usingParamsArray: self.arrayExtractedParameters, copyUnmatchedValues:self.checkboxCopyUnmatchedValues.state == NSOnState)
                else {return}
            
            //reload etc
            self.resetExtractedParameters(andPopupHeaders: true)
        }
        
    }
    
    func columnAddedSafeTitle(fromColumnIndex fromColumnIndex:Int)->String
    {
        return self.textFieldColumnRecodedName!.stringValue.isEmpty ? self.stringForRecodedColumn(fromColumnIndex) : self.textFieldColumnRecodedName!.stringValue
    }
    
    func recodeDateTime_FromOneColumn(overwrite overwrite:Bool)
    {
        guard
            let csvdo = self.associatedCSVmodel,
            let csvdVC = self.associatedCSVdataViewController,
            let methodString = self.popupDateFormatMethod.selectedItem?.title,
            let formatMethod = DateTimeFormatMethod(rawValue: methodString)
        else {return}
        
        var recodedOK = false
        let formatString = self.textFieldDateFormatString.stringValue
        
        switch self.radio_DateTimeMethod_Selected
        {
        case .Integer, .String:
            guard
                let columnIndexFrom = csvdo.validatedColumnIndex(self.popupHeaders.indexOfSelectedItem)
            else {return}
           recodedOK = csvdVC.recodedDateTimeToNewColumn(withTitle: self.columnAddedSafeTitle(fromColumnIndex: columnIndexFrom), fromColum: columnIndexFrom, formatMethod: formatMethod, formatString: formatString, copyUnmatchedValues: true, asString: self.radio_DateTimeMethod_Selected == .String)
        case .TimeSinceColumn:
            guard
            let columnIndexStart = csvdo.validatedColumnIndex(self.popupHeaders.indexOfSelectedItem),
            let columnIndexEnd = csvdo.validatedColumnIndex(self.popupHeadersDateEnd.indexOfSelectedItem),
            let roundingString = self.popupDateTimeRoundingUnits.selectedItem?.title,
            let roundingunits = DateTimeRoundingUnits(rawValue: roundingString)
            else {return}
            
            let newTitle = csvdo.headerStringForColumnIndex(columnIndexStart)+"->"+csvdo.headerStringForColumnIndex(columnIndexEnd)
            recodedOK = csvdVC.calculatedDateTimeToNewColumn(withTitle: newTitle, startColumn: columnIndexStart, endColumn: columnIndexEnd, formatMethod: formatMethod, formatString: formatString, roundingUnits: roundingunits, copyUnmatchedValues: self.checkboxCopyUnmatchedValues.state == NSOnState)
            
        }
        
        if recodedOK
        {
            //reload etc
            self.resetExtractedParameters(andPopupHeaders: true)
        }
    }
    
    func doRecodeOverwrite()
    {
        guard let id = self.tabbedVrecoding.selectedTabViewItem?.identifier as? String else {return}
        switch id
        {
        case "datetime":
            self.recodeDateTime_FromOneColumn(overwrite: false)
        default:
            guard self.arrayExtractedParameters.count > 0  else { return}
            guard
                let csvdo = self.associatedCSVmodel,
                let csvdVC = self.associatedCSVdataViewController,
                let columnIndex = csvdo.validatedColumnIndex(self.popupHeaders.indexOfSelectedItem)
                else {return}
            
            guard
                //pass it over
                csvdVC.recodedColumnInSitu(columnToRecode:columnIndex, usingParamsArray: self.arrayExtractedParameters, copyUnmatchedValues:self.checkboxCopyUnmatchedValues.state == NSOnState) == true
                else { return}
            
            
            //reload etc
            self.resetExtractedParameters(andPopupHeaders: true)
        }
    }


}

