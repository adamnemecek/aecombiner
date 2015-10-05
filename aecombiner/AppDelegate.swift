//
//  AppDelegate.swift
//  aecombiner
//
//  Created by David JM Lewis on 25/06/2015.
//  Copyright (c) 2015 djml.eu. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    // MARK: - @IBActions
    @IBAction func importFile(sender: NSToolbarItem)
    {
        let panel = NSOpenPanel()
        var types = StringsArray1D()
        types.append("txt")
        panel.allowedFileTypes = types
        if panel.runModal() == NSFileHandlingPanelOKButton
        {
            guard
                let theURL = panel.URL
                //let data = NSData(contentsOfURL: theURL)
                else {return}
            do {
                var usedencoding = NSStringEncoding()
                let csvstring = try NSString(contentsOfURL: theURL, usedEncoding: &usedencoding)
                let doc = try NSDocumentController.sharedDocumentController().openUntitledDocumentAndDisplay(true)
                if doc is CSVdataDocument
                {
                    (doc as! CSVdataDocument).csvDataModel = CSVdata(stringTAB: csvstring, name:doc.displayName)
                    (doc as! CSVdataDocument).updateChangeCount(.ChangeDone)
                }
            } catch {
                print(error)
            }
        }
    }
    
   @IBAction func closeSheetForButton(button:NSButton)
    {
        guard   let win = button.window,
                let sheetP = button.window?.sheetParent else
        {
            return
        }
        sheetP.endSheet(win)
    }
}

