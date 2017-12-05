#undef CURRENT_RESIDENT_FILE

#define LIST_MODE_NUM 0
#define LIST_MODE_TEXT 1
#define LIST_MODE_FLAG 2

/datum/config_entry
	var/name	//read-only, this is determined by the last portion of the derived entry type
	var/value
	var/default	//read-only, just set value directly
	
	var/resident_file	//the file which this belongs to, must be set
	var/modified = FALSE	//set to TRUE if the default has been overridden by a config entry

	var/protection = NONE
	var/abstract_type = /datum/config_entry	//do not instantiate if type matches this

	var/dupes_allowed = FALSE

/datum/config_entry/New()
	if(!resident_file)
		CRASH("Config entry [type] has no resident_file set")
	if(type == abstract_type)
		CRASH("Abstract config entry [type] instatiated!")	
	name = lowertext(type2top(type))
	if(islist(value))
		var/list/L = value
		default = L.Copy()
	else
		default = value

/datum/config_entry/Destroy()
	config.RemoveEntry(src)
	return ..()

/datum/config_entry/can_vv_get(var_name)
	. = ..()
	if(var_name == "value" || var_name == "default")
		. &= !(protection & CONFIG_ENTRY_HIDDEN)

/datum/config_entry/vv_edit_var(var_name, var_value)
	var/static/list/banned_edits = list("name", "default", "resident_file", "protection", "abstract_type", "modified", "dupes_allowed")
	if(var_name == "value")
		if(protection & CONFIG_ENTRY_LOCKED)
			return FALSE
		. = ValidateAndSet("[var_value]")
		if(.)
			var_edited = TRUE
		return
	if(var_name in banned_edits)
		return FALSE
	return ..()

/datum/config_entry/proc/VASProcCallGuard(str_val)
	. = !(IsAdminAdvancedProcCall() && GLOB.LastAdminCalledProc == "ValidateAndSet" && GLOB.LastAdminCalledTargetRef == "[REF(src)]")
	if(!.)
		log_admin_private("Config set of [type] to [str_val] attempted by [key_name(usr)]")

/datum/config_entry/proc/ValidateAndSet(str_val)
	VASProcCallGuard(str_val)
	CRASH("Invalid config entry type!")

/datum/config_entry/proc/ValidateKeyedList(str_val, list_mode, splitter)
	str_val = trim(str_val)
	var/key_pos = findtext(str_val, splitter)
	var/key_name = null
	var/key_value = null

	if(key_pos || list_mode == LIST_MODE_FLAG)
		key_name = lowertext(copytext(str_val, 1, key_pos))
		key_value = copytext(str_val, key_pos + 1)
		var/temp
		var/continue_check
		switch(list_mode)
			if(LIST_MODE_FLAG)
				temp = TRUE
				continue_check = TRUE
			if(LIST_MODE_NUM)
				temp = text2num(key_value)
				continue_check = !isnull(temp)
			if(LIST_MODE_TEXT)
				temp = key_value
				continue_check = temp
		if(continue_check && ValidateKeyName(key_name))
			value[key_name] = temp
			return TRUE
	return FALSE

/datum/config_entry/proc/ValidateKeyName(key_name)
	return TRUE

/datum/config_entry/string
	value = ""
	abstract_type = /datum/config_entry/string
	var/auto_trim = TRUE

/datum/config_entry/string/vv_edit_var(var_name, var_value)
	return var_name != "auto_trim" && ..()

/datum/config_entry/string/ValidateAndSet(str_val)
	if(!VASProcCallGuard(str_val))
		return FALSE
	value = auto_trim ? trim(str_val) : str_val
	return TRUE

/datum/config_entry/number
	value = 0
	abstract_type = /datum/config_entry/number
	var/integer = TRUE
	var/max_val = INFINITY
	var/min_val = -INFINITY

/datum/config_entry/number/ValidateAndSet(str_val)
	if(!VASProcCallGuard(str_val))
		return FALSE
	var/temp = text2num(trim(str_val))
	if(!isnull(temp))
		value = Clamp(integer ? round(temp) : temp, min_val, max_val)
		if(value != temp && !var_edited)
			log_config("Changing [name] from [temp] to [value]!")
		return TRUE
	return FALSE

/datum/config_entry/number/vv_edit_var(var_name, var_value)
	var/static/list/banned_edits = list("max_val", "min_val", "integer")
	return !(var_name in banned_edits) && ..()

/datum/config_entry/flag
	value = FALSE
	abstract_type = /datum/config_entry/flag

/datum/config_entry/flag/ValidateAndSet(str_val)
	if(!VASProcCallGuard(str_val))
		return FALSE
	value = text2num(trim(str_val)) != 0
	return TRUE

/datum/config_entry/number_list
	abstract_type = /datum/config_entry/number_list
	value = list()

/datum/config_entry/number_list/ValidateAndSet(str_val)
	if(!VASProcCallGuard(str_val))
		return FALSE
	str_val = trim(str_val)
	var/list/new_list = list()
	var/list/values = splittext(str_val," ")
	for(var/I in values)
		var/temp = text2num(I)
		if(isnull(temp))
			return FALSE
		new_list += temp
	if(!new_list.len)
		return FALSE
	value = new_list
	return TRUE

/datum/config_entry/keyed_flag_list
	abstract_type = /datum/config_entry/keyed_flag_list
	value = list()
	dupes_allowed = TRUE

/datum/config_entry/keyed_flag_list/ValidateAndSet(str_val)
	if(!VASProcCallGuard(str_val))
		return FALSE
	return ValidateKeyedList(str_val, LIST_MODE_FLAG, " ")

/datum/config_entry/keyed_number_list
	abstract_type = /datum/config_entry/keyed_number_list
	value = list()
	dupes_allowed = TRUE
	var/splitter = " "

/datum/config_entry/keyed_number_list/vv_edit_var(var_name, var_value)
	return var_name != "splitter" && ..()

/datum/config_entry/keyed_number_list/ValidateAndSet(str_val)
	if(!VASProcCallGuard(str_val))
		return FALSE
	return ValidateKeyedList(str_val, LIST_MODE_NUM, splitter)

/datum/config_entry/keyed_string_list
	abstract_type = /datum/config_entry/keyed_string_list
	value = list()
	dupes_allowed = TRUE
	var/splitter = " "

/datum/config_entry/keyed_string_list/vv_edit_var(var_name, var_value)
	return var_name != "splitter" && ..()

/datum/config_entry/keyed_string_list/ValidateAndSet(str_val)
	if(!VASProcCallGuard(str_val))
		return FALSE
	return ValidateKeyedList(str_val, LIST_MODE_TEXT, splitter)

#undef LIST_MODE_NUM
#undef LIST_MODE_TEXT
#undef LIST_MODE_FLAG
