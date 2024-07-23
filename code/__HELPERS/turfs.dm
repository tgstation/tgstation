///Returns location. Returns null if no location was found.
/proc/get_teleport_loc(turf/location, mob/target, distance = 1, density_check = FALSE, closed_turf_check = FALSE, errorx = 0, errory = 0, eoffsetx = 0, eoffsety = 0)
/*
Location where the teleport begins, target that will teleport, distance to go, density checking 0/1(yes/no), closed turf checking.
Random error in tile placement x, error in tile placement y, and block offset.
Block offset tells the proc how to place the box. Behind teleport location, relative to starting location, forward, etc.
Negative values for offset are accepted, think of it in relation to North, -x is west, -y is south. Error defaults to positive.
Turf and target are separate in case you want to teleport some distance from a turf the target is not standing on or something.
*/

	var/dirx = 0//Generic location finding variable.
	var/diry = 0

	var/xoffset = 0//Generic counter for offset location.
	var/yoffset = 0

	var/b1xerror = 0//Generic placing for point A in box. The lower left.
	var/b1yerror = 0
	var/b2xerror = 0//Generic placing for point B in box. The upper right.
	var/b2yerror = 0

	errorx = abs(errorx)//Error should never be negative.
	errory = abs(errory)

	switch(target.dir)//This can be done through equations but switch is the simpler method. And works fast to boot.
	//Directs on what values need modifying.
		if(1)//North
			diry += distance
			yoffset += eoffsety
			xoffset += eoffsetx
			b1xerror -= errorx
			b1yerror -= errory
			b2xerror += errorx
			b2yerror += errory
		if(2)//South
			diry -= distance
			yoffset -= eoffsety
			xoffset += eoffsetx
			b1xerror -= errorx
			b1yerror -= errory
			b2xerror += errorx
			b2yerror += errory
		if(4)//East
			dirx += distance
			yoffset += eoffsetx//Flipped.
			xoffset += eoffsety
			b1xerror -= errory//Flipped.
			b1yerror -= errorx
			b2xerror += errory
			b2yerror += errorx
		if(8)//West
			dirx -= distance
			yoffset -= eoffsetx//Flipped.
			xoffset += eoffsety
			b1xerror -= errory//Flipped.
			b1yerror -= errorx
			b2xerror += errory
			b2yerror += errorx

	var/turf/destination = locate(location.x+dirx,location.y+diry,location.z)

	if(!destination)//If there isn't a destination.
		return

	if(!errorx && !errory)//If errorx or y were not specified.
		if(density_check && destination.density)
			return
		if(closed_turf_check && isclosedturf(destination))
			return//If closed was specified.
		if(destination.x>world.maxx || destination.x<1)
			return
		if(destination.y>world.maxy || destination.y<1)
			return

	var/destination_list[] = list()//To add turfs to list.
	//destination_list = new()
	/*This will draw a block around the target turf, given what the error is.
	Specifying the values above will basically draw a different sort of block.
	If the values are the same, it will be a square. If they are different, it will be a rectengle.
	In either case, it will center based on offset. Offset is position from center.
	Offset always calculates in relation to direction faced. In other words, depending on the direction of the teleport,
	the offset should remain positioned in relation to destination.*/

	var/turf/center = locate((destination.x + xoffset), (destination.y + yoffset), location.z)//So now, find the new center.

	//Now to find a box from center location and make that our destination.
	var/width = (b2xerror - b1xerror) + 1
	var/height = (b2yerror - b1yerror) + 1
	for(var/turf/current_turf as anything in CORNER_BLOCK_OFFSET(center, width, height, b1xerror, b1yerror))
		if(density_check && current_turf.density)
			continue//If density was specified.
		if(closed_turf_check && isclosedturf(current_turf))
			continue//If closed was specified.
		if(current_turf.x > world.maxx || current_turf.x < 1)
			continue//Don't want them to teleport off the map.
		if(current_turf.y > world.maxy || current_turf.y < 1)
			continue
		destination_list += current_turf

	if(!destination_list.len)
		return

	destination = pick(destination_list)
	return destination

/**
 * Returns the top-most atom sitting on the turf.
 * For example, using this on a disk, which is in a bag, on a mob,
 * will return the mob because it's on the turf.
 *
 * Arguments
 * * something_in_turf - a movable within the turf, somewhere.
 * * stop_type - optional - stops looking if stop_type is found in the turf, returning that type (if found).
 **/
