///the subsystem creates this many [/mob/oranges_ear] mob instances during init. allocations that require more than this create more.
#define NUMBER_OF_PREGENERATED_ORANGES_EARS 2500

/**
 * # Spatial Grid Cell
 *
 * used by [/datum/controller/subsystem/spatial_grid] to cover every z level so that the coordinates of every turf in the world corresponds to one of these in
 * the subsystems list of grid cells by z level. each one of these contains content lists holding all atoms meeting a certain criteria that is in our borders.
 * these datums shouldnt have significant behavior, they should just hold data. the lists are filled and emptied by the subsystem.
 */
/datum/spatial_grid_cell
	///our x index in the list of cells. this is our index inside of our row list
	var/cell_x
	///our y index in the list of cells. this is the index of our row list inside of our z level grid
	var/cell_y
	///which z level we belong to, corresponding to the index of our gridmap in SSspatial_grid.grids_by_z_level
	var/cell_z
	//every data point in a grid cell is separated by usecase

	//when empty, the contents lists of these grid cell datums are just references to a dummy list from SSspatial_grid
	//this is meant to allow a great compromise between memory usage and speed.
	//now orthogonal_range_search() doesnt need to check if the list is null and each empty list is taking 12 bytes instead of 24
	//the only downside is that it needs to be switched over to a new list when it goes from 0 contents to > 0 contents and switched back on the opposite case

	///every hearing sensitive movable inside this cell
	var/list/hearing_contents
	///every client possessed mob inside this cell
	var/list/client_contents
	///every atmos machine inside this cell
	var/list/atmos_contents

/datum/spatial_grid_cell/New(cell_x, cell_y, cell_z)
	. = ..()
	src.cell_x = cell_x
	src.cell_y = cell_y
	src.cell_z = cell_z
	//cache for sanic speed (lists are references anyways)
	var/list/dummy_list = SSspatial_grid.dummy_list

	if(length(dummy_list))
		dummy_list.Cut()
		stack_trace("SSspatial_grid.dummy_list had something inserted into it at some point! this is a problem as it is supposed to stay empty")
	hearing_contents = dummy_list
	client_contents = dummy_list
	atmos_contents = dummy_list

/datum/spatial_grid_cell/Destroy(force)
	if(force)//the response to someone trying to qdel this is a right proper fuck you
		stack_trace("dont try to destroy spatial grid cells without a good reason. if you need to do it use force")
		return

	. = ..()

/**
 * # Spatial Grid
 *
 * a gamewide grid of spatial_grid_cell datums, each "covering" [SPATIAL_GRID_CELLSIZE] ^ 2 turfs.
 * each spatial_grid_cell datum stores information about what is inside its covered area, so that searches through that area dont have to literally search
 * through all turfs themselves to know what is within it since view() calls are expensive, and so is iterating through stuff you dont want.
 * this allows you to only go through lists of what you want very cheaply.
 *
 * you can also register to objects entering and leaving a spatial cell, this allows you to do things like stay idle until a player enters, so you wont
 * have to use expensive view() calls or iteratite over the global list of players and call get_dist() on every one. which is fineish for a few things, but is
 * k * n operations for k objects iterating through n players.
 *
 * currently this system is only designed for searching for relatively uncommon things, small subsets of /atom/movable.
 * dont add stupid shit to the cells please, keep the information that the cells store to things that need to be searched for often
 *
 * The system currently implements two different "classes" of spatial type
 *
 * The first exists to support important_recursive_contents.
 * So if a client is inside a locker and the locker crosses a boundary, you'll still get a signal from the spatial grid.
 * These types are [SPATIAL_GRID_CONTENTS_TYPE_HEARING] and [SPATIAL_GRID_CONTENTS_TYPE_CLIENTS]
 *
 * The second pattern is more paired down, and supports more wide use.
 * Rather then the object and anything the object is in being sensitive, it's limited to just the object itself
 * Currently only [SPATIAL_GRID_CONTENTS_TYPE_ATMOS] uses this pattern. This is because it's far more common, and so worth optimizing
 *
 */
SUBSYSTEM_DEF(spatial_grid)
	can_fire = FALSE
	init_order = INIT_ORDER_SPATIAL_GRID
	name = "Spatial Grid"

	///list of the spatial_grid_cell datums per z level, arranged in the order of y index then x index
	var/list/grids_by_z_level = list()
	///everything that spawns before us is added to this list until we initialize
	var/list/waiting_to_add_by_type = list(SPATIAL_GRID_CONTENTS_TYPE_HEARING = list(), SPATIAL_GRID_CONTENTS_TYPE_CLIENTS = list(), SPATIAL_GRID_CONTENTS_TYPE_ATMOS = list())
	///associative list of the form: movable.spatial_grid_key (string) -> inner list of spatial grid types for that key.
	///inner lists contain contents channel types such as SPATIAL_GRID_CONTENTS_TYPE_HEARING etc.
	///we use this to make adding to a cell static cost, and to save on memory
	var/list/spatial_grid_categories = list()

	var/cells_on_x_axis = 0
	var/cells_on_y_axis = 0

	///empty spatial grid cell content lists are just a reference to this instead of a standalone list to save memory without needed to check if its null when iterating
	var/list/dummy_list = list()

	///list of all of /mob/oranges_ear instances we have pregenerated for view() iteration speedup
	var/list/mob/oranges_ear/pregenerated_oranges_ears = list()
	///how many pregenerated /mob/oranges_ear instances currently exist. this should hopefully never exceed its starting value
	var/number_of_oranges_ears = NUMBER_OF_PREGENERATED_ORANGES_EARS

