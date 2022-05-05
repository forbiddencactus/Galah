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
// A circular buffer for our thread manager.

#ifndef ThreadManager_h
#define ThreadManager_h
#include "Thread/Thread.h"

typedef struct
{
    GJob* job[GALAH_THREADMANAGER_NEWJOBBUFFER_SIZE]; // Shared by both.
    GVolatileUInt writeIndex; // Owned by main thread.
    GVolatileUInt readIndex; // Owned by thread.
}GJobManagerBuffer;

#endif
