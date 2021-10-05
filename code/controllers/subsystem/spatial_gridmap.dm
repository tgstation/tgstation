/datum/spatial_grid_cell
	///our x index in the list of cells. this is our index inside of our row list
	var/cell_x
	///our y index in the list of cells. this is the index of our row list inside of our z level grid
	var/cell_y
	///which z level we belong to, corresponding to the index of our gridmap in SSspatial_grid.grids_by_z_level
	var/cell_z
	//every data point in a grid cell is separated by usecase

	///every hearing sensitive movable inside this cell
	var/list/hearing_contents
	///every client possessed mob inside this cell
	var/list/client_contents

/datum/spatial_grid_cell/New(cell_x, cell_y, cell_z)
	. = ..()
	src.cell_x = cell_x
	src.cell_y = cell_y
	src.cell_z = cell_z

/datum/spatial_grid_cell/Destroy(force, ...)
	if(force)//the response to someone trying to qdel this is a right proper fuck you
		return

	. = ..()

/**
 * # Spatial Grid
 * a gamewide grid of spatial_grid_cell datums, each "covering" SPATIAL_GRID_CELLSIZE ^ 2 turfs
 * each spatial_grid_cell datum stores information about what is inside its covered area, so that searches through that area dont have to literally search
 * through all turfs themselves to know what is within it since view() calls are expensive, and so is iterating through stuff you dont want.
 * this allows you to only go through lists of what you want very cheaply
 *
 * you can also register to objects entering and leaving a spatial cell, this allows you to do things like stay idle until a player enters, so you wont
 * have to use expensive view() calls or iteratite over the global list of players and call get_dist() on every one. which is fineish for a few things, but is
 * k * n operations for k objects iterating through n players
 *
 * currently this system is only designed for searching for relatively uncommon things, small subsets of /atom/movable
 * dont add stupid shit to the cells please, keep the information that the cells store to things that need to be searched for often
 *
 * as of right now this system operates on a subset of the important_recursive_contents list for atom/movable, specifically
 * RECURSIVE_CONTENTS_HEARING_SENSITIVE and RECURSIVE_CONTENTS_CLIENT_MOBS because both are those are both 1. important and 2. commonly searched for
 */

SUBSYSTEM_DEF(spatial_grid)
	can_fire = FALSE
	init_order = INIT_ORDER_SPATIAL_GRID
	name = "Spatial Grid"

	///list of the spatial_grid_cell datums per z level, arranged in the order of y index then x index
	var/list/grids_by_z_level = list()
	///everything that spawns before us is added to this list until we initialize
	var/list/waiting_to_add_by_type = list(RECURSIVE_CONTENTS_HEARING_SENSITIVE = list(), RECURSIVE_CONTENTS_CLIENT_MOBS = list())

/datum/controller/subsystem/spatial_grid/Initialize(start_timeofday)
	. = ..()
	var/cells_per_side = world.maxx / SPATIAL_GRID_CELLSIZE //assume world.maxx == world.maxy
	for(var/datum/space_level/z_level as anything in SSmapping.z_list)
		var/list/new_cell_grid = list()

		grids_by_z_level += list(new_cell_grid)

		for(var/y in 1 to cells_per_side)
			new_cell_grid += list(list())
			for(var/x in 1 to cells_per_side)
				var/datum/spatial_grid_cell/cell = new(x, y, z_level.z_value)
				new_cell_grid[y] += cell

	//for anything waiting to be let in
	for(var/channel_type in waiting_to_add_by_type)
		for(var/atom/movable/movable as anything in waiting_to_add_by_type[channel_type])
			var/turf/movable_turf = get_turf(movable)
			if(movable_turf)
				enter_cell(movable, movable_turf)

			UnregisterSignal(movable, COMSIG_PARENT_PREQDELETED)
			waiting_to_add_by_type[channel_type] -= movable

