/datum/orderable_item
	var/use_translate = TRUE
	/// List consists of ("name", "именительный", "родительный", "дательный", "винительный", "творительный", "предложный", "gender")
	var/list/ru_names

/datum/orderable_item/New()
	. = ..()
	ru_names = ru_names_toml(purchase_path::name)
	if(!use_translate)
		return
	name = capitalize(declent_ru(NOMINATIVE))

/datum/orderable_item/declent_ru(declent)
	. = name
	if(declent == "gender")
		. = NEUTER
	if(!length(ru_names))
		return .
	return get_declented_value(ru_names, declent, .)
