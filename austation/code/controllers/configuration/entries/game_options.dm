/datum/config_entry/flag/autosandbox_enabled //whether or not autosandbox is enabled.

/datum/config_entry/number/autosandbox_min //the threshold at which the server will drop to sandbox (default: 5 players)
	config_entry_value = 5
	min_val = 0
	integer = TRUE

/datum/config_entry/number/autosandbox_max //the threshold at which the server will swap to secret (default: 10 players)
	config_entry_value = 10
	min_val = 0
	integer = TRUE
