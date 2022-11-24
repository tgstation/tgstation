// Representative icons for each creafting recipe
/datum/asset/spritesheet/food
	name = "food"

/datum/asset/spritesheet/food/create_spritesheets()
	var/list/id_list = list()
	for (var/path in subtypesof(/obj/item/food))
		var/obj/item/food/item = initial(path)
		var/icon_file = initial(item.icon)
		var/icon_state = initial(item.icon_state)
		#ifdef UNIT_TESTS
		if(!(icon_state in icon_states(icon_file)))
			stack_trace("recipe [R] with icon '[icon_file]' missing state '[icon_state]'")
			continue
		#endif
		var/icon/I = icon(icon_file, icon_state, SOUTH)
		var/id = sanitize_css_class_name("[path]")
		if(id in id_list) //no dupes
			continue
		id_list += id
		Insert(id, I)
