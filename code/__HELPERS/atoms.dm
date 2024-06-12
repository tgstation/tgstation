///Returns the src and all recursive contents as a list.
/atom/proc/get_all_contents(ignore_flag_1)
	. = list(src)
	var/i = 0
	while(i < length(.))
		var/atom/checked_atom = .[++i]
		if(checked_atom.flags_1 & ignore_flag_1)
			continue
		. += checked_atom.contents

///identical to get_all_contents but returns a list of atoms of the type passed in the argument.
/atom/proc/get_all_contents_type(type)
	var/list/processing_list = list(src)
	. = list()
	while(length(processing_list))
		var/atom/checked_atom = processing_list[1]
		processing_list.Cut(1, 2)
		processing_list += checked_atom.contents
		if(istype(checked_atom, type))
			. += checked_atom

///Like get_all_contents_type, but uses a typecache list as argument
/atom/proc/get_all_contents_ignoring(list/ignore_typecache)
	if(!length(ignore_typecache))
		return get_all_contents()
	var/list/processing = list(src)
	. = list()
	var/i = 0
	while(i < length(processing))
		var/atom/checked_atom = processing[++i]
		if(ignore_typecache[checked_atom.type])
			continue
		processing += checked_atom.contents
		. += checked_atom

///Returns a list of all locations (except the area) the movable is within.
/proc/get_nested_locs(atom/movable/atom_on_location, include_turf = FALSE)
	. = list()
	var/atom/location = atom_on_location.loc
	var/turf/our_turf = get_turf(atom_on_location)
	while(location && location != our_turf)
		. += location
		location = location.loc
	if(our_turf && include_turf) //At this point, only the turf is left, provided it exists.
		. += our_turf

///Step-towards method of determining whether one atom can see another. Similar to viewers()
///note: this is a line of sight algorithm, view() does not do any sort of raycasting and cannot be emulated by it accurately
/proc/can_see(atom/source, atom/target, length=5) // I couldnt be arsed to do actual raycasting :I This is horribly inaccurate.
	var/turf/current = get_turf(source)
	var/turf/target_turf = get_turf(target)
	if(get_dist(source, target) > length)
		return FALSE
	var/steps = 1
	if(current == target_turf)//they are on the same turf, source can see the target
		return TRUE
	current = get_step_towards(current, target_turf)
	while(current != target_turf)
		if(steps > length)
			return FALSE
		if(IS_OPAQUE_TURF(current))
			return FALSE
		current = get_step_towards(current, target_turf)
		steps++
	return TRUE

///Get the cardinal direction between two atoms
/proc/get_cardinal_dir(atom/start, atom/end)
	var/dx = abs(end.x - start.x)
	var/dy = abs(end.y - start.y)
	return get_dir(start, end) & (rand() * (dx+dy) < dy ? 3 : 12)

/**
 * Finds the distance between two atoms, in pixels
 * centered = FALSE counts from turf edge to edge
 * centered = TRUE counts from turf center to turf center
 * of course mathematically this is just adding world.icon_size on again
**/
/proc/get_pixel_distance(atom/start, atom/end, centered = TRUE)
	if(!istype(start) || !istype(end))
		return 0
	. = bounds_dist(start, end) + sqrt((((start.pixel_x + end.pixel_x) ** 2) + ((start.pixel_y + end.pixel_y) ** 2)))
	if(centered)
		. += world.icon_size

/**
 * Check if there is already a wall item on the turf loc
 * floor_loc = floor tile in front of the wall
 * dir_toward_wall = direction from the floor tile in front of the wall towards the wall
 * check_external = truthy if we should be checking against items coming out of the wall, rather than visually on top of the wall.
**/
/proc/check_wall_item(floor_loc, dir_toward_wall, check_external = 0)
	var/wall_loc = get_step(floor_loc, dir_toward_wall)
	for(var/obj/checked_object in floor_loc)
		if(is_type_in_typecache(checked_object, GLOB.WALLITEMS_INTERIOR) && !check_external)
			//Direction works sometimes
			if(checked_object.dir == dir_toward_wall)
				return TRUE

			//Some stuff doesn't use dir properly, so we need to check pixel instead
			//That's exactly what get_turf_pixel() does
			if(get_turf_pixel(checked_object) == wall_loc)
				return TRUE

		if(is_type_in_typecache(checked_object, GLOB.WALLITEMS_EXTERIOR) && check_external)
			if(checked_object.dir == dir_toward_wall)
				return TRUE

	//Some stuff is placed directly on the wallturf (signs).
	//If we're only checking for external entities, we don't need to look though these.
	if (check_external)
		return FALSE
	for(var/obj/checked_object in wall_loc)
		if(is_type_in_typecache(checked_object, GLOB.WALLITEMS_INTERIOR))
			if(checked_object.pixel_x == 0 && checked_object.pixel_y == 0)
				return TRUE
	return FALSE

///Forces the atom to take a step in a random direction
/proc/random_step(atom/movable/moving_atom, steps, chance)
	var/initial_chance = chance
	while(steps > 0)
		if(prob(chance))
			step(moving_atom, pick(GLOB.alldirs))
		chance = max(chance - (initial_chance / steps), 0)
		steps--

/**
 * Compare source's dir, the clockwise dir of source and the anticlockwise dir of source
 * To the opposite dir of the dir returned by get_dir(target,source)
 * If one of them is a match, then source is facing target
**/
/proc/is_source_facing_target(atom/source,atom/target)
	if(!istype(source) || !istype(target))
		return FALSE
	if(isliving(source))
		var/mob/living/source_mob = source
		if(source_mob.body_position == LYING_DOWN)
			return FALSE
	var/goal_dir = get_dir(source, target)
	var/clockwise_source_dir = turn(source.dir, -45)
	var/anticlockwise_source_dir = turn(source.dir, 45)

	if(source.dir == goal_dir || clockwise_source_dir == goal_dir || anticlockwise_source_dir == goal_dir)
		return TRUE
	return FALSE

