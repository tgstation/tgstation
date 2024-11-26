//config files
#define CONFIG_GET(X) global.config.Get(/datum/config_entry/##X)
#define CONFIG_SET(X, Y) global.config.Set(/datum/config_entry/##X, ##Y)

#define CONFIG_MAPS_FILE "maps.txt"

//flags
/// can't edit
#define CONFIG_ENTRY_LOCKED (1<<0)
/// can't see value
#define CONFIG_ENTRY_HIDDEN (1<<1)

/// Force the config directory to be something other than "config"
#define OVERRIDE_CONFIG_DIRECTORY_PARAMETER "config-directory"

// Config entry types
#define VALUE_MODE_NUM 0
#define VALUE_MODE_TEXT 1
#define VALUE_MODE_FLAG 2

#define KEY_MODE_TEXT 0
#define KEY_MODE_TYPE 1

// Flags for respawn config
/// Respawn not allowed
#define RESPAWN_FLAG_DISABLED 0
/// Respawn as much as you'd like
#define RESPAWN_FLAG_FREE 1
/// Can respawn, but not as the same character
#define RESPAWN_FLAG_NEW_CHARACTER 2

// Human authority defines
#define HUMAN_AUTHORITY_DISABLED "DISABLED"
#define HUMAN_AUTHORITY_HUMAN_WHITELIST "HUMAN_WHITELIST"
#define HUMAN_AUTHORITY_NON_HUMAN_WHITELIST "NON_HUMAN_WHITELIST"
#define HUMAN_AUTHORITY_ENFORCED "ENFORCED"
