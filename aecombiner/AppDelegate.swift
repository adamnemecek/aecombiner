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

