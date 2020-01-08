/datum/config_entry/number/fail2topic_rate_limit
	config_entry_value = 10		//deciseconds

/datum/config_entry/number/fail2topic_max_fails
	config_entry_value = 5

/datum/config_entry/string/fail2topic_rule_name
	config_entry_value = "_dd_fail2topic"
	protection = CONFIG_ENTRY_LOCKED		//affects physical server configuration, no touchies!!

/datum/config_entry/flag/fail2topic_enabled
	config_entry_value = TRUE

/datum/config_entry/number/topic_max_size
	config_entry_value = 8192

/datum/config_entry/keyed_list/topic_rate_limit_whitelist
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_FLAG
