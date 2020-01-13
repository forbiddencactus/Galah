//
//  MetalRenderDelegate.swift
//  
//
//  Created by Alex Griffin on 12/1/20.
//

#if os(macOS) || os(iOS)

import Galah2D
import Galah2DC

public class MetalRenderDelegate: RenderDelegate
{
    private var metalRenderer: UnsafeMutablePointer<MetalRenderer>
    
    private var _renderTarget: RenderTarget! = nil;
    
    public var RenderTarget: RenderTarget { get { return _renderTarget; } }
    
    
    public required init(_ newRenderTarget: RenderTarget)
    {
        metalRenderer = .allocate(capacity: 1)
        metalRenderer.initialize(to:  construct_renderer())
        set_mtkview(metalRenderer, newRenderTarget.TargetPointer)
        
        self.SetUpSizeChangedCallback();
    }
    
    public func Draw()
    {
        renderer_draw(metalRenderer);
    }
    
    
    private func SetUpSizeChangedCallback()
    {
        // The callback closure in Swift.
        let callback : CallbackWithSize? = { (size : BridgeSize) -> () in

            Renderer.Instance.RenderDelegate.ViewSizeWillChange(width: size.width, height: size.height);
        }

        // Run the C-function with the callback and context, then check for modification of the context.
        createViewSizeChangedCallback(callback)
        
    }
    
    
}

#endif