/datum/controller/subsystem/spatial_grid/Initialize()
	cells_on_x_axis = SPATIAL_GRID_CELLS_PER_SIDE(world.maxx)
	cells_on_y_axis = SPATIAL_GRID_CELLS_PER_SIDE(world.maxy)

	// enter_cell only runs if 'initialized'
	initialized = TRUE

	for(var/datum/space_level/z_level as anything in SSmapping.z_list)
		propogate_spatial_grid_to_new_z(null, z_level)
		CHECK_TICK

	//go through the pre init queue for anything waiting to be let in the grid
	for(var/channel_type in waiting_to_add_by_type)
		for(var/atom/movable/movable as anything in waiting_to_add_by_type[channel_type])
			var/turf/movable_turf = get_turf(movable)
			if(movable_turf)
				enter_cell(movable, movable_turf)

			UnregisterSignal(movable, COMSIG_QDELETING)
			waiting_to_add_by_type[channel_type] -= movable

	pregenerate_more_oranges_ears(NUMBER_OF_PREGENERATED_ORANGES_EARS)

	RegisterSignal(SSdcs, COMSIG_GLOB_NEW_Z, PROC_REF(propogate_spatial_grid_to_new_z))
	RegisterSignal(SSdcs, COMSIG_GLOB_EXPANDED_WORLD_BOUNDS, PROC_REF(after_world_bounds_expanded))
	return SS_INIT_SUCCESS

///add a movable to the pre init queue for whichever type is specified so that when the subsystem initializes they get added to the grid
/datum/controller/subsystem/spatial_grid/proc/enter_pre_init_queue(atom/movable/waiting_movable, type)
	RegisterSignal(waiting_movable, COMSIG_QDELETING, PROC_REF(queued_item_deleted), override = TRUE)
	//override because something can enter the queue for two different types but that is done through unrelated procs that shouldnt know about eachother
	waiting_to_add_by_type[type] += waiting_movable

///removes an initialized and probably deleted movable from our pre init queue before we're initialized
/datum/controller/subsystem/spatial_grid/proc/remove_from_pre_init_queue(atom/movable/movable_to_remove, exclusive_type)
	if(exclusive_type)
		waiting_to_add_by_type[exclusive_type] -= movable_to_remove

		var/waiting_movable_is_in_other_queues = FALSE//we need to check if this movable is inside the other queues
		for(var/type in waiting_to_add_by_type)
			if(movable_to_remove in waiting_to_add_by_type[type])
				waiting_movable_is_in_other_queues = TRUE

		if(!waiting_movable_is_in_other_queues)
			UnregisterSignal(movable_to_remove, COMSIG_QDELETING)

		return

	UnregisterSignal(movable_to_remove, COMSIG_QDELETING)
	for(var/type in waiting_to_add_by_type)
		waiting_to_add_by_type[type] -= movable_to_remove

///if a movable is inside our pre init queue before we're initialized and it gets deleted we need to remove that reference with this proc
/datum/controller/subsystem/spatial_grid/proc/queued_item_deleted(atom/movable/movable_being_deleted)
	SIGNAL_HANDLER
	remove_from_pre_init_queue(movable_being_deleted, null)

///creates the spatial grid for a new z level
/datum/controller/subsystem/spatial_grid/proc/propogate_spatial_grid_to_new_z(datum/controller/subsystem/processing/dcs/fucking_dcs, datum/space_level/z_level)
	SIGNAL_HANDLER

	var/list/new_cell_grid = list()

	grids_by_z_level += list(new_cell_grid)

	for(var/y in 1 to cells_on_y_axis)
		new_cell_grid += list(list())
		for(var/x in 1 to cells_on_x_axis)
			var/datum/spatial_grid_cell/cell = new(x, y, z_level.z_value)
			new_cell_grid[y] += cell

///adds cells to the grid for every z level when world.maxx or world.maxy is expanded after this subsystem is initialized. hopefully this is never needed.
///because i never tested this.
/datum/controller/subsystem/spatial_grid/proc/after_world_bounds_expanded(datum/controller/subsystem/processing/dcs/fucking_dcs, has_expanded_world_maxx, has_expanded_world_maxy)
	SIGNAL_HANDLER
	var/old_x_axis = cells_on_x_axis
	var/old_y_axis = cells_on_y_axis

	cells_on_x_axis = SPATIAL_GRID_CELLS_PER_SIDE(world.maxx)
	cells_on_y_axis = SPATIAL_GRID_CELLS_PER_SIDE(world.maxy)

	for(var/z_level in 1 to length(grids_by_z_level))
		var/list/z_level_gridmap = grids_by_z_level[z_level]

		for(var/cell_row_for_expanded_y_axis in 1 to cells_on_y_axis)

			if(cell_row_for_expanded_y_axis > old_y_axis)//we are past the old length of the number of rows, so add to the list
				z_level_gridmap += list(list())

			//now we know theres a row at this position, so add cells to it that need to be added and update the ones that already exist
			var/list/cell_row = z_level_gridmap[cell_row_for_expanded_y_axis]

			for(var/grid_cell_for_expanded_x_axis in 1 to cells_on_x_axis)

				if(grid_cell_for_expanded_x_axis > old_x_axis)
					var/datum/spatial_grid_cell/new_cell_inserted = new(grid_cell_for_expanded_x_axis, cell_row_for_expanded_y_axis, z_level)
					cell_row += new_cell_inserted
					continue

				//now we know the cell index we're at contains an already existing cell that needs its x and y values updated
				var/datum/spatial_grid_cell/old_cell_that_needs_updating = cell_row[grid_cell_for_expanded_x_axis]
				old_cell_that_needs_updating.cell_x = grid_cell_for_expanded_x_axis
				old_cell_that_needs_updating.cell_y = cell_row_for_expanded_y_axis

