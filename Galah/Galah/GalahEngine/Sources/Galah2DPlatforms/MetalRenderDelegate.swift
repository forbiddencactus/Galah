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
    
    public init()
    {
        metalRenderer = .allocate(capacity: 1)
        metalRenderer.initialize(to:  construct_renderer())
    }
    
    public func SetRenderTarget(_ newRenderTarget: RenderTarget)
    {
        set_mtkview(metalRenderer, newRenderTarget.TargetPointer)
    }
    
    public func Draw()
    {
        renderer_draw(metalRenderer);
    }
}

#endif

