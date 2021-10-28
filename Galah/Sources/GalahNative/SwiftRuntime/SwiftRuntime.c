//
//  File.c
//  
//
//  Created by Alex Griffin on 29/10/2021.
//

#include "SwiftRuntime/SwiftRuntime.h"

void galah_set_refcount(void* obj, GUInt newRefCount)
{
    GClassHeader* classHeader = (GClassHeader*)obj;
    
    classHeader->strongRetainCounts = newRefCount;
}
