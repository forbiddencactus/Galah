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
// RenderDelegates are overriden by per-platform implementations.

public protocol RenderDelegate
{
    var RenderTarget: RenderTarget { get };
    
    
    init(_ newRenderTarget: RenderTarget);
    func Draw();
    func SetBackgroundColour(_ colour: Colour);
    func SetTargetResolution(_ resolution: Size);
}

public extension RenderDelegate
{
    func ViewSizeWillChange(width: Float, height: Float)
    {
        ///
    }
}
