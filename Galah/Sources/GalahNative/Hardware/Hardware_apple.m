//---- Galah Engine --------------------------------------------------------//
//
// This source file is part of the Galah open source game engine.
//
// Copyright © 2020 - 2022, the Galah contributors.
//
// Licensed under the MIT Licence.
//
// You can find a copy of Galah's licence in LICENCE.MD
// You can find a list of Galah's contributors in CONTRIBUTORS.MD
// You can find a list of Galah's attributions in ATTRIBUTIONS.MD
//
// galah-engine.org | https://github.com/forbiddencactus/Galah
//--------------------------------------------------------------------------//
// Wrapper around functions related to hardware queries.

#if __APPLE__
#include "Hardware/Hardware.h"
#import <Foundation/Foundation.h>

// Returns the number of available CPU cores.
GUInt glh_hardware_getactiveprocessorcount()
{
    return (GUInt)[[NSProcessInfo processInfo] activeProcessorCount];
}

// Returns the advertised number of CPU cores.
GUInt glh_hardware_getadvertisedprocessorcount()
{
    return (GUInt)[[NSProcessInfo processInfo] processorCount];
}

#endif /* Hardware_h */
