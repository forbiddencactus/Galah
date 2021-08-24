/*
MIT License

Copyright © 2020, 2021 Alexis Griffin.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#include "Memory/Pointer.h"
#include "Memory/Alloc.h"

GPtr ptr_add(GPtr ptr, MemSize typesize, GUInt amount)
{
    GPtr ret;
    ret.ptr = ptr.ptr + (amount * typesize);
    return ret;
}

GPtr ptr_sub(GPtr ptr, MemSize typesize, GUInt amount)
{
    GPtr ret;
    ret.ptr = ptr.ptr - (amount * typesize);
    return ret;
}

void ptr_set(GPtr* outptr, void* inptr)
{
    outptr->ptr = inptr;
}

// Assigns the value of inassignptr into the location pointed to by ptr.
void ptr_assign(GPtr* ptr, void* inassignptr, MemSize size)
{
    glh_memcpy(ptr->ptr, inassignptr, size);
}

void ptr_setnull(GPtr* inptr)
{
    inptr->ptr = NULL;
}
