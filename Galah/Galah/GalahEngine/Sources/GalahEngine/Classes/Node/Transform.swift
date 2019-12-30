//
//  Transform.swift
//  Galah
//
//  Created by Alex Griffin on 31/12/19.
//  Copyright © 2019 Forbidden Cactus. All rights reserved.
//

public class Transform: Component
{
    private var _parent: Transform? = nil;
    public var Parent: Transform?
    {
        get
        {
            return _parent;
        }
        
        set(newParent)
        {
            self.SetParent(parent: newParent);
        }
    }
    
    private var _children: Array<Transform> = Array<Transform>();
    
    private var _localPosition: Vec2 = Vec2.Zero
    private var _worldPosition: Vec2 = Vec2.Zero
    private var _localRotation: Float = 0;
    private var _worldRotation: Float = 0;
    private var _localScale: Vec2 = Vec2.Zero
    private var _worldScale: Vec2 = Vec2.Zero;
    private var _localShear: Vec2 = Vec2.Zero;
    private var _worldShear: Vec2 = Vec2.Zero;
    
    private var _cachedMatrix: Mat3x3;
    private var WorldTRSS: Mat3x3 { get { _cachedMatrix; } }
    private var LocalTRSS: Mat3x3
    {
        get
        {
            return Mat3x3Helpers.CreateTRSS(translation: _localPosition, rotationInRad: _localRotation, scale: _localScale, shear: _localShear);
        }
    }
    
    private var _depth: Int = 0;
    public var Depth: Int
    {
        get { return _depth; }
        set(newDepth) {_depth = newDepth;}
    }
    
    required init(_ node: Node)
    {
        super.init(node);
        
        self.InternalRefresh();
    }
    
    public func SetParent(parent: Transform?, keepWorldPosition: Bool = true)
    {
        //update local positions...
        
        self.InternalRefresh();
        
    }
    
    private func SetLocalPosition(position: Vec2)
    {
        
    }
    
    private func SetWorldPosition(position: Vec2)
    {
    }
    
    private func InternalRefresh()
    {
        //Assuming the local values are accurate, refresh the world matrix.
        if (_parent != nil)
        {
            //First, set the new matrix for our children to use...
            _cachedMatrix = self.LocalTRSS * _parent!.WorldTRSS;
            
            //Set new world data based on local data.
            _worldPosition = _parent!._worldPosition + _localPosition;
            _worldRotation = _parent!._worldRotation + _localRotation;
            _worldScale = Vec2.Scale(_parent!._worldScale, _localScale);
            _worldShear = _parent!._worldShear + _localShear;

        }
        else
        {
            _cachedMatrix = self.LocalTRSS;
            
            _worldPosition
        }
        
        
        
    }
    
}