///the left or bottom side index of a box composed of spatial grid cells with the given actual center x or y coordinate
#define BOUNDING_BOX_MIN(center_coord) max(GET_SPATIAL_INDEX(center_coord - range), 1)
///the right or upper side index of a box composed of spatial grid cells with the given center x or y coordinate.
///outputted value cant exceed the number of cells on that axis
#define BOUNDING_BOX_MAX(center_coord, axis_size) min(GET_SPATIAL_INDEX(center_coord + range), axis_size)

/**
 * https://en.wikipedia.org/wiki/Range_searching#Orthogonal_range_searching
 *
 * searches through the grid cells intersecting a rectangular search space (with sides of length 2 * range) then returns all contents of type inside them.
 * much faster than iterating through view() to find all of what you want.
 *
 * this does NOT return things only in range distance from center! the search space is a square not a circle, if you want only things in a certain distance
 * then you need to filter that yourself
 *
 * * center - the atom that is the center of the searched circle
 * * type - the type of grid contents you are looking for, see __DEFINES/spatial_grid.dm
 * * range - the bigger this is, the more spatial grid cells the search space intersects
 */
/datum/controller/subsystem/spatial_grid/proc/orthogonal_range_search(atom/center, type, range)
	var/turf/center_turf = get_turf(center)

	var/center_x = center_turf.x//used inside the macros
	var/center_y = center_turf.y

	. = list()

	//technically THIS list only contains lists, but inside those lists are grid cell datums and we can go without a SINGLE var init if we do this
	var/list/list/datum/spatial_grid_cell/grid_level = grids_by_z_level[center_turf.z]

	switch(type)
		if(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS)
			for(var/row in BOUNDING_BOX_MIN(center_y) to BOUNDING_BOX_MAX(center_y, cells_on_y_axis))
				for(var/x_index in BOUNDING_BOX_MIN(center_x) to BOUNDING_BOX_MAX(center_x, cells_on_x_axis))

					. += grid_level[row][x_index].client_contents

		if(SPATIAL_GRID_CONTENTS_TYPE_HEARING)
			for(var/row in BOUNDING_BOX_MIN(center_y) to BOUNDING_BOX_MAX(center_y, cells_on_y_axis))
				for(var/x_index in BOUNDING_BOX_MIN(center_x) to BOUNDING_BOX_MAX(center_x, cells_on_x_axis))

					. += grid_level[row][x_index].hearing_contents

		if(SPATIAL_GRID_CONTENTS_TYPE_ATMOS)
			for(var/row in BOUNDING_BOX_MIN(center_y) to BOUNDING_BOX_MAX(center_y, cells_on_y_axis))
				for(var/x_index in BOUNDING_BOX_MIN(center_x) to BOUNDING_BOX_MAX(center_x, cells_on_x_axis))
					. += grid_level[row][x_index].atmos_contents

	return .

///get the grid cell encomapassing targets coordinates
/datum/controller/subsystem/spatial_grid/proc/get_cell_of(atom/target)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return

	return grids_by_z_level[target_turf.z][GET_SPATIAL_INDEX(target_turf.y)][GET_SPATIAL_INDEX(target_turf.x)]

///get all grid cells intersecting the bounding box around center with sides of length 2 * range
/datum/controller/subsystem/spatial_grid/proc/get_cells_in_range(atom/center, range)
	return get_cells_in_bounds(center, range, range)

///get all grid cells intersecting the bounding box around center with sides of length (2 * range_x, 2 * range_y)
/datum/controller/subsystem/spatial_grid/proc/get_cells_in_bounds(atom/center, range_x, range_y)
	var/turf/center_turf = get_turf(center)

	var/center_x = center_turf.x
	var/center_y = center_turf.y

	var/list/intersecting_grid_cells = list()

	//the minimum x and y cell indexes to test
	var/min_x = max(GET_SPATIAL_INDEX(center_x - range_x), 1)
	var/min_y = max(GET_SPATIAL_INDEX(center_y - range_y), 1)//calculating these indices only takes around 2 microseconds

	//the maximum x and y cell indexes to test
	var/max_x = min(GET_SPATIAL_INDEX(center_x + range_x), cells_on_x_axis)
	var/max_y = min(GET_SPATIAL_INDEX(center_y + range_y), cells_on_y_axis)

	var/list/grid_level = grids_by_z_level[center_turf.z]

	for(var/row in min_y to max_y)
		var/list/grid_row = grid_level[row]

		for(var/x_index in min_x to max_x)
			intersecting_grid_cells += grid_row[x_index]

	return intersecting_grid_cells

