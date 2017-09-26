//config files
#define CONFIG_DEF(X) X { resident_file = CURRENT_RESIDENT_FILE }; X

#define CONFIG_MAPS_FILE "maps.txt"

//flags
#define CONFIG_ENTRY_LOCKED 1	//can't edit
#define CONFIG_ENTRY_HIDDEN 3	//can't see value, hidden implies locked

//Used by jobs_have_maint_access
#define ASSISTANTS_HAVE_MAINT_ACCESS 1
#define SECURITY_HAS_MAINT_ACCESS 2
#define EVERYONE_HAS_MAINT_ACCESS 4