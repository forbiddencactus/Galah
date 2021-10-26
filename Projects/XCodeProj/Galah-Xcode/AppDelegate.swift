//
//  AppDelegate.swift
//  Galah-Xcode
//
//  Created by Alex Griffin on 15/10/2021.
//

import Cocoa
import Galah;

public class Deinit
{
    deinit
    {
        // This shouldn't run.
        print("It deinit!");
    }
}

public struct Test
{
    let theDeinit = Deinit();
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet var window: NSWindow!
    
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        let extents = ExtentsOf(GObject.self);
        print(extents);
        
        var doTest = Test();
        var buf = try! Buffer<Test>();
        try! buf.Add(doTest);
        // I don't want ARC to release the reference to theDeinit here because buf now has a copy of doTest. 
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
}
