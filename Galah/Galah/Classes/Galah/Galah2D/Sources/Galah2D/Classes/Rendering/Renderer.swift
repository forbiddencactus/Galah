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
    
    private var _targetResolution: Rect<Int> = Constants.TargetResolution;
    public var TargetResolution: Rect<Int> { get { return _targetResolution; } set { self.SetTargetResolution(newValue); } }
    
    private init()
    {
        
    }
    
    public func Render()
    {
        
    }
    
    private func SetTargetResolution(_ newTarget: Rect<Int>)
    {
        _targetResolution = newTarget;
        
        //Update matrices here?
    }
}
