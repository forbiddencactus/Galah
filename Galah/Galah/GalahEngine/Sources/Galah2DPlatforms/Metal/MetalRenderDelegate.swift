//
//  MetalRenderDelegate.swift
//  
//
//  Created by Alex Griffin on 12/1/20.
//

#if os(macOS) || os(iOS)

import Galah2D
import Galah2DC
import MetalKit

@available(OSX 10.11, *)
public class MetalRenderDelegate: RenderDelegate
{
    private var metalRenderer: UnsafeMutablePointer<MetalRenderer>
    
    private var _renderTarget: RenderTarget! = nil;
    
    public var RenderTarget: RenderTarget { get { return _renderTarget; } }
    
    public static func CreateMetalRenderDelegate(metalKitView: MTKView) -> MetalRenderDelegate
    {
        let renderTarget = Galah2D.RenderTarget(GetPointerFromObject(metalKitView));
        return MetalRenderDelegate(renderTarget);
    }
    
    public required init(_ newRenderTarget: RenderTarget)
    {
        _renderTarget = newRenderTarget;
        
        metalRenderer = .allocate(capacity: 1)
        metalRenderer.initialize(to:  construct_renderer())
        set_mtkview(metalRenderer, _renderTarget.TargetPointer)
        
        self.SetUpSizeChangedCallback();
    }
    
    public func Draw()
    {
        renderer_draw(metalRenderer);
    }
    
    public func SetBackgroundColour(_ colour: Colour)
    {
        renderer_setclearcolour(metalRenderer, colour.r, colour.g, colour.b, colour.a);
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

