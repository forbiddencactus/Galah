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

#include "Memory/Alloc.h"

void* glh_malloc(MemSize size)
{
    return malloc(size);
}

void glh_free(void* ptr)
{
    free(ptr);
}

void* glh_memcpy(void* dest, const void* src, MemSize size)
{
    return memcpy(dest, src, size);
}

void* glh_memmove(void* dest, const void* src, MemSize size)
{
    return memmove(dest, src, size);
}

void* glh_memset(void* dest, int value, MemSize size)
{
    return memset(dest, value, size);
}
