//
//  File.h
//  
//
//  Created by Alex Griffin on 3/9/21.
//

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
