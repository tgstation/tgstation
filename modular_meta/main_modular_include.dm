// All new mod's includes here
// Some modules can be easy excludes from code compile sequence by commenting #define you need to remove in code\__DEFINES\__meta_modpaks_includes.dm
// Keep in mind, that module may not be only in modular folder but also embedded directly in TG code and covered with #ifdef - #endif structure

#include "__modpack\assets_modpacks.dm"
#include "__modpack\modpack.dm" //modpack obj
#include "__modpack\modpacks_subsystem.dm" //actually mods subsystem + tgui in "tgui/packages/tgui/interfaces/Modpacks.tsx"

/* --FEATURES-- */

#include "features\additional_circuit\includes.dm"
#if CHEBUREK_CAR
	#include "features\cheburek_car\includes.dm"
#endif
#include "features\venom_knife\includes.dm"
/* -- REVERTS -- */

#include "reverts\revert_glasses_protect_welding\includes.dm"

/* --TRANSLATIONS-- */

#if RU_CRAYONS
	#include "ru_translate\ru_crayons\includes.dm"
#endif
#include "ru_translate\ru_tweak_say_fonts\includes.dm"
#if RU_VENDORS
	#include "ru_translate\ru_vendors\includes.dm"
#endif