/proc/get_atom_on_turf(atom/movable/something_in_turf, stop_type)
	if(!istype(something_in_turf))
		CRASH("get_atom_on_turf was not passed an /atom/movable! Got [isnull(something_in_turf) ? "null":"type: [something_in_turf.type]"]")

	var/atom/movable/topmost_thing = something_in_turf

	while(topmost_thing?.loc && !isturf(topmost_thing.loc))
		topmost_thing = topmost_thing.loc
		if(stop_type && istype(topmost_thing, stop_type))
			break

	return topmost_thing

///Returns the turf located at the map edge in the specified direction relative to target_atom used for mass driver
/proc/get_edge_target_turf(atom/target_atom, direction)
	var/turf/target = locate(target_atom.x, target_atom.y, target_atom.z)
	if(!target_atom || !target)
		return 0
		//since NORTHEAST == NORTH|EAST, etc, doing it this way allows for diagonal mass drivers in the future
		//and isn't really any more complicated

	var/x = target_atom.x
	var/y = target_atom.y
	if(direction & NORTH)
		y = world.maxy
	else if(direction & SOUTH) //you should not have both NORTH and SOUTH in the provided direction
		y = 1
	if(direction & EAST)
		x = world.maxx
	else if(direction & WEST)
		x = 1
	if(ISDIAGONALDIR(direction)) //let's make sure it's accurately-placed for diagonals
		var/lowest_distance_to_map_edge = min(abs(x - target_atom.x), abs(y - target_atom.y))
		return get_ranged_target_turf(target_atom, direction, lowest_distance_to_map_edge)
	return locate(x,y,target_atom.z)

// returns turf relative to target_atom in given direction at set range
// result is bounded to map size
// note range is non-pythagorean
// used for disposal system
/proc/get_ranged_target_turf(atom/target_atom, direction, range)

	var/x = target_atom.x
	var/y = target_atom.y
	if(direction & NORTH)
		y = min(world.maxy, y + range)
	else if(direction & SOUTH)
		y = max(1, y - range)
	if(direction & EAST)
		x = min(world.maxx, x + range)
	else if(direction & WEST) //if you have both EAST and WEST in the provided direction, then you're gonna have issues
		x = max(1, x - range)

	return locate(x,y,target_atom.z)

/**
 * Get ranged target turf, but with direct targets as opposed to directions
 *
 * Starts at atom starting_atom and gets the exact angle between starting_atom and target
 * Moves from starting_atom with that angle, Range amount of times, until it stops, bound to map size
 * Arguments:
 * * starting_atom - Initial Firer / Position
 * * target - Target to aim towards
 * * range - Distance of returned target turf from starting_atom
 * * offset - Angle offset, 180 input would make the returned target turf be in the opposite direction
 */
/proc/get_ranged_target_turf_direct(atom/starting_atom, atom/target, range, offset)
	var/angle = ATAN2(target.x - starting_atom.x, target.y - starting_atom.y)
	if(offset)
		angle += offset
	var/turf/starting_turf = get_turf(starting_atom)
	for(var/i in 1 to range)
		var/turf/check = locate(starting_atom.x + cos(angle) * i, starting_atom.y + sin(angle) * i, starting_atom.z)
		if(!check)
			break
		starting_turf = check

	return starting_turf


/// returns turf relative to target_atom offset in dx and dy tiles, bound to map limits
/proc/get_offset_target_turf(atom/target_atom, dx, dy)
	var/x = min(world.maxx, max(1, target_atom.x + dx))
	var/y = min(world.maxy, max(1, target_atom.y + dy))
	return locate(x, y, target_atom.z)

/**
 * Lets the turf this atom's *ICON* appears to inhabit
 * it takes into account:
 * Pixel_x/y
 * Matrix x/y
 * NOTE: if your atom has non-standard bounds then this proc
 * will handle it, but:
 * if the bounds are even, then there are an even amount of "middle" turfs, the one to the EAST, NORTH, or BOTH is picked
 * this may seem bad, but you're atleast as close to the center of the atom as possible, better than byond's default loc being all the way off)
 * if the bounds are odd, the true middle turf of the atom is returned
**/
/proc/get_turf_pixel(atom/checked_atom)
	var/turf/atom_turf = get_turf(checked_atom) //use checked_atom's turfs, as its coords are the same as checked_atom's AND checked_atom's coords are lost if it is inside another atom
	if(!atom_turf)
		return null
	if(checked_atom.flags_1 & IGNORE_TURF_PIXEL_OFFSET_1)
		return atom_turf

	var/list/offsets = get_visual_offset(checked_atom)
	return pixel_offset_turf(atom_turf, offsets)

