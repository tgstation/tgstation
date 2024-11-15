/datum/material/declent_ru(case_id, list/ru_names_override)
	. = name
	if(!ispath(sheet_type))
		CRASH("Sheet type couldn't be declented because it's not a path!")
	var/atom/sheet = sheet_type
	var/list/list_to_use = ru_names_override || ru_names_toml(name) || ru_names_toml(sheet:name)
	if(length(list_to_use) && list_to_use["base"] == name && list_to_use[case_id])
		return list_to_use[case_id]
	return name
