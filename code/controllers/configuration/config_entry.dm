#undef CURRENT_RESIDENT_FILE
/datum/config_entry
	var/name	//read-only, this is determined by the last portion of the derived entry type
	var/value
	var/default	//read-only, just set value directly
	
	var/resident_file	//the file which this belongs to, must be set
	var/modified = FALSE	//set to TRUE if the default has been overridden by a config entry

	var/protection = NONE
	var/abstract_type = /datum/config_entry	//do not instantiate if type matches this

/datum/config_entry/New()
	if(!resident_file)
		CRASH("Config entry [type] has no resident_file set")
	if(type == abstract_type)
		CRASH("Abstract config entry [type] instatiated!")	
	name = lowertext(type2top(type))
	default = value
	config.entries[name] = src
	config.entries_by_type[type] = src

/datum/config_entry/Destroy()
	config.entries -= name
	config.entries_by_type -= type
	return ..()

/datum/config_entry/can_vv_get(var_name)
	. = ..()
	if(var_name == "value" || var_name == "default")
		. &= !(protection & CONFIG_ENTRY_HIDDEN)

/datum/config_entry/vv_edit_var(var_name, var_value)
	var/static/list/banned_edits = list("name", "default", "resident_file", "protection", "abstract_type", "modified")
	if(var_name == "value")
		if(protection & CONFIG_ENTRY_LOCKED)
			return FALSE
		var_edited = TRUE
		return ValidateAndSet("[var_value]")
	if(var_name in banned_edits)
		return FALSE
	return ..()

/datum/config_entry/proc/ValidateAndSet(str_val)
	CRASH("Invalid config entry type!")

/datum/config_entry/string
	value = ""
	abstract_type = /datum/config_entry/string
	var/auto_trim = TRUE

/datum/config_entry/string/vv_edit_var(var_name, var_value)
	return var_name == "auto_trim" ? FALSE : ..()

/datum/config_entry/string/ValidateAndSet(str_val)
	value = auto_trim ? trim(str_val) : str_val
	return TRUE

/datum/config_entry/string/untrimmed
	abstract_type = /datum/config_entry/string/untrimmed
	auto_trim = FALSE

/datum/config_entry/number
	value = 0
	abstract_type = /datum/config_entry/number
	var/integer = TRUE
	var/max_val = INFINITY
	var/min_val = -INFINITY

/datum/config_entry/number/ValidateAndSet(str_val)
	var/temp = text2num(str_val)
	if(!isnull(temp))
		value = Clamp(integer ? round(temp) : temp, min_val, max_val)
		if(value != temp && !var_edited)
			WRITE_FILE(GLOB.config_error_log, "Changing [name] from [temp] to [value]!")
		return TRUE
	return FALSE

/datum/config_entry/number/vv_edit_var(var_name, var_value)
	var/static/list/banned_edits = list("max_val", "min_val", "integer")
	return !(var_name in banned_edits) && ..()

/datum/config_entry/flag
	value = FALSE
	abstract_type = /datum/config_entry/flag

/datum/config_entry/flag/ValidateAndSet(str_val)
	value = text2num(str_val) != 0
	return TRUE
