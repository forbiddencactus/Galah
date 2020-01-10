//
//  AppDelegate.swift
//  Galah
//
//  Created by Alex Griffin on 29/12/19.
//  Copyright © 2019 Forbidden Cactus. All rights reserved.
//

import Cocoa
import Galah2D

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
}
