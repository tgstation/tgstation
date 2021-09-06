SUBSYSTEM_DEF(spatial_hashmap)
	can_fire = FALSE
	init_order = INIT_ORDER_HASHMAP
	name = "Spatial Hashmap"

	var/list/hashmaps_by_z_level = list()

/datum/controller/subsystem/spatial_hashmap/Initialize(start_timeofday)
	. = ..()
	for(var/datum/space_level/z_level as anything in SSmapping.z_list)
		hashmaps_by_z_level += new/datum/z_level_hashmap(z_level.z_value)

/*
/datum/controller/subsystem/spatial_hashmap/proc/add_to_cell(atom/target, contents_type)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		CRASH("no usable turf loc of [target]!")

	var/datum/z_level_hashmap/used_hashmap_level = hashmaps_by_z_level[target_turf.z]

	if(contents_type & HASHMAP_CONTENTS_TYPE_HEARING)

///returns FALSE if the two atom arguments dont share the same hashmap cell, and TRUE if they do
/datum/controller/subsystem/spatial_hashmap/proc/compare_hashmap_cells(atom/first_atom, atom/second_atom)
	var/turf/first_turf = get_turf(first_atom)
	var/turf/second_turf = get_turf(second_atom)
	if(!first_turf || !second_turf)
		return FALSE

	if(first_turf.z != second_turf.z)
		return FALSE

	var/datum/z_level_hashmap/hashmap_level = hashmaps_by_z_level[first_turf.z]
*/

/datum/controller/subsystem/spatial_hashmap/proc/find_contents_in_range(type, atom/center, range)
	var/turf/center_turf = get_turf(center)
	if(!center_turf)
		return
	var/datum/z_level_hashmap/hashmap = hashmaps_by_z_level[center_turf.z]
	if(hashmap)
		return hashmap.find_contents_in_range(type, center, range)

/datum/controller/subsystem/spatial_hashmap/proc/get_cell_of(atom/target)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		CRASH("no usable turf loc of [target]!")

	var/datum/z_level_hashmap/hashmap = hashmaps_by_z_level[target_turf.z]
	if(!hashmap)
		CRASH("no z level hashmap for [target_turf] as the turf of [target]!")

	var/datum/spatial_hashmap_cell/cell_to_return = hashmap.cells["[CEILING(target_turf.x / HASHMAP_CELLSIZE, 1)],[CEILING(target_turf.y / HASHMAP_CELLSIZE, 1)]"]
	return cell_to_return

/datum/z_level_hashmap
	///associative list of all /datum/spatial_hashmap_cell's for this z level, of the form: list("[x][y] = cell at those coordinates")
	var/list/cells = list()

	var/z_level

/datum/z_level_hashmap/New(z_level)
	. = ..()
	src.z_level = z_level
	var/cells_per_side = world.maxx / HASHMAP_CELLSIZE //assume world.maxx == world.maxy
	//var/starting_offset = CEILING(HASHMAP_CELLSIZE/2, 1)
	for(var/x in 1 to cells_per_side)
		for(var/y in 1 to cells_per_side)
			//var/cell_x = 1 + x * HASHMAP_CELLSIZE //this generates the COORDINATES of a cell
			//var/cell_y = 1 + y * HASHMAP_CELLSIZE //note that this isnt used
			cells["[x],[y]"] = new/datum/spatial_hashmap_cell(x, y) //1,1 | 1,2 | 1,3 | 1,4 | 1,5 | 1,6 | 1,7 ...

/datum/z_level_hashmap/proc/get_cell_by_coordinates(atom/point)
	var/turf/point_turf = get_turf(point)
	var/cell_x = CEILING(point_turf.x / HASHMAP_CELLSIZE, 1) //251 / 5 = 50.2 ceil(50.2) = 51
	var/cell_y = CEILING(point_turf.y / HASHMAP_CELLSIZE, 1) //1 / 5 = 0.2 ceil(0.2) = 1

	return cells["[cell_x],[cell_y]"]

/**
 * finds all hashmap cells in range of the specified coordinates
 * then outputs all of the specified contents type of the cells that are in range that arent blocked by walls
 */
