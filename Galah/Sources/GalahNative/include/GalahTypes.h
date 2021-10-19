//---- Galah Engine---------------------------------------------------------//
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
// C typedefs for convenience or to simplify platform abstraction down the line. 

#ifndef GalahTypes_h
#define GalahTypes_h

#include <stdint.h>

typedef size_t GMemSize;

// Integers...
typedef uint GUInt;
typedef ushort GUShort;
typedef uint8_t GUInt8;
typedef uint16_t GUInt16;
typedef uint32_t GUInt32;
typedef uint64_t GUInt64;

// Volatile types...
typedef volatile bool GVolatileBool;
typedef volatile GUInt64 GVolatileUInt64;

#endif
