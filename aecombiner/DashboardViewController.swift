//
//  DashboardViewController.swift
//  aecombiner
//
//  Created by David JM Lewis on 17/07/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa

class DashboardViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
    // MARK: - @IBAction

    @IBAction func showDataWindow(sender: AnyObject) {
        guard let doc = NSDocumentController.sharedDocumentController().currentDocument as? Document
            else
        {
            print("No document showDataWindow")
            return
        }
        doc.makeAndShowCSVdataWindow()
        doc.showWindows()
    }

}
