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
// Swift runtime stuff.

#ifndef CRuntime_h
#define CRuntime_h

const void * _Nullable swift_getTypeByMangledNameInContext(
                        const char * _Nullable typeNameStart,
                        int typeNameLength,
                        const void * _Nullable context,
                        const void * _Nullable const * _Nullable genericArgs);

const void * _Nullable swift_allocObject(
                    const void * _Nullable type,
                    int requiredSize,
                    int requiredAlignmentMask);

#endif /* File_h */
