/datum/design
	var/use_declented_name = TRUE

/datum/design/New()
	. = ..()
	if(!use_declented_name || !build_path)
		return
	var/atom/design_result = build_path
	name = capitalize(declent_ru_initial(design_result::name, NOMINATIVE, name))

/datum/crafting_recipe
	var/use_declented_name = TRUE

/datum/crafting_recipe/New()
	. = ..()
	if(!use_declented_name || !result)
		return
	var/atom/crafting_result = result
	name = capitalize(declent_ru_initial(crafting_result::name, NOMINATIVE, name))