/// Adds grid awareness to the passed in atom, of the passed in type
/// Basically, when this atom moves between grids, it wants to have enter/exit cell called on it
/datum/controller/subsystem/spatial_grid/proc/add_grid_awareness(atom/movable/add_to, type)
	// We need to ensure we have a new list reference, to build our new key out of
	var/list/current_list = spatial_grid_categories[add_to.spatial_grid_key]
	if(current_list)
		current_list = current_list.Copy()
	else
		current_list = list()
	// Now we do a binary insert, to ensure it's sorted (don't wanna overcache)
	BINARY_INSERT_DEFINE(type, current_list, SORT_VAR_NO_TYPE, type, SORT_COMPARE_DIRECTLY, COMPARE_KEY)
	update_grid_awareness(add_to, current_list)

/// Removes grid awareness from the passed in atom, of the passed in type
/datum/controller/subsystem/spatial_grid/proc/remove_grid_awareness(atom/movable/remove_from, type)
	// We need to ensure we have a new list reference, to build our new key out of
	var/list/current_list = spatial_grid_categories[remove_from.spatial_grid_key]
	if(current_list)
		current_list = current_list.Copy()
	else
		current_list = list()
	current_list -= type
	update_grid_awareness(remove_from, current_list)

/// Alerts the atom's current cell that it wishes to be treated as a member
/// This functionally amounts to "hey, I was recently made aware by [add_grid_awareness], please insert me into my current cell"
/datum/controller/subsystem/spatial_grid/proc/add_grid_membership(atom/movable/add_to, turf/target_turf, type)
	if(!target_turf)
		return
	if(initialized)
		add_single_type(add_to, target_turf, type)
	else //SSspatial_grid isnt init'd yet, add ourselves to the queue
		enter_pre_init_queue(add_to, type)

/// Removes grid membership from the passed in atom, of the passed in type
/datum/controller/subsystem/spatial_grid/proc/remove_grid_membership(atom/movable/remove_from, turf/target_turf, type)
	if(!target_turf)
		return
	if(initialized)
		remove_single_type(remove_from, target_turf, type)
	else //SSspatial_grid isnt init'd yet, remove ourselves from the queue
		remove_from_pre_init_queue(remove_from, type)

/// Updates the string that atoms hold that stores their grid awareness
/// We will use it to key into their spatial grid categories later
/datum/controller/subsystem/spatial_grid/proc/update_grid_awareness(atom/movable/update, list/new_list)
	// We locally store a stringified version of the list, to prevent people trying to mutate it
	update.spatial_grid_key = new_list.Join("-")
	// Ensure the global representation is cached
	if(!spatial_grid_categories[update.spatial_grid_key])
		spatial_grid_categories[update.spatial_grid_key] = new_list

///find the spatial map cell that target belongs to, then add the target to it, as its type prefers.
///make sure to provide the turf new_target is "in"
/datum/controller/subsystem/spatial_grid/proc/enter_cell(atom/movable/new_target, turf/target_turf)
	if(!initialized)
		return
	if(QDELETED(new_target))
		CRASH("qdeleted or null target trying to enter the spatial grid!")

	if(!target_turf || !new_target.spatial_grid_key)
		CRASH("null turf loc or a new_target that doesn't support it trying to enter the spatial grid!")

	var/x_index = GET_SPATIAL_INDEX(target_turf.x)
	var/y_index = GET_SPATIAL_INDEX(target_turf.y)
	var/z_index = target_turf.z

	var/datum/spatial_grid_cell/intersecting_cell = grids_by_z_level[z_index][y_index][x_index]
	for(var/type in spatial_grid_categories[new_target.spatial_grid_key])
		switch(type)
			if(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS)
				var/list/new_target_contents = new_target.important_recursive_contents //cache for sanic speeds (lists are references anyways)
				GRID_CELL_SET(intersecting_cell.client_contents, new_target_contents[SPATIAL_GRID_CONTENTS_TYPE_CLIENTS])
				SEND_SIGNAL(intersecting_cell, SPATIAL_GRID_CELL_ENTERED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS), new_target_contents[SPATIAL_GRID_CONTENTS_TYPE_CLIENTS])

			if(SPATIAL_GRID_CONTENTS_TYPE_HEARING)
				var/list/new_target_contents = new_target.important_recursive_contents
				GRID_CELL_SET(intersecting_cell.hearing_contents, new_target.important_recursive_contents[SPATIAL_GRID_CONTENTS_TYPE_HEARING])
				SEND_SIGNAL(intersecting_cell, SPATIAL_GRID_CELL_ENTERED(SPATIAL_GRID_CONTENTS_TYPE_HEARING), new_target_contents[SPATIAL_GRID_CONTENTS_TYPE_HEARING])

			if(SPATIAL_GRID_CONTENTS_TYPE_ATMOS)
				GRID_CELL_SET(intersecting_cell.atmos_contents, new_target)
				SEND_SIGNAL(intersecting_cell, SPATIAL_GRID_CELL_ENTERED(SPATIAL_GRID_CONTENTS_TYPE_ATMOS), new_target)

