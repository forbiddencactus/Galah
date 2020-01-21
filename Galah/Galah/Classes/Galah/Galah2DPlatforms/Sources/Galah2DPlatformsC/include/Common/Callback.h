//https://originware.com/blog/?p=265
//https://medium.com/@prafullkumar77/pointers-in-swift-f8d651d0e724
#include "Structs.h"

typedef void (* CallbackWithSize)(BridgeSize);

static CallbackWithSize viewSizeChangedCallback;
void createViewSizeChangedCallback(CallbackWithSize callback);
