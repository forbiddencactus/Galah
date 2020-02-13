//
//  RenderDelegate.swift
//  
//
//  Created by Alex Griffin on 12/1/20.
//

public protocol RenderDelegate
{
    var RenderQueue: Array<RenderQueue>! { get };
    var RenderTarget: RenderTarget { get };
    
    
    init(_ newRenderTarget: RenderTarget);
    func Draw();
    func SetBackgroundColour(_ colour: Colour);
    func SetTargetResolution(_ resolution: Size<Int>);
}

public extension RenderDelegate
{
    func ViewSizeWillChange(width: Float, height: Float)
    {
        ///
    }
}