///acts like enter_cell() but only adds the target to a specified type of grid cell contents list
/datum/controller/subsystem/spatial_grid/proc/add_single_type(atom/movable/new_target, turf/target_turf, exclusive_type)
	if(!initialized)
		return
	if(QDELETED(new_target))
		CRASH("qdeleted or null target trying to enter the spatial grid!")

	if(!target_turf || !(exclusive_type in spatial_grid_categories[new_target.spatial_grid_key]))
		CRASH("null turf loc or a new_target that doesn't support it trying to enter the spatial grid as a [exclusive_type]!")

	var/x_index = GET_SPATIAL_INDEX(target_turf.x)
	var/y_index = GET_SPATIAL_INDEX(target_turf.y)
	var/z_index = target_turf.z

	var/datum/spatial_grid_cell/intersecting_cell = grids_by_z_level[z_index][y_index][x_index]
	switch(exclusive_type)
		if(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS)
			var/list/new_target_contents = new_target.important_recursive_contents //cache for sanic speeds (lists are references anyways)
			GRID_CELL_SET(intersecting_cell.client_contents, new_target_contents[SPATIAL_GRID_CONTENTS_TYPE_CLIENTS])
			SEND_SIGNAL(intersecting_cell, SPATIAL_GRID_CELL_ENTERED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS), new_target_contents[SPATIAL_GRID_CONTENTS_TYPE_CLIENTS])

		if(SPATIAL_GRID_CONTENTS_TYPE_HEARING)
			var/list/new_target_contents = new_target.important_recursive_contents
			GRID_CELL_SET(intersecting_cell.hearing_contents, new_target.important_recursive_contents[SPATIAL_GRID_CONTENTS_TYPE_HEARING])
			SEND_SIGNAL(intersecting_cell, SPATIAL_GRID_CELL_ENTERED(SPATIAL_GRID_CONTENTS_TYPE_HEARING), new_target_contents[SPATIAL_GRID_CONTENTS_TYPE_HEARING])

		if(SPATIAL_GRID_CONTENTS_TYPE_ATMOS)
			GRID_CELL_SET(intersecting_cell.atmos_contents, new_target)
			SEND_SIGNAL(intersecting_cell, SPATIAL_GRID_CELL_ENTERED(SPATIAL_GRID_CONTENTS_TYPE_ATMOS), new_target)

	return intersecting_cell

/**
 * find the spatial map cell that target used to belong to, then remove the target (and sometimes it's important_recusive_contents) from it.
 * make sure to provide the turf old_target used to be "in"
 *
 * * old_target - the thing we want to remove from the spatial grid cell
 * * target_turf - the turf we use to determine the cell we're removing from
 * * exclusive_type - either null or a valid contents channel. if you just want to remove a single type from the grid cell then use this
 */
/datum/controller/subsystem/spatial_grid/proc/exit_cell(atom/movable/old_target, turf/target_turf, exclusive_type)
	if(!initialized)
		return

	if(!target_turf || !old_target.spatial_grid_key)
		stack_trace("/datum/controller/subsystem/spatial_grid/proc/exit_cell() was given null arguments or a old_target that doesn't use the spatial grid!")
		return FALSE

	var/x_index = GET_SPATIAL_INDEX(target_turf.x)
	var/y_index = GET_SPATIAL_INDEX(target_turf.y)
	var/z_index = target_turf.z

	var/datum/spatial_grid_cell/intersecting_cell = grids_by_z_level[z_index][y_index][x_index]
	for(var/type in spatial_grid_categories[old_target.spatial_grid_key])
		switch(type)
			if(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS)
				var/list/old_target_contents = old_target.important_recursive_contents?[type] || old_target
				GRID_CELL_REMOVE(intersecting_cell.client_contents, old_target_contents)
				SEND_SIGNAL(intersecting_cell, SPATIAL_GRID_CELL_EXITED(type), old_target_contents)

			if(SPATIAL_GRID_CONTENTS_TYPE_HEARING)
				var/list/old_target_contents = old_target.important_recursive_contents?[type] || old_target
				GRID_CELL_REMOVE(intersecting_cell.hearing_contents, old_target_contents)
				SEND_SIGNAL(intersecting_cell, SPATIAL_GRID_CELL_EXITED(type), old_target_contents)

			if(SPATIAL_GRID_CONTENTS_TYPE_ATMOS)
				GRID_CELL_REMOVE(intersecting_cell.atmos_contents, old_target)
				SEND_SIGNAL(intersecting_cell, SPATIAL_GRID_CELL_EXITED(type), old_target)

	return TRUE

///acts like exit_cell() but only removes the target from the specified type of grid cell contents list
/datum/controller/subsystem/spatial_grid/proc/remove_single_type(atom/movable/old_target, turf/target_turf, exclusive_type)
	if(!target_turf || !exclusive_type || !old_target.spatial_grid_key)
		stack_trace("/datum/controller/subsystem/spatial_grid/proc/remove_single_type() was given null arguments or an old_target that doesn't use the spatial grid!")
		return FALSE

	if(!(exclusive_type in spatial_grid_categories[old_target.spatial_grid_key]))
		return FALSE

	var/x_index = GET_SPATIAL_INDEX(target_turf.x)
	var/y_index = GET_SPATIAL_INDEX(target_turf.y)
	var/z_index = target_turf.z

	var/datum/spatial_grid_cell/intersecting_cell = grids_by_z_level[z_index][y_index][x_index]

	switch(exclusive_type)
		if(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS)
			var/list/old_target_contents = old_target.important_recursive_contents?[exclusive_type] || old_target //cache for sanic speeds (lists are references anyways)
			GRID_CELL_REMOVE(intersecting_cell.client_contents, old_target_contents)
			SEND_SIGNAL(intersecting_cell, SPATIAL_GRID_CELL_EXITED(exclusive_type), old_target_contents)

		if(SPATIAL_GRID_CONTENTS_TYPE_HEARING)
			var/list/old_target_contents = old_target.important_recursive_contents?[exclusive_type] || old_target
			GRID_CELL_REMOVE(intersecting_cell.hearing_contents, old_target_contents)
			SEND_SIGNAL(intersecting_cell, SPATIAL_GRID_CELL_EXITED(exclusive_type), old_target_contents)

		if(SPATIAL_GRID_CONTENTS_TYPE_ATMOS)
			GRID_CELL_REMOVE(intersecting_cell.atmos_contents, old_target)
			SEND_SIGNAL(intersecting_cell, SPATIAL_GRID_CELL_EXITED(exclusive_type), old_target)

	return TRUE

