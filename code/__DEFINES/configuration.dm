//config files
#define CONFIG_GENERAL "config.txt"
#define CONFIG_GAME_OPTIONS "game_options.txt"
#define CONFIG_DATABASE "database.txt"

#define CONFIG_ENTRY_FILES list(CONFIG_GENERAL, CONFIG_GAME_OPTIONS, CONFIG_DATABASE)

#define CONFIG_MAPS_FILE "maps.txt"

//flags
#define CONFIG_ENTRY_LOCKED 1	//can't edit
#define CONFIG_ENTRY_HIDDEN 3	//can't see value, hidden implies locked

//Used by jobs_have_maint_access
#define ASSISTANTS_HAVE_MAINT_ACCESS 1
#define SECURITY_HAS_MAINT_ACCESS 2
#define EVERYONE_HAS_MAINT_ACCESS 4