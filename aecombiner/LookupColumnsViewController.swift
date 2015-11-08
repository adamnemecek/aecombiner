//
//  LookupColumnsViewController.swift
//  aecombiner
//
//  Created by David Lewis on 08/11/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa

class LookupColumnsViewController: TwoColumnsViewController {
    // MARK: - Var
    var lookupCSVdata: CSVdata = CSVdata()
    {
        didSet {
            // Update the view, if already loaded.
            self.rebuildColumns()
        }
    }
    
    
    // MARK: - @IBOutlet

    
    @IBOutlet weak var popupMatchColumn: NSPopUpButton!
    
    
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
    }

    
    // MARK: - TableViews
    override     func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        
        switch tableView
        {
        case self.tvHeaders:
            return self.lookupCSVdata.numberOfColumnsInData()
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
        case self.tvHeaders:
            cellView = self.lookupCSVdata.cellForHeadersTable(tableView: tableView, row: row)
            
        default:
            break
        }
        
        
        // Return the cellView
        return cellView;
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
            self.enableButtons(enabled: true)
        default:
            break
        }
    }

    // MARK: - funcs
    
    func rebuildColumns()
    {
        self.tvHeaders?.reloadData()
        populateHeaderPopups()
        self.buttonCopyColumns?.enabled = false
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
    
    
}
