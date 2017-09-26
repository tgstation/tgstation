//config files
#define CONFIG_DEF(X) /datum/config_entry/##X { resident_file = CURRENT_RESIDENT_FILE }; /datum/config_entry/##X
#define CONFIG_GET(X) config.Get(/datum/config_entry/##X)
#define CONFIG_SET(X, Y) config.Set(/datum/config_entry/##X, ##Y)

#define CONFIG_MAPS_FILE "maps.txt"

//flags
#define CONFIG_ENTRY_LOCKED 1	//can't edit
#define CONFIG_ENTRY_HIDDEN 2	//can't see value
