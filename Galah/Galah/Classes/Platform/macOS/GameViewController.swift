//
//  GameViewController.swift
//  Galah
//
//  Created by Alex Griffin on 29/12/19.
//  Copyright © 2019 Forbidden Cactus. All rights reserved.
//

import Cocoa
import MetalKit
import Galah2DPlatforms

// Our macOS specific view controller
class GameViewController: NSViewController {

    var renderer: Renderer!
    var mtkView: MTKView!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let mtkView = self.view as? MTKView else {
            print("View attached to GameViewController is not an MTKView")
            return
        }

        // Select the device to render with.  We choose the default device
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }

        mtkView.device = defaultDevice
        
        MetalRenderDelegate.CreateMetalRenderDelegate(metalKitView: mtkView);


       /* guard let newRenderer = Renderer(metalKitView: mtkView) else {
            print("Renderer cannot be initialized")
            return
        }

        renderer = newRenderer

        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)

        mtkView.delegate = renderer
        */

    }
}
