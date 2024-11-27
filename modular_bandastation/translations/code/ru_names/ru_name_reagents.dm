/datum/reagent
	/// List consists of ("name", "именительный", "родительный", "дательный", "винительный", "творительный", "предложный", "gender")
	var/list/ru_names

/datum/reagent/proc/update_to_ru()
	description = GLOB.ru_reagent_descs[name] || description

/datum/reagent/New()
	. = ..()
	ru_names = ru_names_toml(name)

/datum/reagent/declent_ru(declent)
	. = name
	if(declent == "gender")
		. = NEUTER
	if(!length(ru_names) || ru_names["base"] != name)
		return .
	return get_declented_value(ru_names, declent, .)