/// if for whatever reason this movable is "untracked" e.g. it breaks the assumption that a movable is only inside the contents of any grid cell associated with its loc,
/// this will error. this checks every grid cell in the world so dont call this on live unless you have to.
/// returns TRUE if this movable is untracked, FALSE otherwise
/datum/controller/subsystem/spatial_grid/proc/untracked_movable_error(atom/movable/movable_to_check)
	if(!movable_to_check?.spatial_grid_key)
		return FALSE

	if(!initialized)
		return FALSE

	var/datum/spatial_grid_cell/loc_cell = get_cell_of(movable_to_check)
	var/list/containing_cells = find_hanging_cell_refs_for_movable(movable_to_check, remove_from_cells=FALSE)
	//if we're in multiple cells, throw an error.
	//if we're in 1 cell but it cant be deduced by our location, throw an error.
	if(length(containing_cells) > 1 || (length(containing_cells) == 1 && loc_cell && containing_cells[1] != loc_cell && containing_cells[1] != null))
		var/error_data = ""

		var/location_string = "which is in nullspace, and thus not be within the contents of any spatial grid cell"
		if(loc_cell)
			location_string = "which is supposed to only be in the contents of a spatial grid cell at coords: ([GRID_INDEX_TO_COORDS(loc_cell.cell_x)], [GRID_INDEX_TO_COORDS(loc_cell.cell_y)], [loc_cell.cell_z])"

		var/error_explanation = "was in the contents of [length(containing_cells)] spatial grid cells when it was only supposed to be in one!"
		if(length(containing_cells) == 1)
			error_explanation = "was in the contents of 1 spatial grid cell but it was inside the area handled by another grid cell!"
			var/datum/spatial_grid_cell/bad_cell = containing_cells[1]

			error_data = "within the contents of a cell at coords: ([GRID_INDEX_TO_COORDS(bad_cell.cell_x)], [GRID_INDEX_TO_COORDS(bad_cell.cell_y)], [bad_cell.cell_z])"

		if(!error_data)
			for(var/datum/spatial_grid_cell/cell in containing_cells)
				var/coords = "([GRID_INDEX_TO_COORDS(cell.cell_x)], [GRID_INDEX_TO_COORDS(cell.cell_y)], [cell.cell_z])"
				var/contents = ""

				if(movable_to_check in cell.hearing_contents)
					contents = "hearing"

				if(movable_to_check in cell.client_contents)
					if(length(contents) > 0)
						contents = "[contents], client"
					else
						contents = "client"

				if(movable_to_check in cell.atmos_contents)
					if(length(contents) > 0)
						contents = "[contents], atmos"
					else
						contents = "atmos"

				if(length(error_data) > 0)
					error_data = "[error_data], {coords: [coords], within channels: [contents]}"
				else
					error_data = "within the contents of the following cells: {coords: [coords], within channels: [contents]}"

		/**
		 * example:
		 *
		 * /mob/living/trolls_the_maintainer instance, which is supposed to only be in the contents of a spatial grid cell at coords: (136, 136, 14),
		 * was in the contents of 3 spatial grid cells when it was only supposed to be in one! within the contents of the following cells:
		 * {(68, 153, 2), within channels: hearing},
		 * {coords: (221, 170, 3), within channels: hearing},
		 * {coords: (255, 153, 11), within channels: hearing},
		 * {coords: (136, 136, 14), within channels: hearing}.
		 */
		stack_trace("[movable_to_check.type] instance, [location_string], [error_explanation] [error_data].")

		return TRUE

	return FALSE

/**
 * remove this movable from the grid by finding the grid cell its in and removing it from that.
 * if it cant infer a grid cell its located in (e.g. if its in nullspace but it can happen if the grid isnt expanded to a z level), search every grid cell.
 */
/datum/controller/subsystem/spatial_grid/proc/force_remove_from_grid(atom/movable/to_remove)
	if(!to_remove?.spatial_grid_key)
		return

	if(!initialized)
		remove_from_pre_init_queue(to_remove)//the spatial grid doesnt exist yet, so just take it out of the queue
		return

#ifdef UNIT_TESTS
	if(untracked_movable_error(to_remove))
		find_hanging_cell_refs_for_movable(to_remove, remove_from_cells=FALSE) //dont remove from cells because we should be able to see 2 errors
		return
#endif

	var/datum/spatial_grid_cell/loc_cell = get_cell_of(to_remove)

	if(loc_cell)
		GRID_CELL_REMOVE_ALL(loc_cell, to_remove)
	else
		find_hanging_cell_refs_for_movable(to_remove, remove_from_cells=TRUE)

///remove this movable from the given spatial_grid_cell
/datum/controller/subsystem/spatial_grid/proc/force_remove_from_cell(atom/movable/to_remove, datum/spatial_grid_cell/input_cell)
	if(!input_cell)
		return

	GRID_CELL_REMOVE_ALL(input_cell, to_remove)

