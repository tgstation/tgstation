/datum/orderable_item
	var/use_translate = TRUE

/datum/orderable_item/New()
	. = ..()
	if(!use_translate)
		return
	name = capitalize(declent_ru(NOMINATIVE))

/datum/orderable_item/declent_ru(case_id, list/ru_names_override)
	. = name
	if(!ispath(purchase_path))
		CRASH("Purchase type couldn't be declented because it's not a path!")
	var/list/list_to_use = ru_names_override || ru_names_toml(purchase_path::name)
	if(length(list_to_use) && list_to_use["base"] == name && list_to_use[case_id])
		return list_to_use[case_id]
	return name
