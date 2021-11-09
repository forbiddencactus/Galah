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

#if INTPTR_MAX == INT64_MAX
#define GALAH_64BIT 1
#elif INTPTR_MAX == INT32_MAX
#define GALAH_64BIT 0
#else
#error Unknown pointer size or missing size macros!
#endif

typedef size_t GMemSize;

// Integers...
typedef uint8_t GUInt8;
typedef uint16_t GUInt16;
typedef uint32_t GUInt32;
typedef uint64_t GUInt64;
typedef int8_t GInt8;
typedef int16_t GInt16;
typedef int32_t GInt32;
typedef int64_t GInt64;

// ARM 64 bit short... https://armkeil.blob.core.windows.net/developer/Files/pdf/graphics-and-multimedia/Porting%20to%20ARM%2064-bit.pdf
typedef GUInt16 GUShort;
typedef GInt16 GShort;

// Native word size...
#if GALAH_64BIT
typedef GInt64 GInt;
typedef GUInt64 GUInt;
#else
typedef GInt32 GInt;
typedef GUInt32 GUInt;
#endif

// Volatile types...
typedef volatile GInt GVolatileInt;
typedef volatile GUInt GVolatileUInt;
typedef volatile bool GVolatileBool;
typedef volatile GUInt64 GVolatileUInt64;

#endif