///if shit goes south, this will find hanging references for qdeleting movables inside the spatial grid
/datum/controller/subsystem/spatial_grid/proc/find_hanging_cell_refs_for_movable(atom/movable/to_remove, remove_from_cells = TRUE)

	var/list/queues_containing_movable = list()
	for(var/queue_channel in waiting_to_add_by_type)
		var/list/queue_list = waiting_to_add_by_type[queue_channel]
		if(to_remove in queue_list)
			queues_containing_movable += queue_channel//just add the associative key
			if(remove_from_cells)
				queue_list -= to_remove

	if(!initialized)
		return queues_containing_movable

	var/list/containing_cells = list()
	for(var/list/z_level_grid as anything in grids_by_z_level)
		for(var/list/cell_row as anything in z_level_grid)
			for(var/datum/spatial_grid_cell/cell as anything in cell_row)
				if(to_remove in (cell.hearing_contents | cell.client_contents | cell.atmos_contents))
					containing_cells += cell
					if(remove_from_cells)
						force_remove_from_cell(to_remove, cell)

	return containing_cells

///debug proc for checking if a movable is in multiple cells when it shouldnt be (ie always unless multitile entering is implemented)
/atom/proc/find_all_cells_containing(remove_from_cells = FALSE)
	var/datum/spatial_grid_cell/real_cell = SSspatial_grid.get_cell_of(src)
	var/list/containing_cells = SSspatial_grid.find_hanging_cell_refs_for_movable(src, remove_from_cells)

	message_admins("[src] is located in the contents of [length(containing_cells)] spatial grid cells")

	var/cell_coords = "the following cells contain [src]: "
	for(var/datum/spatial_grid_cell/cell as anything in containing_cells)
		cell_coords += "([cell.cell_x], [cell.cell_y], [cell.cell_z]), "

	message_admins(cell_coords)
	message_admins("[src] is supposed to only be contained in the cell at indexes ([real_cell.cell_x], [real_cell.cell_y], [real_cell.cell_z]). but is contained at the cells at [cell_coords]")

///creates number_to_generate new oranges_ear's and adds them to the subsystems list of ears.
///i really fucking hope this never gets called after init :clueless:
/datum/controller/subsystem/spatial_grid/proc/pregenerate_more_oranges_ears(number_to_generate)
	for(var/new_ear in 1 to number_to_generate)
		pregenerated_oranges_ears += new/mob/oranges_ear(null)

	number_of_oranges_ears = length(pregenerated_oranges_ears)

///allocate one [/mob/oranges_ear] mob per turf containing atoms_that_need_ears and give them a reference to every listed atom in their turf.
///if an oranges_ear is allocated to a turf that already has an oranges_ear then the second one fails to allocate (and gives the existing one the atom it was assigned to)
/datum/controller/subsystem/spatial_grid/proc/assign_oranges_ears(list/atoms_that_need_ears)
	var/input_length = length(atoms_that_need_ears)

	if(input_length > number_of_oranges_ears)
		stack_trace("somehow, for some reason, more than the preset generated number of oranges ears was requested. thats fucking [number_of_oranges_ears]. this is not good that should literally never happen")
		pregenerate_more_oranges_ears(input_length - number_of_oranges_ears)//im still gonna DO IT but ill complain about it

	. = list()

	///the next unallocated /mob/oranges_ear that we try to allocate to assigned_atom's turf
	var/mob/oranges_ear/current_ear
	///the next atom in atoms_that_need_ears an ear assigned to it
	var/atom/assigned_atom
	///the turf loc of the current assigned_atom. turfs are used to track oranges_ears already assigned to one location so we dont allocate more than one
	///because allocating more than one oranges_ear to a given loc wastes view iterations
	var/turf/turf_loc

	for(var/current_ear_index in 1 to input_length)
		assigned_atom = atoms_that_need_ears[current_ear_index]

		turf_loc = get_turf(assigned_atom)
		if(!turf_loc)
			continue

		current_ear = pregenerated_oranges_ears[current_ear_index]

		if(turf_loc.assigned_oranges_ear)
			turf_loc.assigned_oranges_ear.references += assigned_atom
			continue //if theres already an oranges_ear mob at assigned_movable's turf we give assigned_movable to it instead and dont allocate ourselves

		current_ear.references += assigned_atom

		current_ear.loc = turf_loc //normally this is bad, but since this is meant to be as fast as possible we literally just need to exist there for view() to see us
		turf_loc.assigned_oranges_ear = current_ear

		. += current_ear

