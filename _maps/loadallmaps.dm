#define TRAVIS_MASS_MAP_BUILD
#define MAP_TRANSITION_CONFIG DEFAULT_MAP_TRANSITION_CONFIG

#include "deltastation.dm"
#ifdef MAP_OVERRIDE_FILES
	#undef MAP_OVERRIDE_FILES
#endif

#include "metastation.dm"
#ifdef MAP_OVERRIDE_FILES
	#undef MAP_OVERRIDE_FILES
#endif

#include "omegastation.dm"
#ifdef MAP_OVERRIDE_FILES
	#undef MAP_OVERRIDE_FILES
#endif

#include "pubbystation.dm"
#ifdef MAP_OVERRIDE_FILES
	#undef MAP_OVERRIDE_FILES
#endif

#include "tgstation2.dm"
#ifdef MAP_OVERRIDE_FILES
	#undef MAP_OVERRIDE_FILES
#endif

#include "map_files\generic\z2.dmm"
#include "map_files\generic\z3.dmm"
#include "map_files\generic\z4.dmm"
#include "map_files\generic\lavaland.dmm"
#include "map_files\generic\z6.dmm"
#include "map_files\generic\z7.dmm"
#include "map_files\generic\z8.dmm"
#include "map_files\generic\z9.dmm"
#include "map_files\generic\z10.dmm"
#include "map_files\generic\z11.dmm"

#undef TRAVIS_MASS_MAP_BUILD

#ifdef TRAVISBUILDING
#include "templates.dm"
#endif

#include "runtimestation.dm"

#define BYOND_WHY_YOU_NO_ALLOW_INCLUDE_LAST_LINE //because byond fails to compile if the last thing in a file is an include.
