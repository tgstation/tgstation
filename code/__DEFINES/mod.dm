/// Default value for the max_complexity var on modsuits
#define DEFAULT_MAX_COMPLEXITY 20

/// Passive module, just acts when put in naturally.
#define MODULE_PASSIVE 0
/// Usable module, does something when you press a button.
#define MODULE_USABLE 1
/// Toggle module, you turn it on/off and it does stuff.
#define MODULE_TOGGLE 2
/// Actively usable module, you may only have one selected at a time.
#define MODULE_ACTIVE 3

/// Global list of all /datum/mod_theme
GLOBAL_LIST_INIT(mod_themes, setup_mod_themes())
