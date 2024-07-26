// This file is included right at the start of the DME.
// Its purpose is to enable multiple lints (pragmas) that are supported by OpenDream to better validate the codebase
// These are essentially nitpicks the DM compiler should pick up on but doesnt

#if !defined(SPACEMAN_DMM) && defined(OPENDREAM)
// This is in a separate file as a hack to avoid SpacemanDMM
// evaluating the #pragma lines, even if its outside a block it cares about
// (Also so people can code-own it. Shoutout to AA)
#include "tools/ci/od_lints.dm"
#endif
