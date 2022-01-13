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
// Helpers to dealloc a swift object.

#include "SwiftRuntime/ObjectDealloc.h"
#include "GalahNative.h"

void glh_runSwiftDestructor( void** destructorRef, void *object)
{
    if (destructorRef != NULL)
    {
        SwiftDestructor destructor = (SwiftDestructor)(*destructorRef);
        destructor(object);
    }
}
