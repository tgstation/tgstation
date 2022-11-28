// Default container icon lookup by reagent type path

/datum/asset/spritesheet/reagents
	name = "reagents"

/datum/asset/spritesheet/reagents/create_spritesheets()
	var/list/id_list = list()
	for (var/path in subtypesof(/datum/reagent/))
		var/datum/reagent/reagent = initial(path)
		var/atom/item = initial(reagent.default_container)
		var/icon_file = initial(item.icon)
		var/icon_state = initial(item.icon_state)
		#ifdef UNIT_TESTS
		if(!(icon_state in icon_states(icon_file)))
			stack_trace("reagent container [R] with icon '[icon_file]' missing state '[icon_state]'")
			continue
		#endif
		var/icon/I = icon(icon_file, icon_state, SOUTH)
		var/id = sanitize_css_class_name("[path]")
		if(id in id_list) //no dupes
			continue
		id_list += id
		Insert(id, I)
