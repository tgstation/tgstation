/datum/config_entry/string/comms_key
	protection = CONFIG_ENTRY_HIDDEN

/datum/config_entry/string/comms_key/ValidateAndSet(str_val)
    return str_val != "default_pwd" && length(str_val) > 6 && ..()

/datum/config_entry/string/cross_server_address
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/string/cross_server_address/ValidateAndSet(str_val)
    return str_val != "byond:\\address:port" && ..()

/datum/config_entry/string/cross_comms_name

GLOBAL_VAR_INIT(medals_enabled, TRUE)	//will be auto set to false if the game fails contacting the medal hub to prevent unneeded calls.

/datum/config_entry/string/medal_hub_address

/datum/config_entry/string/medal_hub_password
	protection = CONFIG_ENTRY_HIDDEN