/**
 * Returns how visually "off" the atom is from its source turf as a list of x, y (in pixel steps)
 * it takes into account:
 * Pixel_x/y
 * Matrix x/y
 * Icon width/height
**/
/proc/get_visual_offset(atom/checked_atom)
	//Find checked_atom's matrix so we can use its X/Y pixel shifts
	var/matrix/atom_matrix = matrix(checked_atom.transform)

	var/pixel_x_offset = checked_atom.pixel_x + checked_atom.pixel_w + atom_matrix.get_x_shift()
	var/pixel_y_offset = checked_atom.pixel_y + checked_atom.pixel_z + atom_matrix.get_y_shift()

	//Irregular objects
	var/list/icon_dimensions = get_icon_dimensions(checked_atom.icon)
	var/checked_atom_icon_height = icon_dimensions["height"]
	var/checked_atom_icon_width = icon_dimensions["width"]
	if(checked_atom_icon_height != world.icon_size || checked_atom_icon_width != world.icon_size)
		pixel_x_offset += ((checked_atom_icon_width / world.icon_size) - 1) * (world.icon_size * 0.5)
		pixel_y_offset += ((checked_atom_icon_height / world.icon_size) - 1) * (world.icon_size * 0.5)

	return list(pixel_x_offset, pixel_y_offset)

/**
 * Takes a turf, and a list of x and y pixel offsets and returns the turf that the offset position best lands in
**/
/proc/pixel_offset_turf(turf/offset_from, list/offsets)
	//DY and DX
	var/rough_x = round(round(offsets[1], world.icon_size) / world.icon_size)
	var/rough_y = round(round(offsets[2], world.icon_size) / world.icon_size)

	var/final_x = clamp(offset_from.x + rough_x, 1, world.maxx)
	var/final_y = clamp(offset_from.y + rough_y, 1, world.maxy)

	if(final_x || final_y)
		return locate(final_x, final_y, offset_from.z)
	return offset_from

///Returns a turf based on text inputs, original turf and viewing client
/proc/parse_caught_click_modifiers(list/modifiers, turf/origin, client/viewing_client)
	if(!modifiers)
		return null

	var/screen_loc = splittext(LAZYACCESS(modifiers, SCREEN_LOC), ",")
	var/list/actual_view = getviewsize(viewing_client ? viewing_client.view : world.view)
	var/click_turf_x = splittext(screen_loc[1], ":")
	var/click_turf_y = splittext(screen_loc[2], ":")
	var/click_turf_z = origin.z

	var/click_turf_px = text2num(click_turf_x[2])
	var/click_turf_py = text2num(click_turf_y[2])
	click_turf_x = origin.x + text2num(click_turf_x[1]) - round(actual_view[1] / 2) - 1
	click_turf_y = origin.y + text2num(click_turf_y[1]) - round(actual_view[2] / 2) - 1

	var/turf/click_turf = locate(clamp(click_turf_x, 1, world.maxx), clamp(click_turf_y, 1, world.maxy), click_turf_z)
	LAZYSET(modifiers, ICON_X, "[(click_turf_px - click_turf.pixel_x) + ((click_turf_x - click_turf.x) * world.icon_size)]")
	LAZYSET(modifiers, ICON_Y, "[(click_turf_py - click_turf.pixel_y) + ((click_turf_y - click_turf.y) * world.icon_size)]")
	return click_turf

///Almost identical to the params_to_turf(), but unused (remove?)
/proc/screen_loc_to_turf(text, turf/origin, client/C)
	if(!text)
		return null
	var/tZ = splittext(text, ",")
	var/tX = splittext(tZ[1], "-")
	var/tY = text2num(tX[2])
	tX = splittext(tZ[2], "-")
	tX = text2num(tX[2])
	tZ = origin.z
	var/list/actual_view = getviewsize(C ? C.view : world.view)
	tX = clamp(origin.x + round(actual_view[1] / 2) - tX, 1, world.maxx)
	tY = clamp(origin.y + round(actual_view[2] / 2) - tY, 1, world.maxy)
	return locate(tX, tY, tZ)

