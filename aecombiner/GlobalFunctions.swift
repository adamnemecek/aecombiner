//
//  GlobalFunctions.swift
//  aecombiner
//
//  Created by David Lewis on 20/09/2015.
//  Copyright © 2015 djml.eu. All rights reserved.
//

import Cocoa


func alertWithMessage(message:String, style: NSAlertStyle)
{
    let alert = NSAlert()
    alert.messageText = message
    alert.alertStyle = style
    alert.runModal()
}

