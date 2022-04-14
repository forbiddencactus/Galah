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
// A wrapper for simple pointer operations.

#ifndef Pointer_h
#define Pointer_h

#include "GalahNative.h"

// Returns a void pointer from a void pointer, useful to nab pointers from value types without Swift complaining. 
void* glh_pointer_get(void* ptr);

#endif
