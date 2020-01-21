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
    
    public var LocalPosition: Vec2 { get { return _localPosition; } set { self.SetLocalPosition(position: newValue); } }
    public var WorldPosition: Vec2 { get { return _worldPosition; } set { self.SetWorldPosition(position: newValue); } }
    public var LocalRotation: Float { get { return _localRotation; } set { self.SetLocalRotation(rotation: newValue); } }
    public var WorldRotation: Float { get { return _worldRotation; } set { self.SetWorldRotation(rotation: newValue); } }
    public var LocalScale: Vec2 { get { return _localScale; } set { self.SetLocalScale(scale: newValue); } }
    public var WorldScale: Vec2 { get { return _worldScale; } set { self.SetWorldScale(scale: newValue); } }
    public var LocalShear: Vec2 { get { return _localShear; } set { self.SetLocalShear(shear: newValue); } }
    
    
    private var _cachedMatrix: Mat3x3 = Mat3x3.Identity;
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
    
    public func Construct()
    {        
        self.InternalWorldRefresh();
    }
    
    public func SetParent(parent: Transform?, keepWorldPosition: Bool = true)
    {
        _parent = parent;
        //update local positions...
        if (keepWorldPosition)
        {
            if (_parent != nil)
            {
                _localPosition = Mat3x3.MultiplyVec2(m: try! _parent!._cachedMatrix.Invert(), vec: _worldPosition);
                _localRotation = _worldRotation - _parent!._worldRotation;
                _localScale = _worldScale - _parent!._worldScale;
                _localShear = _worldShear - _parent!._worldShear;
            }
            else
            {
                _localPosition = _worldPosition
                _localRotation = _worldRotation;
                _localScale = _worldScale;
                _localShear = _worldShear;
            }
        }
        
        //Refresh
        self.InternalWorldRefresh();
        
    }
    
    private func SetLocalPosition(position: Vec2)
    {
        _localPosition = position;
        self.InternalWorldRefresh();
    }
    
    private func SetWorldPosition(position: Vec2)
    {
        _worldPosition = position;
        self.InternalLocalRefresh();
    }
    
    private func SetLocalRotation(rotation: Float)
    {
        _localRotation = rotation;
        self.InternalWorldRefresh();
    }
    
    private func SetWorldRotation(rotation: Float)
    {
        _worldRotation = rotation;
        self.InternalLocalRefresh();
    }
    
    private func SetLocalScale(scale: Vec2)
    {
        _localScale = scale;
        self.InternalWorldRefresh();
    }
    
    private func SetWorldScale(scale: Vec2)
    {
        _worldScale = scale;
        self.InternalLocalRefresh();
    }
    
    private func SetLocalShear(shear: Vec2)
    {
        _localShear = shear;
        self.InternalWorldRefresh();
    }
    
    private func SetWorldShear(shear: Vec2)
    {
        _worldShear = shear;
        self.InternalLocalRefresh();
    }
    
    //New local values were provided and we need to refresh world values.
    private func InternalWorldRefresh()
    {
        //Assuming the local values are accurate, refresh the world matrix.
        if (_parent != nil)
        {
            //First, set the new matrix for our children to use...
            _cachedMatrix = self.LocalTRSS * _parent!.WorldTRSS;
            
            //Set new world data based on local data.
            _worldPosition = Mat3x3.MultiplyVec2(m: _parent!.WorldTRSS, vec: _localPosition);
            _worldRotation = _parent!._worldRotation + _localRotation;
            _worldScale = Vec2.Scale(_parent!._worldScale, _localScale);
            _worldShear = _parent!._worldShear + _localShear;

        }
        else
        {
            _cachedMatrix = self.LocalTRSS;
            
            _worldPosition = _localPosition;
            _worldRotation = _localRotation;
            _worldScale = _localScale;
            _worldShear = _localShear;
        }
        
        for child in _children
        {
            child.InternalWorldRefresh();
        }
    }
    
    //New world values were provided and we need to refresh local values.
    private func InternalLocalRefresh()
    {
        if (_parent != nil)
        {
            _localPosition = Mat3x3.MultiplyVec2(m: try! _parent!._cachedMatrix.Invert(), vec: _worldPosition);
            _localRotation = _worldRotation - _parent!._worldRotation;
            _localScale = _worldScale - _parent!._worldScale;
            _localShear = _worldShear - _parent!._worldShear;
        }
        else
        {
            _localPosition = _worldPosition;
            _localRotation = _worldRotation;
            _localScale = _worldScale;
            _localShear = _worldShear;
        }
        
        for child in _children
        {
            child.InternalWorldRefresh();
        }
    }
}

