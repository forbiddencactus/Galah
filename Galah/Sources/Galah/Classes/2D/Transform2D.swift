//---- Galah Engine --------------------------------------------------------//
//
// This source file is part of the Galah open source game engine.
//
// Copyright © 2020, 2021, the Galah contributors.
//
// Licensed under the MIT Licence.
//
// You can find a copy of Galah's licence in LICENCE.MD
// You can find a list of Galah's contributors in CONTRIBUTORS.MD
// You can find a list of Galah's attributions in ATTRIBUTIONS.MD
//
// galah-engine.org | https://github.com/forbiddencactus/Galah
//--------------------------------------------------------------------------//
// The Transform2D class. Has support for shear like the classics!


public class Transform2D: Transform
{    
    private var _localPosition: Float2 = Float2.Zero;
    private var _worldPosition: Float2 = Float2.Zero;
    private var _localRotation: Float = 0;
    private var _worldRotation: Float = 0;
    private var _localScale: Float2 = Float2.Zero;
    private var _worldScale: Float2 = Float2.Zero;
    private var _localShear: Float2 = Float2.Zero;
    private var _worldShear: Float2 = Float2.Zero;
    
    public var LocalPosition: Float2 { get { return _localPosition; } set { self.SetLocalPosition(position: newValue); } }
    public var WorldPosition: Float2 { get { return _worldPosition; } set { self.SetWorldPosition(position: newValue); } }
    public var LocalRotation: Float { get { return _localRotation; } set { self.SetLocalRotation(rotation: newValue); } }
    public var WorldRotation: Float { get { return _worldRotation; } set { self.SetWorldRotation(rotation: newValue); } }
    public var LocalScale: Float2 { get { return _localScale; } set { self.SetLocalScale(scale: newValue); } }
    public var WorldScale: Float2 { get { return _worldScale; } set { self.SetWorldScale(scale: newValue); } }
    public var LocalShear: Float2 { get { return _localShear; } set { self.SetLocalShear(shear: newValue); } }
    
    
    private var _cachedMatrix: Mat3x3 = Mat3x3.Identity;
    private var WorldTRSS: Mat3x3 { get { _cachedMatrix; } }
    private var LocalTRSS: Mat3x3
    {
        get
        {
            return Mat3x3Helpers.CreateTRSS(translation: _localPosition, rotationInRad: _localRotation, scale: _localScale, shear: _localShear);
        }
    }
    
    public func Construct()
    {
        self.InternalWorldRefresh();
    }
    
    public func override SetParent(parent: Transform?, keepWorldPosition: Bool = true)
    {
        _parent = parent;
        //update local positions...
        if (keepWorldPosition)
        {
            if (_parent != nil)
            {
                _localPosition = Mat3x3.MultiplyFloat2(m: try! _parent!._cachedMatrix.Invert(), vec: _worldPosition);
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
    
    private func SetLocalPosition(position: Float2)
    {
        _localPosition = position;
        self.InternalWorldRefresh();
    }
    
    private func SetWorldPosition(position: Float2)
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
    
    private func SetLocalScale(scale: Float2)
    {
        _localScale = scale;
        self.InternalWorldRefresh();
    }
    
    private func SetWorldScale(scale: Float2)
    {
        _worldScale = scale;
        self.InternalLocalRefresh();
    }
    
    private func SetLocalShear(shear: Float2)
    {
        _localShear = shear;
        self.InternalWorldRefresh();
    }
    
    private func SetWorldShear(shear: Float2)
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
            _worldPosition = Mat3x3.MultiplyFloat2(m: _parent!.WorldTRSS, vec: _localPosition);
            _worldRotation = _parent!._worldRotation + _localRotation;
            _worldScale = Float2.Scale(_parent!._worldScale, _localScale);
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
            _localPosition = Mat3x3.MultiplyFloat2(m: try! _parent!._cachedMatrix.Invert(), vec: _worldPosition);
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

// Created by Alex Griffin on 31/12/19.
