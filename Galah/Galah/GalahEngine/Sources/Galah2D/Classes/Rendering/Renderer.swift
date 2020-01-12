//
//  Renderer.swift
//  
//
//  Created by Alex Griffin on 12/1/20.
//

public class Renderer
{
    private var _instance: Renderer! = nil;
    public var Instance: Renderer
    {
        get
        {
            if (_instance == nil)
            {
                _instance = Renderer();
            }
            
            return _instance;
        }
    }
    
    private var _renderDelegate: RenderDelegate! = nil;
    public var RenderDelegate: RenderDelegate { get { return _renderDelegate; } }
    
    internal init()
    {
        
    }
    
    public func Render()
    {
        
    }
}