/datum/controller/subsystem/spatial_grid/proc/enter_pre_init_queue(atom/movable/waiting_movable, type)
	RegisterSignal(waiting_movable, COMSIG_PARENT_PREQDELETED, .proc/queued_item_deleted, override = TRUE)
	//override because something can enter the queue for two different types but that is done through unrelated procs that shouldnt know about eachother
	waiting_to_add_by_type[type] += waiting_movable

/datum/controller/subsystem/spatial_grid/proc/remove_from_pre_init_queue(atom/movable/movable_to_remove, exclusive_type)//TODOKYLER: make exclusive_type a list
	if(exclusive_type)
		waiting_to_add_by_type[exclusive_type] -= movable_to_remove

		var/waiting_movable_is_in_other_queues = FALSE//we need to check if this movable is inside the other queues
		for(var/type in waiting_to_add_by_type)
			if(movable_to_remove in waiting_to_add_by_type[type])
				waiting_movable_is_in_other_queues = TRUE

		if(!waiting_movable_is_in_other_queues)
			UnregisterSignal(movable_to_remove, COMSIG_PARENT_PREQDELETED)

		return

	UnregisterSignal(movable_to_remove, COMSIG_PARENT_PREQDELETED)
	for(var/type in waiting_to_add_by_type)
		waiting_to_add_by_type[type] -= movable_to_remove

/datum/controller/subsystem/spatial_grid/proc/queued_item_deleted(atom/movable/movable_being_deleted)
	SIGNAL_HANDLER
	remove_from_pre_init_queue(movable_being_deleted, null)

/**
 * searches through the grid cells intersecting range radius around center and returns the added contents that are also in LOS
 * much faster than iterating through view() to find all of what you want for things that arent that common
 *
 * * center - the atom that is the center of the searched circle
 * * type - the grid contents channel you are looking for, see __DEFINES/spatial_grid.dm
 * * range - the radius of our search circle. the code assumes this is > 1
 * * ignore_visibility - if TRUE, line of sight is ignored, the contents of the grid are only filtered for distance
 * * include_center - if FALSE, subtracts center from the output before filtering, used to speedup searches where you dont care about center being in the output
 */
/datum/controller/subsystem/spatial_grid/proc/find_grid_contents_in_view(atom/center, type, range, ignore_visibility = FALSE, include_center = TRUE)//should probably just be a global proc but w/e
	var/turf/center_turf = get_turf(center)

	var/center_x = center_turf.x
	var/center_y = center_turf.y

	var/list/contents_to_return = list()

	var/static/grid_cells_per_axis = world.maxx / SPATIAL_GRID_CELLSIZE//im going to assume this doesnt change at runtime

	//the minimum x and y cell indexes to test
	var/min_x = max(CEILING((center_x - range) / SPATIAL_GRID_CELLSIZE, 1), 1)
	var/min_y = max(CEILING((center_y - range) / SPATIAL_GRID_CELLSIZE, 1), 1)//calculating these indices only takes around 2 microseconds

	//the maximum x and y cell indexes to test
	var/max_x = min(CEILING((center_x + range) / SPATIAL_GRID_CELLSIZE, 1), grid_cells_per_axis)
	var/max_y = min(CEILING((center_y + range) / SPATIAL_GRID_CELLSIZE, 1), grid_cells_per_axis)

	var/list/grid_level = grids_by_z_level[center_turf.z]
	switch(type)
		if(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS)
			for(var/row in min_y to max_y)
				var/list/grid_row = grid_level[row]

				for(var/x_index in min_x to max_x)
					var/datum/spatial_grid_cell/cell = grid_row[x_index]

					if(cell.client_contents)//this if statement slows down the proc by ~3%, try to find a way to make this unnecessary
						contents_to_return += cell.client_contents

		if(SPATIAL_GRID_CONTENTS_TYPE_HEARING)
			for(var/row in min_y to max_y)
				var/list/grid_row = grid_level[row]

				for(var/x_index in min_x to max_x)
					var/datum/spatial_grid_cell/cell = grid_row[x_index]

					if(cell.hearing_contents)
						contents_to_return += cell.hearing_contents

	//this is faster for things that dont care about themselves but are (probably) in the output, helps us return without using the LOS algorithm
	if(!include_center)
		contents_to_return -= center

	if(!length(contents_to_return))
		return contents_to_return

	if(ignore_visibility)
		for(var/atom/movable/target as anything in contents_to_return)
			var/turf/target_turf = get_turf(target)

			if(get_dist(center_turf, target_turf) > range)
				contents_to_return -= target

		return contents_to_return

	//now that we have the first list of things to return, filter for things with line of sight to x and y
	for(var/atom/movable/target as anything in contents_to_return)
		var/turf/target_turf = get_turf(target)
		var/distance = get_dist(center_turf, target_turf)

		if(distance < 2)//we're adjacent so we can see it :clueless:
			continue

		if(distance > range)
			contents_to_return -= target
			continue

		//this turf search algorithm is the worst scaling part of this proc, scaling worse than view() for small-moderate ranges and > 50 length contents_to_return
		//luckily its significantly faster than view for large ranges in large spaces and/or relatively few contents_to_return
		//i can do things that would scale better, but they would be slower for low volume searches which is the vast majority of the current workload
		//maybe in the future a high volume algorithm would be worth it
		var/turf/inbetween_turf = center_turf
		while(TRUE)
			inbetween_turf = get_step(inbetween_turf, get_dir(inbetween_turf, target_turf))

			if(inbetween_turf == target_turf)//we've gotten to target's turf without returning due to turf opacity, so we must be able to see target
				break

			if(inbetween_turf.opacity || inbetween_turf.opacity_sources)//this turf or something on it is opaque so we cant see through it
				contents_to_return -= target
				break

	return contents_to_return