/datum/z_level_hashmap/proc/find_contents_in_range(type, atom/center, range)
	if(range < 0) //dont use us for single turf looping just look through the turf yourself TODOKYLER: actually enforce this
		CRASH("/datum/z_level_hashmap/proc/find_contents_in_range() was given a range less than or equal to 0! range: [range]")

	var/turf/center_turf = get_turf(center)
	if(!center_turf)
		CRASH("no turf for the center argument given to find_contents_in_range()!")

	var/x = center_turf.x//rename to center_x and center_y
	var/y = center_turf.y

	//var/list/intersecting_cells = list()
	var/list/contents_to_return = list()

	//the minimum x and y cell indexes to test
	var/min_x = max(CEILING((x - range) / HASHMAP_CELLSIZE, 1), 1)
	var/min_y = max(CEILING((y - range) / HASHMAP_CELLSIZE, 1), 1)

	//the maximum x and y cell indexes to test
	var/max_x = min(CEILING((x + range) / HASHMAP_CELLSIZE, 1), world.maxx / HASHMAP_CELLSIZE)
	var/max_y = min(CEILING((y + range) / HASHMAP_CELLSIZE, 1), world.maxx / HASHMAP_CELLSIZE)

	for(var/y_cell_index in min_y to max_y)
		for(var/x_cell_index in min_x to max_x)
			var/datum/spatial_hashmap_cell/cell = cells["[x_cell_index],[y_cell_index]"]
			if(!cell)
				stack_trace("there is no hashmap cell at index [x_cell_index],[y_cell_index] for z level [z_level]!")
				continue
			switch(type)//this is dumb but whatever, this is why cells shouldnt exist and should just be nested associative list in the cells list
				if(HASHMAP_CONTENTS_TYPE_HEARING)
					if(length(cell.hearing_contents))
						contents_to_return += cell.hearing_contents
				if(HASHMAP_CONTENTS_TYPE_CLIENTS)
					if(length(cell.client_contents))
						contents_to_return += cell.client_contents

	var/has_contents_in_range = FALSE
	//now that we have the first list of things to return, filter for things with line of sight to x and y
	for(var/atom/movable/movable_to_check as anything in contents_to_return)
		if(get_dist(center_turf, get_turf(movable_to_check)) <= range)
			has_contents_in_range = TRUE
			break

	if(!has_contents_in_range)
		return

	var/old_lum = center_turf.luminosity
	center_turf.luminosity = 6
	contents_to_return &= view(range, center_turf)
	center_turf.luminosity = old_lum
	return contents_to_return

/datum/spatial_hashmap_cell
	///our x index in the list of cells
	var/cell_x
	///our y index in the list of cells
	var/cell_y

	//every data point in a hashmap cell is separated by usecase TODOKYLER: maybe make this not lazy?

	///every hearing sensitive movable inside this cell
	var/list/hearing_contents
	///every client possessed movable inside this cell
	var/list/client_contents

/datum/spatial_hashmap_cell/New(cell_x, cell_y)
	. = ..()
	src.cell_x = cell_x
	src.cell_y = cell_y

//
/turf/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!LAZYLEN(arrived.important_recursive_contents) || !(arrived.important_recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS] || arrived.important_recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE]))
		return
	//this is turf/Entered so we know both arrived and us have nonzero coords but we dont know if old_loc does
	if(old_loc?.z == z && CEILING(old_loc.x / HASHMAP_CELLSIZE, 1) == CEILING(x / HASHMAP_CELLSIZE, 1) && CEILING(old_loc.y / HASHMAP_CELLSIZE, 1) == CEILING(y / HASHMAP_CELLSIZE, 1))
		return //both the old location and the new one are in the same hashmap cell

	var/datum/spatial_hashmap_cell/our_cell = SSspatial_hashmap.get_cell_of(src)
	if(!our_cell)
		return

	if(LAZYACCESS(arrived.important_recursive_contents, RECURSIVE_CONTENTS_CLIENT_MOBS))
		LAZYADD(our_cell.client_contents, arrived.important_recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS])

	if(LAZYACCESS(arrived.important_recursive_contents, RECURSIVE_CONTENTS_HEARING_SENSITIVE))
		LAZYADD(our_cell.hearing_contents, arrived.important_recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE])
