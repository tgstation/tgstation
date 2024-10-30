// All new mod's includes here
// Some modules can be easy excludes from code compile sequence by commenting #define you need to remove in code\__DEFINES\__meta_modpaks_includes.dm
// Keep in mind, that module may not be only in modular folder but also embedded directly in TG code and covered with #ifdef - #endif structure

#include "_modpacks_subsystem.dm" //actually mods subsystem

/// FEATURES
#if CHEBUREK_CAR
	#include "features\cheburek_car\includes.dm"
#endif

/// PEREVODY
#if RU_CRAYONS 
	#include "perevody\ru_crayons\includes.dm"
#endif
#if RU_VENDORS
	#include "perevody\ru_vendors\includes.dm"
#endif

/// REVERTS