///get the grid cell encomapassing targets coordinates
/datum/controller/subsystem/spatial_grid/proc/get_cell_of(atom/target)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return

	var/list/grid = grids_by_z_level[target_turf.z]

	var/datum/spatial_grid_cell/cell_to_return = grid[CEILING(target_turf.y / SPATIAL_GRID_CELLSIZE, 1)][CEILING(target_turf.x / SPATIAL_GRID_CELLSIZE, 1)]
	return cell_to_return

///get all grid cells intersecting radius around center and return a list of them
/datum/controller/subsystem/spatial_grid/proc/get_cells_in_range(atom/center, range)
	var/turf/center_turf = get_turf(center)

	var/center_x = center_turf.x
	var/center_y = center_turf.y

	var/list/intersecting_grid_cells = list()

	var/static/grid_cells_per_axis = world.maxx / SPATIAL_GRID_CELLSIZE//im going to assume this doesnt change at runtime

	//the minimum x and y cell indexes to test
	var/min_x = max(CEILING((center_x - range) / SPATIAL_GRID_CELLSIZE, 1), 1)
	var/min_y = max(CEILING((center_y - range) / SPATIAL_GRID_CELLSIZE, 1), 1)//calculating these indices only takes around 2 microseconds

	//the maximum x and y cell indexes to test
	var/max_x = min(CEILING((center_x + range) / SPATIAL_GRID_CELLSIZE, 1), grid_cells_per_axis)
	var/max_y = min(CEILING((center_y + range) / SPATIAL_GRID_CELLSIZE, 1), grid_cells_per_axis)

	var/list/grid_level = grids_by_z_level[center_turf.z]

	for(var/row in min_y to max_y)
		var/list/grid_row = grid_level[row]

		for(var/x_index in min_x to max_x)
			intersecting_grid_cells += grid_row[x_index]

	return intersecting_grid_cells

