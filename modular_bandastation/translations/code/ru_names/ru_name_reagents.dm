/datum/reagent
	/// List consists of ("name", "именительный", "родительный", "дательный", "винительный", "творительный", "предложный", "gender")
	var/list/ru_names

/// Необходимо использовать ПЕРЕД изменением var/name, и использовать только этот прок для изменения в рантайме склонений
/datum/reagent/ru_names_rename(list/new_list)
	if(!length(new_list))
		return
	ru_names = new_list

/datum/reagent/New()
	. = ..()
	ru_names_rename(ru_names_toml(LOWER_TEXT(name)))

/datum/reagent/declent_ru(case_id, list/ru_names_override)
	var/list/list_to_use = ru_names_override || ru_names
	if(length(list_to_use) && list_to_use["base"] == name && list_to_use[case_id])
		return list_to_use[case_id]
	if(case_id == "gender")
		return
	return name
