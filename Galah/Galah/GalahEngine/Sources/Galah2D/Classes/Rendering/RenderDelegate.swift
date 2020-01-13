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
}

public extension RenderDelegate
{
    func ViewSizeWillChange(width: Float, height: Float)
    {
        ///
    }
}