/*
rough example of the "cone" made by the 3 dirs checked

* \
*  \
*   >
*     <
*      \
*       \
*B --><-- A
*       /
*      /
*     <
*    >
*   /
*  /


*/

///ultra range (no limitations on distance, faster than range for distances > 8); including areas drastically decreases performance
/proc/urange(dist = 0, atom/center = usr, orange = FALSE, areas = FALSE)
	if(!dist)
		if(!orange)
			return list(center)
		else
			return list()

	var/list/turfs = RANGE_TURFS(dist, center)
	if(orange)
		turfs -= get_turf(center)
	. = list()
	for(var/turf/checked_turf as anything in turfs)
		. += checked_turf
		. += checked_turf.contents
		if(areas)
			. |= checked_turf.loc

///similar function to range(), but with no limitations on the distance; will search spiralling outwards from the center
/proc/spiral_range(dist = 0, center = usr, orange = FALSE)
	var/list/atom_list = list()
	var/turf/t_center = get_turf(center)
	if(!t_center)
		return list()

	if(!orange)
		atom_list += t_center
		atom_list += t_center.contents

	if(!dist)
		return atom_list


	var/turf/checked_turf
	var/y
	var/x
	var/c_dist = 1


	while( c_dist <= dist )
		y = t_center.y + c_dist
		x = t_center.x - c_dist + 1
		for(x in x to t_center.x + c_dist)
			checked_turf = locate(x, y, t_center.z)
			if(checked_turf)
				atom_list += checked_turf
				atom_list += checked_turf.contents

		y = t_center.y + c_dist - 1
		x = t_center.x + c_dist
		for(y in t_center.y - c_dist to y)
			checked_turf = locate(x, y, t_center.z)
			if(checked_turf)
				atom_list += checked_turf
				atom_list += checked_turf.contents

		y = t_center.y - c_dist
		x = t_center.x + c_dist - 1
		for(x in t_center.x - c_dist to x)
			checked_turf = locate(x, y, t_center.z)
			if(checked_turf)
				atom_list += checked_turf
				atom_list += checked_turf.contents

		y = t_center.y - c_dist + 1
		x = t_center.x - c_dist
		for(y in y to t_center.y + c_dist)
			checked_turf = locate(x, y, t_center.z)
			if(checked_turf)
				atom_list += checked_turf
				atom_list += checked_turf.contents
		c_dist++

	return atom_list

///Returns the closest atom of a specific type in a list from a source
/proc/get_closest_atom(type, list/atom_list, source)
	var/closest_atom
	var/closest_distance
	for(var/atom in atom_list)
		if(!istype(atom, type))
			continue
		var/distance = get_dist(source, atom)
		if(!closest_atom)
			closest_distance = distance
			closest_atom = atom
		else
			if(closest_distance > distance)
				closest_distance = distance
				closest_atom = atom
	return closest_atom

///Returns a chosen path that is the closest to a list of matches
/proc/pick_closest_path(value, list/matches = get_fancy_list_of_atom_types())
	if (value == FALSE) //nothing should be calling us with a number, so this is safe
		value = input("Enter type to find (blank for all, cancel to cancel)", "Search for type") as null|text
		if (isnull(value))
			return
	value = trim(value)

	var/random = FALSE
	if(findtext(value, "?"))
		value = replacetext(value, "?", "")
		random = TRUE

	if(!isnull(value) && value != "")
		matches = filter_fancy_list(matches, value)

	if(matches.len == 0)
		return

	var/chosen
	if(matches.len == 1)
		chosen = matches[1]
	else if(random)
		chosen = pick(matches) || null
	else
		chosen = input("Select a type", "Pick Type", matches[1]) as null|anything in sort_list(matches)
	if(!chosen)
		return
	chosen = matches[chosen]
	return chosen

///Creates new items inside an atom based on a list
/proc/generate_items_inside(list/items_list, where_to)
	for(var/each_item in items_list)
		for(var/i in 1 to items_list[each_item])
			new each_item(where_to)

///Returns the atom type in the specified loc
/proc/get(atom/loc, type)
	while(loc)
		if(istype(loc, type))
			return loc
		loc = loc.loc
	return null

///Returns true if the src countain the atom target
/atom/proc/contains(atom/target)
	if(!target)
		return FALSE
	for(var/atom/location = target.loc, location, location = location.loc)
		if(location == src)
			return TRUE

///A do nothing proc
/proc/pass(...)
	return

/// Returns an x and y value require to reverse the transformations made to center an oversized icon
/atom/proc/get_oversized_icon_offsets()
	if (pixel_x == 0 && pixel_y == 0)
		return list("x" = 0, "y" = 0)
	var/list/icon_dimensions = get_icon_dimensions(icon)
	var/icon_width = icon_dimensions["width"]
	var/icon_height = icon_dimensions["height"]
	return list(
		"x" = icon_width > world.icon_size && pixel_x != 0 ? (icon_width - world.icon_size) * 0.5 : 0,
		"y" = icon_height > world.icon_size && pixel_y != 0 ? (icon_height - world.icon_size) * 0.5 : 0,
	)

/**
 * Called before an item is put into this atom's storage datum via the item clicking on this atom
 *
 * This can be used to add item-atom interactions that you want handled before inserting something into storage
 * (But it's also fairly snowflakey)
 *
 * Returning FALSE will block that item from being put into our storage
 */
/atom/proc/storage_insert_on_interacted_with(datum/storage, obj/item/inserted, mob/living/user)
	return TRUE
