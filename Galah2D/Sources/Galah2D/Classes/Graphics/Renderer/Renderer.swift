//
//  Renderer.swift
//  
//
//  Created by Alex Griffin on 12/1/20.
//

public class Renderer
{
    private static let LAYERBUFFERSIZE: Int = 124;
    
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
    
    // Render Layers & Batches
    private var renderLayers: ContiguousArray<RenderLayer>? = nil;
    
    private init()
    {
        renderLayers = ContiguousArray<RenderLayer>();
        renderLayers?.reserveCapacity(Renderer.LAYERBUFFERSIZE);
    }
    
    public func Render()
    {
        
    }
    
    private func SetTargetResolution(_ newTarget: Size)
    {
        _targetResolution = newTarget;
        
        //Update matrices here?
    }
    
    internal func GetLayer(_ depth: Int) -> RenderLayer
    {
        for i in 0..<renderLayers?.count
        {
            print(i)
        }
    }
}

internal struct RenderLayer: BufferItem
{
    internal var isActive: Bool = false;
    
    var depth: Int;
    var layers: ContiguousArray<RenderComponent>? = nil;
    
    var firstItem
        
    fileprivate init()
    {
        
    }
}

