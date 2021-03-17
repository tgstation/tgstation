/// Default value for the max_complexity var on modsuits
#define DEFAULT_MAX_COMPLEXITY 15

/// Passive module, just acts when put in.
#define MOD_PASSIVE 0
/// Active module, you turn it on for it to have effect.
#define MOD_ACTIVE 1
/// Actively usable module, you may only have one at a time.
#define MOD_USABLE 2

/// Global list of all /datum/mod_theme
GLOBAL_LIST_INIT(mod_themes, setup_mod_themes())
