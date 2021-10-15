//
//  AppDelegate.swift
//  Galah-Xcode
//
//  Created by Alex Griffin on 15/10/2021.
//

import Cocoa
import Galah;

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        let extents = ExtentsOf(GObject.self);
        print(extents);
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
}