///find the spatial map cell that target belongs to, then add target's important_recusive_contents to it. make sure to provide the turf new_target is "in"
/datum/controller/subsystem/spatial_grid/proc/enter_cell(atom/movable/new_target, turf/target_turf)
	if(!target_turf || !new_target?.important_recursive_contents)
		CRASH("/datum/controller/subsystem/spatial_grid/proc/enter_cell() was given null arguments or a new_target without important_recursive_contents!")

	var/list/grid = grids_by_z_level[target_turf.z]

	var/datum/spatial_grid_cell/intersecting_cell = grid[CEILING(target_turf.y / SPATIAL_GRID_CELLSIZE, 1)][CEILING(target_turf.x / SPATIAL_GRID_CELLSIZE, 1)]

	SEND_SIGNAL(intersecting_cell, SPATIAL_GRID_CELL_ENTERED, new_target)

	if(new_target.important_recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS])
		LAZYOR(intersecting_cell.client_contents, new_target.important_recursive_contents[SPATIAL_GRID_CONTENTS_TYPE_CLIENTS])

	if(new_target.important_recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE])
		LAZYOR(intersecting_cell.hearing_contents, new_target.important_recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE])

///find the spatial map cell that target used to belong to, then subtract target's important_recusive_contents from it.
///make sure to provide the turf old_target used to be "in"
/datum/controller/subsystem/spatial_grid/proc/exit_cell(atom/movable/old_target, turf/target_turf)
	if(!target_turf || !old_target?.important_recursive_contents)
		CRASH("/datum/controller/subsystem/spatial_grid/proc/exit_cell() was given null arguments or a new_target without important_recursive_contents!")

	var/list/grid = grids_by_z_level[target_turf.z]
	var/datum/spatial_grid_cell/intersecting_cell = grid[CEILING(target_turf.y / SPATIAL_GRID_CELLSIZE, 1)][CEILING(target_turf.x / SPATIAL_GRID_CELLSIZE, 1)]

	SEND_SIGNAL(intersecting_cell, SPATIAL_GRID_CELL_EXITED, old_target)

	if(old_target.important_recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS])
		LAZYREMOVE(intersecting_cell.client_contents, old_target.important_recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS])

	if(old_target.important_recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE])
		LAZYREMOVE(intersecting_cell.hearing_contents, old_target.important_recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE])

///find the cell this movable is associated with and removes it from all lists
/datum/controller/subsystem/spatial_grid/proc/force_remove_from_cell(atom/movable/to_remove, datum/spatial_grid_cell/input_cell)
	if(!input_cell)
		input_cell = get_cell_of(to_remove)
		if(!input_cell)
			find_hanging_cell_refs_for_movable(to_remove, TRUE, TRUE)
			return

	LAZYREMOVE(input_cell.client_contents, to_remove)
	LAZYREMOVE(input_cell.hearing_contents, to_remove)

///if shit goes south, this will find hanging references for qdeleting movables inside
/datum/controller/subsystem/spatial_grid/proc/find_hanging_cell_refs_for_movable(atom/movable/to_remove, should_yield = TRUE, remove_from_cells = TRUE)
	var/list/containing_cells = list()
	for(var/list/z_level_grid as anything in grids_by_z_level)
		for(var/list/cell_row as anything in z_level_grid)
			if(should_yield)
				CHECK_TICK
			for(var/datum/spatial_grid_cell/cell as anything in cell_row)
				if(to_remove in (cell.hearing_contents | cell.client_contents))
					containing_cells += cell
					if(remove_from_cells)
						force_remove_from_cell(to_remove, cell)

	return containing_cells

///debug proc for checking if a movable is in multiple cells when it shouldnt be (ie always)
/atom/proc/find_all_cells_containing(remove_from_cells = FALSE)
	var/datum/spatial_grid_cell/real_cell = SSspatial_grid.get_cell_of(src)
	var/list/containing_cells = SSspatial_grid.find_hanging_cell_refs_for_movable(src, FALSE, remove_from_cells)

	message_admins("[src] is located in the contents of [length(containing_cells)] spatial grid cells")

	var/cell_coords = "the following cells contain [src]: "
	for(var/datum/spatial_grid_cell/cell as anything in containing_cells)
		cell_coords += "([cell.cell_x], [cell.cell_y]), "

	message_admins(cell_coords)
	message_admins("[src] is supposed to only be contained in the cell at indexes ([real_cell.cell_x], [real_cell.cell_y])")
