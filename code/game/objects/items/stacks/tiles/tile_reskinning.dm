/////////////////////
// Tile reskinning //
/////////////////////
// Q: What is this?
// A: A simple function to allow you to change what tiles you place with a stack of tiles.
// Q: Why do it this way?
// A: This allows players more freedom to do beautiful-looking builds.
// Q: Great! Can I use this for all floors?
// A: Yep! Just change the tile stack's `tile_reskin_lists` list variable and set which variants you want to be able to convert into.

GLOBAL_LIST_EMPTY(tile_reskin_lists)

GLOBAL_LIST_EMPTY(tile_dir_lists)

/**
 * Caches associative lists with type path index keys and images of said type's initial icon state (typepath -> image).
 */
/obj/item/stack/tile/proc/tile_reskin_list(list/values)
	var/string_id = values.Join("-")
	. = GLOB.tile_reskin_lists[string_id]
	if(.)
		return
	for(var/path in values)
		var/obj/item/stack/tile/type_cast_path = path
		values[path] = image(icon = initial(type_cast_path.icon), icon_state = initial(type_cast_path.icon_state))
	return GLOB.tile_reskin_lists[string_id] = values

/obj/item/stack/tile/proc/tile_dir_list(list/values, atom/type_cast_path)
	. = GLOB.tile_dir_lists[type]
	if(.)
		return
	for(var/set_dir in values)
		var/image/turf_image = image(icon = initial(type_cast_path.icon), icon_state = initial(type_cast_path.icon_state), dir = text2dir(set_dir))
		turf_image.transform = turf_image.transform.Scale(0.5, 0.5)
		values[set_dir] = turf_image
	return GLOB.tile_dir_lists[type] = values

/obj/item/stack/tile/attack_self(mob/user)
	var/list/radial_options = list()
	if(tile_reskin_types && tile_rotate_dirs)
		radial_options["Reskin"] = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_reskin")
		radial_options["Rotate"] = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_rotate")
		var/radial_result = show_radial_menu(user, src, radial_options, require_near = TRUE, tooltips = TRUE)
		switch(radial_result)
			if("Reskin")
				return tile_reskin(user)
			if("Rotate")
				return tile_rotate(user)
		return
	if(tile_reskin_types)
		return tile_reskin(user)
	if(tile_rotate_dirs)
		return tile_rotate(user)
	return ..()

/obj/item/stack/tile/proc/tile_reskin(mob/user)
	var/obj/item/stack/tile/choice = show_radial_menu(user, src, tile_reskin_types, radius = 48, require_near = TRUE)
	if(!choice || choice == type)
		return
	choice = new choice(user.drop_location(), amount)
	moveToNullspace()
	if(!QDELETED(choice)) // Tile could have merged with stuff on the ground. The user will have to pick it up if so.
		user.put_in_active_hand(choice)
	qdel(src)

/obj/item/stack/tile/proc/tile_rotate(mob/user)
	var/choice = show_radial_menu(user, src, tile_rotate_dirs, radius = 56, require_near = TRUE)
	if(!choice)
		return
	turf_dir = text2dir(choice)
