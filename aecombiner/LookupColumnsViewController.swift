//
//  LookupColumnsViewController.swift
//  aecombiner
//
//  Created by David Lewis on 08/11/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa

class LookupColumnsViewController: TwoColumnsViewController
{
    // MARK: - Var
    var lookupCSVdata: CSVdata = CSVdata()
    {
        didSet {
            // Update the view, if already loaded.
            self.rebuildColumns()
        }
    }
    
    var arrayImportColParameters =  StringsArray1D()

    // MARK: - @IBOutlet

    @IBOutlet weak var buttonImportMissingFromMatched: NSButton!
    @IBOutlet weak var buttonExportMissingValues: NSButton!
 
    @IBOutlet weak var popupMatchColumn: NSPopUpButton!
    
    @IBOutlet weak var tvImportColumnParameters: NSTableView!
    
    @IBOutlet weak var checkboxAddZeroes: NSButton!
    // MARK: - @IBActions
    @IBAction func lookupButtonTapped(sender: AnyObject) {
        self.performLookupAndMerge()
    }
    
    @IBAction func popupChanged(sender: NSPopUpButton) {
        self.popupChangedSelection(sender)
    }

    @IBAction func lookupFromFile(sender: AnyObject)
    {
        self.requestNewFile()
    }
    
    @IBAction func exportMissingValuesTapped(sender: AnyObject) {
        self.importMissingFromMatched(output: .ExportAsCSV)
   }
    @IBAction func importMissingFromMatchedTapped(sender: AnyObject) {
        self.importMissingFromMatched(output: .AppendToSelf)
    }
    // MARK: - overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.lookupCSVdata = CSVdata()
   }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
    }
    
    override func enableButtons(enabled enabled:Bool)
    {
        self.buttonCopyColumns?.enabled = self.tvHeaders.selectedRowIndexes.count > 0 && self.popupMatchColumn.indexOfSelectedItem >= 0
        self.buttonImportMissingFromMatched?.enabled = self.popupMatchColumn.indexOfSelectedItem >= 0
        self.buttonExportMissingValues?.enabled = self.popupMatchColumn.indexOfSelectedItem >= 0
    }

    
    // MARK: - TableViews
    override     func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        
        switch tableView
        {
        case self.tvHeaders:
            return self.lookupCSVdata.numberOfColumnsInData()
        
        case self.tvMatchColumnParameters:
            return self.arrayMatchParameters.count
        case self.tvImportColumnParameters:
            return self.arrayImportColParameters.count
        
        default:
            return 0
        }
    }

    override func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        // Retrieve to get the @"MyView" from the pool or,
        // if no version is available in the pool, load the Interface Builder version
        var cellView = NSTableCellView()
        
        switch tableView
        {
        case self.tvHeaders:
            cellView = self.lookupCSVdata.cellForHeadersTable(tableView: tableView, row: row)
        case self.tvImportColumnParameters:
            cellView = tableView.makeViewWithIdentifier("cell", owner: self) as! NSTableCellView
            cellView.textField!.stringValue = self.arrayImportColParameters[row]
        case self.tvMatchColumnParameters:
            cellView = tableView.makeViewWithIdentifier("cell", owner: self) as! NSTableCellView
            cellView.textField!.stringValue = self.arrayMatchParameters[row]
        default:
            break
        }
        
        
        // Return the cellView
        return cellView
    }

    override func tableViewSelectionDidChange(notification: NSNotification) {
        guard let tableView = (notification.object as? NSTableView) else {return}
        switch tableView
        {
        case self.tvHeaders:
            guard
                self.tvHeaders.selectedRowIndexes.count == 1,
                let newparams = self.lookupCSVdata.stringsArray1DOfParametersFromColumn(fromColumn: self.tvHeaders.selectedRow, replaceBlank: true)
                else
            {
                self.arrayImportColParameters = StringsArray1D()
                self.tvImportColumnParameters.reloadData()
                return
            }
            self.arrayImportColParameters = newparams
            self.tvImportColumnParameters.reloadData()

        default:
            break;
        }
        self.enableButtons(enabled: true)
    }
    
    // MARK: - match
    override func matchParametersExtract(erase erase:Bool)
    {
        guard
            let newparams = self.lookupCSVdata.stringsArray1DOfParametersFromColumn(fromColumn: self.popupMatchColumn.indexOfSelectedItem, replaceBlank: true)
            else
        {
            self.arrayMatchParameters = StringsArray1D()
            self.tvMatchColumnParameters.reloadData()
            return
        }
        self.arrayMatchParameters = newparams
        self.tvMatchColumnParameters.reloadData()
    }
    
    // MARK: - header Popups
    func populateHeaderPopups()
    {
        self.popupMatchColumn.removeAllItems()
        guard
            self.lookupCSVdata.numberOfColumnsInData()>0
        else { return}
        self.popupMatchColumn.addItemsWithTitles(self.lookupCSVdata.headerStringsForAllColumns())
        self.popupMatchColumn.selectItemAtIndex(-1)
    }

    func popupChangedSelection(popup: NSPopUpButton)
    {
        switch popup
        {
        case self.popupMatchColumn:
            self.matchParametersExtract(erase: false)
        default:
            break
        }
        self.enableButtons(enabled: true)
    }

    // MARK: - funcs
    
    func rebuildColumns()
    {
        self.tvHeaders?.reloadData()
        populateHeaderPopups()
        self.enableButtons(enabled: false)
    }

    func requestNewFile()
    {
        let panel = NSOpenPanel()
        var types = StringsArray1D()
        types.append("csv")
        types.append("txt")
        panel.allowedFileTypes = types
        if panel.runModal() == NSFileHandlingPanelOKButton
        {
            self.lookupFromURL(panel.URL)
        }
    }
    
    func lookupFromURL(url:NSURL?)
    {
        guard
            let theURL = url,
            let urlname = theURL.lastPathComponent,
            let urltype = theURL.pathExtension,
            let data = NSData(contentsOfURL: theURL)
            else {return}
        
        var csvdata = CSVdata()
        switch urltype
        {
        case "txt":
            csvdata = CSVdata(data: data, name: urlname, delimiter: .TAB)
        case "csv":
            csvdata = CSVdata(data: data, name: urlname, delimiter: .CSV)
        default:
            break
        }
        self.lookupCSVdata = csvdata
    }
    
    func performLookupAndMerge()
    {
        self.associatedCSVdataViewController?.lookupNewColumnsFromCSVdata(lookupCSVdata: self.lookupCSVdata, lookupColumn: self.popupMatchColumn.indexOfSelectedItem, columnsToAdd: self.tvHeaders.selectedRowIndexes)
        
    }
    
    enum OutputDirection
    {
        case ExportAsCSV
        case AppendToSelf
    }
    func importMissingFromMatched(output output:OutputDirection)
    {
        guard
            let assocCSVdata = self.associatedCSVmodel,
            let assocCSVdataVC = self.associatedCSVdataViewController,
            let nameOfMatchColumn = self.popupMatchColumn.titleOfSelectedItem,
            let indexOfMatchColumnInOpenFile = assocCSVdata.indexOfColumnWithName(name: nameOfMatchColumn),
            let newparams = self.lookupCSVdata.setOfParametersFromColumn(fromColumn: self.popupMatchColumn.indexOfSelectedItem, replaceBlank: true),
            let openparams = assocCSVdata.setOfParametersFromColumn(fromColumn: indexOfMatchColumnInOpenFile, replaceBlank: true)
            else {return}
        
        let missing = newparams.subtract(openparams)
        if missing.isEmpty == false
        {
            switch output
            {
            case .ExportAsCSV:
                CSVdata.createNewDocumentFromCVSDataAndColumnName(cvsData: CSVdata(singleColumnName: nameOfMatchColumn, singleColumnSetOfData: missing), name: nameOfMatchColumn)
            case .AppendToSelf:
                assocCSVdataVC.appendTheseParametersIntoColumn(params: missing, intoColumn: indexOfMatchColumnInOpenFile, padValue: self.checkboxAddZeroes.state == NSOnState ? "0.0" : "")
            }
        }
        

    }
    
}
