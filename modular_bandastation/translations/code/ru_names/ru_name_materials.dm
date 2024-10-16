/datum/material/declent_ru(case_id, list/ru_names_override)
	. = name
	if(!ispath(sheet_type))
		CRASH("Sheet type couldn't be declented because it's not a path!")
	var/atom/sheet = sheet_type
	var/list/list_to_use = ru_names_override || RU_NAMES_LIST(sheet::ru_name_base, sheet::ru_name_nominative, sheet::ru_name_genitive, sheet::ru_name_dative, sheet::ru_name_accusative, sheet::ru_name_instrumental, sheet::ru_name_prepositional)
	if(length(list_to_use))
		if(list_to_use[case_id] && list_to_use["base"] == name)
			return list_to_use[case_id] || name
	return name
