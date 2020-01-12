//
//  RenderDelegate.swift
//  
//
//  Created by Alex Griffin on 12/1/20.
//

public protocol RenderDelegate
{
    var RenderTarget: RenderTarget { get };
    func SetRenderTarget(_ newRenderTarget: RenderTarget) throws;
    func Draw();
    
}
