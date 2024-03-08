// This file is included right at the start of the DME.
// Its purpose is to enable multiple lints (pragmas) that are supported by OpenDream to better validate the codebase
// These are essentially nitpicks the DM compiler should pick up on but doesnt

#ifndef SPACEMAN_DMM
#ifdef OPENDREAM
/*
	For the person who asks
	"AA, why are these in their own file?"
	Quite simple
	1. I can codeown that file
	2. You need to do it with an include as a hack to avoid SpacemanDMM evaluating the #pragma lines, even if its outside a block it cares about
*/
#include "../tools/ci/od_lints.dm"
#endif
#endif
