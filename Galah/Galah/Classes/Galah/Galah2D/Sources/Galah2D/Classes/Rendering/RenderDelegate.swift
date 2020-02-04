//
//  RenderDelegate.swift
//  
//
//  Created by Alex Griffin on 12/1/20.
//

public protocol RenderDelegate
{
    var RenderTarget: RenderTarget { get };
    init(_ newRenderTarget: RenderTarget);
    func Draw();
    func SetBackgroundColour(_ colour: Colour);
    func SetTargetResolution(_ resolution: Rect<Int>);
}

public extension RenderDelegate
{
    func ViewSizeWillChange(width: Float, height: Float)
    {
        ///
    }
}