///similar function to RANGE_TURFS(), but will search spiralling outwards from the center (like the above, but only turfs)
/proc/spiral_range_turfs(dist = 0, center = usr, orange = FALSE, list/outlist = list(), tick_checked)
	outlist.Cut()
	if(!dist)
		outlist += center
		return outlist

	var/turf/t_center = get_turf(center)
	if(!t_center)
		return outlist

	var/list/turf_list = outlist
	var/turf/checked_turf
	var/y
	var/x
	var/c_dist = 1

	if(!orange)
		turf_list += t_center

	while( c_dist <= dist )
		y = t_center.y + c_dist
		x = t_center.x - c_dist + 1
		for(x in x to t_center.x + c_dist)
			checked_turf = locate(x, y, t_center.z)
			if(checked_turf)
				turf_list += checked_turf

		y = t_center.y + c_dist - 1
		x = t_center.x + c_dist
		for(y in t_center.y - c_dist to y)
			checked_turf = locate(x, y, t_center.z)
			if(checked_turf)
				turf_list += checked_turf

		y = t_center.y - c_dist
		x = t_center.x + c_dist - 1
		for(x in t_center.x - c_dist to x)
			checked_turf = locate(x, y, t_center.z)
			if(checked_turf)
				turf_list += checked_turf

		y = t_center.y - c_dist + 1
		x = t_center.x - c_dist
		for(y in y to t_center.y + c_dist)
			checked_turf = locate(x, y, t_center.z)
			if(checked_turf)
				turf_list += checked_turf
		c_dist++
		if(tick_checked)
			CHECK_TICK

	return turf_list

///Returns a random turf on the station
/proc/get_random_station_turf()
	var/list/turfs = get_area_turfs(pick(GLOB.the_station_areas))
	if (length(turfs))
		return pick(turfs)

///Returns a random turf on the station, excludes dense turfs (like walls) and areas that have valid_territory set to FALSE
/proc/get_safe_random_station_turf(list/areas_to_pick_from = GLOB.the_station_areas)
	for (var/i in 1 to 5)
		var/list/turf_list = get_area_turfs(pick(areas_to_pick_from))
		var/turf/target
		while (turf_list.len && !target)
			var/I = rand(1, turf_list.len)
			var/turf/checked_turf = turf_list[I]
			var/area/turf_area = get_area(checked_turf)
			if(!checked_turf.density && (turf_area.area_flags & VALID_TERRITORY) && !isgroundlessturf(checked_turf))
				var/clear = TRUE
				for(var/obj/checked_object in checked_turf)
					if(checked_object.density)
						clear = FALSE
						break
				if(clear)
					target = checked_turf
			if (!target)
				turf_list.Cut(I, I + 1)
		if (target)
			return target

/**
 * Checks whether the target turf is in a valid state to accept a directional construction
 * such as windows or railings.
 *
 * Returns FALSE if the target turf cannot accept a directional construction.
 * Returns TRUE otherwise.
 *
 * Arguments:
 * * dest_turf - The destination turf to check for existing directional constructions
 * * test_dir - The prospective dir of some atom you'd like to put on this turf.
 * * is_fulltile - Whether the thing you're attempting to move to this turf takes up the entire tile or whether it supports multiple movable atoms on its tile.
 */
/proc/valid_build_direction(turf/dest_turf, test_dir, is_fulltile = FALSE)
	if(!dest_turf)
		return FALSE
	for(var/obj/turf_content in dest_turf)
		if(turf_content.obj_flags & BLOCKS_CONSTRUCTION_DIR)
			if(is_fulltile)  // for making it so fulltile things can't be built over directional things--a special case
				return FALSE
			if(turf_content.dir == test_dir)
				return FALSE
	return TRUE

/**
 * Checks whether or not a particular typepath or subtype of it is present on a turf
 *
 * Returns the first instance located if an instance of the desired type or a subtype of it is found
 * Returns null if the type is not found, or if no turf is supplied
 *
 * Arguments:
 * * location - The turf to be checked for the desired type
 * * type_to_find - The typepath whose presence you are checking for
 */
/proc/is_type_on_turf(turf/location, type_to_find)
	if(!location)
		return
	var/found_type = locate(type_to_find) in location
	return found_type

/**
 * get_blueprint_data
 * Gets a list of turfs around a central turf and gets the blueprint data in a list
 * Args:
 * - central_turf: The center turf we're getting data from.
 * - viewsize: The viewsize we're getting the turfs around central_turf of.
 */
/proc/get_blueprint_data(turf/central_turf, viewsize)
	var/list/blueprint_data_returned = list()
	var/list/dimensions = getviewsize(viewsize)
	var/horizontal_radius = dimensions[1] / 2
	var/vertical_radius = dimensions[2] / 2
	for(var/turf/nearby_turf as anything in RECT_TURFS(horizontal_radius, vertical_radius, central_turf))
		if(nearby_turf.blueprint_data)
			blueprint_data_returned += nearby_turf.blueprint_data
	return blueprint_data_returned
