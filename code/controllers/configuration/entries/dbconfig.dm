/datum/config_entry/flag/sql_enabled	// for sql switching
	protection = CONFIG_ENTRY_LOCKED

/datum/config_entry/string/address
	config_entry_value = "localhost"
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN
	
/datum/config_entry/number/port
	config_entry_value = 3306
	min_val = 0
	max_val = 65535
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/datum/config_entry/string/feedback_database
	config_entry_value = "test"
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/datum/config_entry/string/feedback_login
	config_entry_value = "root"
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/datum/config_entry/string/feedback_password
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/datum/config_entry/string/feedback_tableprefix
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN
