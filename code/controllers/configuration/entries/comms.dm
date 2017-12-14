#define CURRENT_RESIDENT_FILE "comms.txt"

CONFIG_DEF(string/comms_key)
	protection = CONFIG_ENTRY_HIDDEN

/datum/config_entry/string/comms_key/ValidateAndSet(str_val)
	return str_val != "default_pwd" && length(str_val) > 6 && ..()

CONFIG_DEF(keyed_string_list/cross_server)
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/keyed_string_list/cross_server/ValidateAndSet(str_val)
	. = ..()
	if(.)
		var/list/newv = list()
		for(var/I in value)
			newv[replacetext(I, "+", " ")] = value[I]
		value = newv

/datum/config_entry/keyed_string_list/cross_server/ValidateListEntry(key_name, key_value)
	return key_value != "byond:\\address:port" && ..()

CONFIG_DEF(string/cross_comms_name)

GLOBAL_VAR_INIT(medals_enabled, TRUE)	//will be auto set to false if the game fails contacting the medal hub to prevent unneeded calls.

CONFIG_DEF(string/medal_hub_address)

CONFIG_DEF(string/medal_hub_password)
	protection = CONFIG_ENTRY_HIDDEN