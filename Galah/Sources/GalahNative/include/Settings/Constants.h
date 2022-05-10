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
// Some constants.

#ifndef galah_nativetypes_constants
#define galah_nativetypes_constants

#ifndef GSETTINGS_CONSTANTS_DEFAULTBUFFERCAPACITY
#define GSETTINGS_CONSTANTS_DEFAULTBUFFERCAPACITY 16
#endif

// Debug mode
#if DEBUG
#define GALAH_DEBUG 1
#endif

#define GALAH_FORCE_SAFEMODE 0

#if GALAH_FORCE_SAFEMODE || GALAH_DEBUG
#define GALAH_SAFEMODE 1
#endif

// Thread
#define GALAH_THREAD_JOBBUFFER_SIZE 64
#define GALAH_THREAD_THREADCOUNTPERPROCESSOR 2

#endif
