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
        
        // Verified this seems to work!!
        /*var doTest = Test();
        // var buf = try! Buffer<Test>();
       // try! buf.Add(doTest);
        var buf = try! RawBuffer(withInitialCapacity: 16, withType: Test.self);
        let space = try! buf.MakeSpace(0);
        let source = Ptr<VoidPtr>(&doTest);
        galah_copyValue(dest: space, source: source, type: Test.self);
        */
        
        // Allocate the object and then immediately destroy it as a test. The destructor should run twice on Deinit2,
        // (once for the copyFrom throwaway, once for the actual instance, but Deinit's destructor will just run once. :)
        // If you don't call that release, then only the destructor for the throwaway will run, so the throwaway was successfully cloned and ARC's happy.
        // var buf = try! RawBuffer(withInitialCapacity: 16, withType: Deinit2.self);
        // var obj = try! MObject.Construct(type: Deinit2.self, ptr: buf.MakeSpace(0));
        // obj = nil;
        // try! Unmanaged<MObject>.fromOpaque(buf.PtrAt(0).raw!).release();


        //var ptr = Unmanaged.passUnretained(obj!);
        //ptr.release();
        //setObjectRetain(obj!, 1);
        // I don't want ARC to release the reference to theDeinit here because buf now has a copy of doTest. 
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
}
