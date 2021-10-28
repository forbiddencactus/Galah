//
//  File.h
//  
//
//  Created by Alex Griffin on 29/10/2021.
//

#ifndef SwiftRuntime_h
#define SwiftRuntime_h
#include "GalahNative.h"

typedef struct
{
    void* isaPointer;
    GUInt32 strongRetainCounts;
    GUInt32 weakRetainCounts;
} GClassHeader;

void galah_set_refcount(void* obj, GUInt newRefCount);

#endif /* File_h */
