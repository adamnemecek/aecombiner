//
//  CSVdataWindowController.swift
//  aecombiner
//
//  Created by David Lewis on 12/07/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa

class CSVdataWindowController: NSWindowController {


    // MARK: - @IBActions
    
    @IBAction func exportTABpressed(sender: NSToolbarItem) {
        
        self.exportDocument(fileExtension: "txt")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    
    func exportDocument(fileExtension fileExtension:String)
    {
        
        let panel = NSSavePanel()
        let title = ((self.window!.title as NSString).stringByDeletingPathExtension as NSString).stringByAppendingPathExtension(fileExtension)
        panel.nameFieldStringValue = title!
    
        var types = SingleColumnStringsArray()
        types.append("txt")
        panel.allowedFileTypes = types
        panel.beginSheetModalForWindow(self.window!) { (result) -> Void in
            if result == NSFileHandlingPanelOKButton
            {
                (self.document as? CSVdataDocument)?.exportDataTabDelimitedTo(fileURL: panel.URL)
            }
        }
        
    }

    
}