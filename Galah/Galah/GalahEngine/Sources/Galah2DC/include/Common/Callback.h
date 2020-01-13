//https://originware.com/blog/?p=265
#include "Structs.h"

typedef void (* CallbackWithSize)(BridgeSize);

static CallbackWithSize viewSizeChangedCallback;
void createViewSizeChangedCallback(CallbackWithSize callback);
