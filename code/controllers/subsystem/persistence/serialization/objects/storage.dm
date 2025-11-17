/* This is really good for debugging what's inside every object
/obj/proc/on_object_saved(map_string, turf/current_loc, list/obj_blacklist)
	save_stored_contents(map_string, current_loc, obj_blacklist)
*/

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

/obj/structure/filingcabinet/employment/on_object_saved(map_string, turf/current_loc, list/obj_blacklist)
	save_stored_contents(map_string, current_loc, obj_blacklist)

/obj/item/folder/on_object_saved(map_string, turf/current_loc, list/obj_blacklist)
	save_stored_contents(map_string, current_loc, obj_blacklist)

// technically you could do this with all the regular pipes but it might clog
/obj/machinery/disposal/bin/on_object_saved(map_string, turf/current_loc, list/obj_blacklist)
	save_stored_contents(map_string, current_loc, obj_blacklist)
