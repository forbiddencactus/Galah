#ifndef Callback_h
#define Callback_h


//https://originware.com/blog/?p=265
//https://medium.com/@prafullkumar77/pointers-in-swift-f8d651d0e724
#include "NativeTypes/Rects.h"

typedef void (* CallbackWithSize)(NativeSize);

static CallbackWithSize viewSizeChangedCallback;
void createViewSizeChangedCallback(CallbackWithSize callback);

#endif
