// TODO these two should be config options
#define PR_ANNOUNCEMENTS_PER_ROUND 5 //The number of unique PR announcements allowed per round
#define STATION_GOAL_BUDGET 1

//config files
#define CONFIG_GET(X) global.config.Get(/datum/config_entry/##X)
#define CONFIG_SET(X, Y) global.config.Set(/datum/config_entry/##X, ##Y)

#define CONFIG_MAPS_FILE "maps.txt"

//flags
/// can't edit
#define CONFIG_ENTRY_LOCKED 1
/// can't see value
#define CONFIG_ENTRY_HIDDEN 2

/// Force the config directory to be something other than "config"
#define OVERRIDE_CONFIG_DIRECTORY_PARAMETER "config-directory"
