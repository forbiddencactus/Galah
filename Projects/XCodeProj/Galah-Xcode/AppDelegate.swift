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
    init()
    {
        print("It begins. ");
    }
    
    deinit
    {
        // This shouldn't run.
        print("It deinit!");
    }
}

public class Deinit2: MObject
{
    var firstClass = Deinit();
    
    open override func OnConstruct()
    {
        //firstClass = Deinit();
    }
    
    deinit
    {
        print("It hath deinit.");
    }
}

public struct Test
{
    let theDeinit = Deinit();
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet var window: NSWindow!
    private let test: Deinit2? = nil;
    
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        let extents = ExtentsOf(GObject.self);
        print(extents);
        
        //let doTest = Test();
        //var buf = try! Buffer<Test>();
        //try! buf.Add(doTest);
        
        var buf = try! RawBuffer(withInitialCapacity: 16, withType: Deinit2.self);
        let obj = try! MObject.Construct(type: Deinit2.self, ptr: buf.MakeSpace(0));
        var ptr = Unmanaged.passUnretained(obj!);
        ptr.release();
        //setObjectRetain(obj!, 1);
        // I don't want ARC to release the reference to theDeinit here because buf now has a copy of doTest. 
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
}
