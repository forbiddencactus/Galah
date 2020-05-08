//
//  Renderer.swift
//  
//
//  Created by Alex Griffin on 12/1/20.
//

public class Renderer
{
    private static var _instance: Renderer! = nil;
    public static var Instance: Renderer
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
    
    private var _targetResolution: Size = Constants.TargetResolution;
    public var TargetResolution: Size { get { return _targetResolution; } set { self.SetTargetResolution(newValue); } }
    
    private init()
    {
        
    }
    
    public func Render()
    {
        
    }
    
    private func SetTargetResolution(_ newTarget: Size)
    {
        _targetResolution = newTarget;
        
        //Update matrices here?
    }
}
