//
//  Renderer.swift
//  
//
//  Created by Alex Griffin on 12/1/20.
//

public class Renderer
{
    private static let _layerBufferSize: Int = 124;
    
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
    private var firstLayer: RenderLayer? = nil;
    private var layerBuffer: UnsafeMutableBufferPointer<RenderLayer>? = nil;
    
    private init()
    {
        //Pre fill layer buffer.
        layerBuffer = UnsafeMutableBufferPointer<RenderLayer>.allocate(capacity: Renderer._layerBufferSize);
        layerBuffer?.initialize(repeating: RenderLayer());
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
        var layer: RenderLayer? = firstLayer;
        
        while (layer != nil)
        {
            if (layer!.depth == depth)
            {
                return layer!;
            }
            
            layer = layer!.nextLayer;
        }
        
        //No layer found? Insert at appropriate depth in the list.
    }
}

internal class RenderLayer: BufferItem
{
    internal var isActive: Bool = false;
    
    var depth: Int;
    var nextLayer: RenderLayer? = nil;
        
    fileprivate init()
    {
        
    }
    
}

