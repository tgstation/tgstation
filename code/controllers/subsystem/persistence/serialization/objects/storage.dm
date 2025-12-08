/obj/structure/closet/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, name)
	// we need these to keep track of paint jobs via airlock painters
	. += NAMEOF(src, icon_state)
	. += NAMEOF(src, base_icon_state)
	. += NAMEOF(src, icon_door)

/obj/structure/closet/on_object_saved(map_string, turf/current_loc, list/obj_blacklist)
	save_stored_contents(map_string, current_loc, obj_blacklist, include_ids=FALSE)

/obj/item/storage/on_object_saved(map_string, turf/current_loc, list/obj_blacklist)
	save_stored_contents(map_string, current_loc, obj_blacklist)

/obj/item/storage/briefcase/secure/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, stored_lock_code)
	return .

/obj/item/wallframe/secure_safe/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, stored_lock_code)
	return .

/obj/structure/secure_safe/on_object_saved(map_string, turf/current_loc, list/obj_blacklist)
	save_stored_contents(map_string, current_loc, obj_blacklist)

/obj/structure/secure_safe/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, stored_lock_code)
	return .

/obj/structure/safe/on_object_saved(map_string, turf/current_loc, list/obj_blacklist)
	save_stored_contents(map_string, current_loc, obj_blacklist)

/obj/structure/safe/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, open)
	. += NAMEOF(src, locked)
	. += NAMEOF(src, tumblers)
	. += NAMEOF(src, explosion_count)
	return .

/obj/structure/safe/get_custom_save_vars(save_flags=ALL)
	. = ..()
	// we don't need to set new tumblers otherwise the tumblers list grows out of control
	.[NAMEOF(src, number_of_tumblers)] = 0
	return .

/obj/structure/safe/PersistentInitialize()
	. = ..()
	update_appearance()

/obj/structure/filingcabinet/on_object_saved(map_string, turf/current_loc, list/obj_blacklist)
	save_stored_contents(map_string, current_loc, obj_blacklist)

/obj/item/folder/on_object_saved(map_string, turf/current_loc, list/obj_blacklist)
	save_stored_contents(map_string, current_loc, obj_blacklist)

/obj/item/clipboard/on_object_saved(map_string, turf/current_loc, list/obj_blacklist)
	var/list/clipboard_contents = list()
	if(pen)
		clipboard_contents += pen

	for(var/obj/item/paper/paper in contents)
		clipboard_contents += paper

	save_stored_contents(map_string, current_loc, obj_blacklist, clipboard_contents)

/obj/item/clipboard/PersistentInitialize()
	. = ..()

	for(var/clipboard_obj in contents)
		if(istype(clipboard_obj, /obj/item/pen))
			pen = clipboard_obj
		if(istype(clipboard_obj, /obj/item/paper))
			continue // paper is by default inside contents
	update_appearance()

// technically you could do this with all the regular pipes but it might clog
/obj/machinery/disposal/bin/on_object_saved(map_string, turf/current_loc, list/obj_blacklist)
	save_stored_contents(map_string, current_loc, obj_blacklist)

/obj/structure/mop_bucket/janitorialcart/on_object_saved(map_string, turf/current_loc, list/obj_blacklist)
	var/list/janicart_contents = list()
	if(mybag)
		janicart_contents += mybag
	if(mymop)
		janicart_contents += mymop
	if(mybroom)
		janicart_contents += mybroom
	if(myspray)
		janicart_contents += myspray
	if(myreplacer)
		janicart_contents += myreplacer
	if(held_signs.len)
		for(var/obj/item/clothing/suit/caution/sign as anything in held_signs)
			janicart_contents += sign

	if(janicart_contents.len)
		save_stored_contents(map_string, current_loc, obj_blacklist, janicart_contents)

/obj/structure/mop_bucket/janitorialcart/PersistentInitialize()
	. = ..()

	for(var/jani_obj in contents)
		if(istype(jani_obj, /obj/item/storage/bag/trash))
			mybag = jani_obj
		else if(istype(jani_obj, /obj/item/mop))
			mymop = jani_obj
		else if(istype(jani_obj, /obj/item/pushbroom))
			mybroom = jani_obj
		else if(istype(jani_obj, /obj/item/reagent_containers/spray/cleaner))
			myspray = jani_obj
		else if(istype(jani_obj, /obj/item/lightreplacer))
			myreplacer = jani_obj
		else if(istype(jani_obj, /obj/item/clothing/suit/caution))
			// held_signs is a list so slightly different
			held_signs += jani_obj

	update_appearance()

