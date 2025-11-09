/*
/obj/item/storage/on_object_saved(map_string, turf/current_loc)
	. = ..()

	var/parent_container_id_tag
	if(length(contents))
		parent_container_id_tag = assign_random_name()
		GLOB.save_containers_parents[src] = parent_container_id_tag

	for(var/obj/target_obj in contents)
		//if(obj_blacklist[target_atom.type]) // this needs to be a GLOB
		//	continue
		if(!target_obj.is_saveable(current_loc))
			continue

		GLOB.save_containers_children[target_obj] = parent_container_id_tag

		target_obj.on_object_saved(map_string, current_loc)
		var/metadata = generate_tgm_metadata(target_obj)
		TGM_MAP_BLOCK(map_string, target_obj.type, metadata)
*/

/obj/item/storage/briefcase/secure/get_save_vars()
	. = ..()
	. += NAMEOF(src, stored_lock_code)
	return .

/obj/item/wallframe/secure_safe/get_save_vars()
	. = ..()
	. += NAMEOF(src, stored_lock_code)
	return .

/obj/structure/secure_safe/get_save_vars()
	. = ..()
	. += NAMEOF(src, stored_lock_code)
	return .

/obj/structure/safe/get_save_vars()
	. = ..()
	. += NAMEOF(src, open)
	. += NAMEOF(src, locked)
	. += NAMEOF(src, tumblers)
	. += NAMEOF(src, explosion_count)
	return .

/obj/structure/safe/get_custom_save_vars()
	. = ..()
	// we don't need to set new tumblers otherwise the tumblers list grows out of control
	.[NAMEOF(src, number_of_tumblers)] = 0
	return .

/obj/structure/safe/PersistentInitialize()
	. = ..()
	update_appearance()