///debug proc for finding how full the cells of src's z level are
/atom/proc/find_grid_statistics_for_z_level(insert_clients = 0)
	var/raw_clients = 0
	var/raw_hearables = 0
	var/raw_atmos = 0

	var/cells_with_clients = 0
	var/cells_with_hearables = 0
	var/cells_with_atmos = 0

	var/list/client_list = list()
	var/list/hearable_list = list()
	var/list/atmos_list = list()

	var/x_cell_count = world.maxx / SPATIAL_GRID_CELLSIZE
	var/y_cell_count = world.maxy / SPATIAL_GRID_CELLSIZE

	var/total_cells = x_cell_count ** 2

	var/average_clients_per_cell = 0
	var/average_hearables_per_cell = 0
	var/average_atmos_mech_per_call = 0

	var/hearable_min_x = x_cell_count
	var/hearable_max_x = 1

	var/hearable_min_y = y_cell_count
	var/hearable_max_y = 1

	var/client_min_x = x_cell_count
	var/client_max_x = 1

	var/client_min_y = y_cell_count
	var/client_max_y = 1

	var/atmos_min_x = x_cell_count
	var/atmos_max_x = 1

	var/atmos_min_y = y_cell_count
	var/atmos_max_y = 1

	var/list/inserted_clients = list()

	if(insert_clients)
		var/list/turfs
		var/level = SSmapping.get_level(z)
		if(is_station_level(level))
			turfs = GLOB.station_turfs

		else
			turfs = Z_TURFS(z)

		for(var/client_to_insert in 0 to insert_clients)
			var/turf/random_turf = pick(turfs)
			var/mob/fake_client = new()
			fake_client.important_recursive_contents = list(SPATIAL_GRID_CONTENTS_TYPE_HEARING = list(fake_client), SPATIAL_GRID_CONTENTS_TYPE_CLIENTS = list(fake_client))
			fake_client.forceMove(random_turf)
			inserted_clients += fake_client

	var/list/all_z_level_cells = SSspatial_grid.get_cells_in_range(src, 1000)

	for(var/datum/spatial_grid_cell/cell as anything in all_z_level_cells)
		var/client_length = length(cell.client_contents)
		var/hearable_length = length(cell.hearing_contents)
		var/atmos_length = length(cell.atmos_contents)

		raw_clients += client_length
		raw_hearables += hearable_length
		raw_atmos += atmos_length

		if(client_length)
			cells_with_clients++

			client_list += cell.client_contents

			if(cell.cell_x < client_min_x)
				client_min_x = cell.cell_x

			if(cell.cell_x > client_max_x)
				client_max_x = cell.cell_x

			if(cell.cell_y < client_min_y)
				client_min_y = cell.cell_y

			if(cell.cell_y > client_max_y)
				client_max_y = cell.cell_y

		if(hearable_length)
			cells_with_hearables++

			hearable_list += cell.hearing_contents

			if(cell.cell_x < hearable_min_x)
				hearable_min_x = cell.cell_x

			if(cell.cell_x > hearable_max_x)
				hearable_max_x = cell.cell_x

			if(cell.cell_y < hearable_min_y)
				hearable_min_y = cell.cell_y

			if(cell.cell_y > hearable_max_y)
				hearable_max_y = cell.cell_y

		if(raw_atmos)
			cells_with_atmos++

			atmos_list += cell.atmos_contents

			if(cell.cell_x < atmos_min_x)
				atmos_min_x = cell.cell_x

			if(cell.cell_x > atmos_max_x)
				atmos_max_x = cell.cell_x

			if(cell.cell_y < atmos_min_y)
				atmos_min_y = cell.cell_y

			if(cell.cell_y > atmos_max_y)
				atmos_max_y = cell.cell_y

	var/total_client_distance = 0
	var/total_hearable_distance = 0
	var/total_atmos_distance = 0

	var/average_client_distance = 0
	var/average_hearable_distance = 0
	var/average_atmos_distance = 0

	for(var/hearable in hearable_list)//n^2 btw
		for(var/other_hearable in hearable_list)
			if(hearable == other_hearable)
				continue
			total_hearable_distance += get_dist(hearable, other_hearable)

	for(var/client in client_list)//n^2 btw
		for(var/other_client in client_list)
			if(client == other_client)
				continue
			total_client_distance += get_dist(client, other_client)

	for(var/atmos in atmos_list)//n^2 btw
		for(var/other_atmos in atmos_list)
			if(atmos == other_atmos)
				continue
			total_atmos_distance += get_dist(atmos, other_atmos)

	if(length(hearable_list))
		average_hearable_distance = total_hearable_distance / length(hearable_list)
	if(length(client_list))
		average_client_distance = total_client_distance / length(client_list)
	if(length(atmos_list))
		average_atmos_distance = total_atmos_distance / length(atmos_list)

	average_clients_per_cell = raw_clients / total_cells
	average_hearables_per_cell = raw_hearables / total_cells
	average_atmos_mech_per_call = raw_atmos / total_cells

	for(var/mob/inserted_client as anything in inserted_clients)
		qdel(inserted_client)

	message_admins("on z level [z] there are [raw_clients] clients ([insert_clients] of whom are fakes inserted to random station turfs)\
	, [raw_hearables] hearables, and [raw_atmos] atmos machines. all of whom are inside the bounding box given by \
	clients: ([client_min_x], [client_min_y]) x ([client_max_x], [client_max_y]), \
	hearables: ([hearable_min_x], [hearable_min_y]) x ([hearable_max_x], [hearable_max_y]) \
	and atmos machines: ([atmos_min_x], [atmos_min_y]) x ([atmos_max_x], [atmos_max_y]), \
	on average there are [average_clients_per_cell] clients per cell, [average_hearables_per_cell] hearables per cell, \
	and [average_atmos_mech_per_call] per cell, \
	[cells_with_clients] cells have clients, [cells_with_hearables] have hearables, and [cells_with_atmos] have atmos machines \
	the average client distance is: [average_client_distance], the average hearable_distance is [average_hearable_distance], \
	and the average atmos distance is [average_atmos_distance] ")

#undef BOUNDING_BOX_MAX
#undef BOUNDING_BOX_MIN

#undef NUMBER_OF_PREGENERATED_ORANGES_EARS
