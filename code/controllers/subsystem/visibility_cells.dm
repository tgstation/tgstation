// Alright. This system exists to let us pull the highest/lowest plane offset we need to render at a particular position
// We store a list of "cells", clumps of turfs that we cache info on
// Then when we need to check for info we call into those cells and request it
// Doesn't take opacity into account because I am not interested in remaking camera code
SUBSYSTEM_DEF(vis_cells)
	name = "Visible Cells"
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_LOBBY|RUNLEVELS_DEFAULT
	/// list of "visibility cells" by z level by x/y position
	/// Typically sparse but can be quite dense in some cases
	var/list/visibility_cells_by_z = list()
	/// List of cells that MIGHT be empty, gotta check
	var/list/datum/visibility_cell/inspection_queue = list()
	var/cell_count = 0

/datum/controller/subsystem/vis_cells/stat_entry(msg)
	msg = "C:[cell_count] CL:[length(inspection_queue)]"
	return ..()

/datum/controller/subsystem/vis_cells/fire(resumed)
	var/list/inspection_queue = src.inspection_queue // CACHE FOR FUCKING SONIC SPEED LET'S GOOOOO
	while(length(inspection_queue))
		var/datum/visibility_cell/test = inspection_queue[length(inspection_queue)]
		var/list/counts = test.counts
		var/found_depth = TRUE
		for(var/depth in 1 to length(counts))
			if(counts[depth])
				found_depth = TRUE
				break
		if(!found_depth)
			qdel(test)

		inspection_queue.len--
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/vis_cells/proc/remove_cell(x, y, z)
	var/list/x_cells = visibility_cells_by_z[z]
	var/list/y_cells = x_cells[x]
	y_cells[y] = null
	var/list/y_copy = y_cells.Copy()
	list_clear_nulls(y_copy)
	if(!length(y_copy))
		// I am not interested in clearing away the z level's, it's too large a span
		// So we just stop at the rows
		x_cells[x] = null

/// Stores infromation about the visible z stacks stored at any one position
/// A datum purely because it allows me to register signals onto it (this is relevant for efficent movement)
/datum/visibility_cell
	var/x
	var/y
	var/z
	/// A list in the form depth +1 -> how many sources we have for each depth
	/// We are betting that this will not get desynced
	var/list/counts = list()
	/// Are we been queued for a checkover?
	var/queued_for_inspection = FALSE

/datum/visibility_cell/New(x, y, z)
	src.x = x
	src.y = y
	src.z = z
	SSvis_cells.cell_count += 1
	SEND_GLOBAL_SIGNAL(COMSIG_VIS_CELL_CREATED, src)
	return ..()

/datum/visibility_cell/Destroy()
	SSvis_cells.remove_cell(x, y, z)
	SSvis_cells.cell_count -= 1
	return ..()

/turf  
	/// Lazylist that stores depths this turf adds
	var/list/plane_visibility
	
/turf/proc/add_plane_visibilities(list/depths)
	LAZYINITLIST(plane_visibility)
	plane_visibility += depths
	SSvis_cells.insert_visibility_info(x, y, z, depths)

	var/turf/above = GET_TURF_ABOVE(src)
	if(above && HAS_TRAIT(above, TURF_Z_TRANSPARENT_TRAIT))
		above.add_plane_visibilities(depths)

/turf/proc/remove_plane_visibilities(list/depths)
	plane_visibility -= depths
	SSvis_cells.remove_visibility_info(x, y, z, depths)

	var/turf/above = GET_TURF_ABOVE(src)
	if(above && HAS_TRAIT(above, TURF_Z_TRANSPARENT_TRAIT))
		above.remove_plane_visibilities(depths)
	LAZYNULL(plane_visibility)

/// Increments visibilty info at a particular coord
/datum/controller/subsystem/vis_cells/proc/insert_visibility_info(x, y, z, list/depths)
	var/greatest_depth = max(depths)
	var/x_cell = CELL_TRANSFORM(x)
	var/y_cell = CELL_TRANSFORM(y)
	var/list/cells_by_z = visibility_cells_by_z
	
	if(length(cells_by_z) < z)
		cells_by_z.len = z
	var/list/our_z = cells_by_z[z]
	if(!our_z)
		our_z = new /list(MAX_CELL_COUNT)
		cells_by_z[z] = our_z

	var/list/our_x = our_z[x_cell]
	if(!our_x)
		our_x = new /list(MAX_CELL_COUNT)
		our_z[x_cell] = our_x

	var/datum/visibility_cell/cell_info = our_x[y_cell]
	if(!cell_info)
		cell_info = new(x_cell, y_cell, z)
		our_x[y_cell] = cell_info

	var/list/cell_count = cell_info.counts
	if(length(cell_count) < greatest_depth)
		cell_count.len = greatest_depth
	for(var/depth in depths)
		cell_count[depth] += 1
	SEND_SIGNAL(cell_info, COMSIG_CELL_DEPTH_CHANGED, depths, FALSE)
	if(cell_info.queued_for_inspection)
		cell_info.queued_for_inspection = FALSE
		inspection_queue -= cell_info

/// Removes the visibility information from a cell at the passed in coords
/datum/controller/subsystem/vis_cells/proc/remove_visibility_info(x, y, z, list/depths)
	var/greatest_depth = max(depths)
	var/x_cell = CELL_TRANSFORM(x)
	var/y_cell = CELL_TRANSFORM(y)
	var/list/cells_by_z = visibility_cells_by_z
	
	if(length(cells_by_z) < z)
		CRASH("Tried to remove visibility info from a cell at [x_cell] [y_cell] [z] but no cell existed")

	var/list/our_z = cells_by_z[z]
	if(!our_z || length(our_z) < x_cell)
		CRASH("Tried to remove visibility info from a cell at [x_cell] [y_cell] [z] but no cell existed")

	var/list/our_x = our_z[x_cell]
	if(!our_x || length(our_x) < y_cell)
		CRASH("Tried to remove visibility info from a cell at [x_cell] [y_cell] [z] but no cell existed")

	var/datum/visibility_cell/cell_info = our_x[y_cell]
	// What the fuck
	if(!cell_info)
		CRASH("Tried to remove visibility info from a cell at [x_cell] [y_cell] [z] but no cell existed")

	var/list/cell_count = cell_info.counts
	if(length(cell_count) < greatest_depth)
		stack_trace("Tried to remove visibility info from a cell at [x_cell] [y_cell] [z] but the cell did not have enough depth. (Ours: [greatest_depth], Cells: [length(cell_count)])")
		for(var/depth in depths)
			if(depth > length(cell_count))
				depths -= depth
		if(!length(depths))
			return

	var/removed_all = FALSE
	for(var/depth in depths)
		if(cell_count[depth] == 0)
			stack_trace("Tried to remove visibility info from a cell at [x_cell] [y_cell] [z] but the cell didn't have the sources to give [depth]")
			continue
		cell_count[depth] -= 1
		if(cell_count[depth] == 0)
			removed_all = TRUE

	// I'm sorry bout this but I do not want to have to register more shit on each cell then is absolutely needed
	SEND_SIGNAL(cell_info, COMSIG_CELL_DEPTH_CHANGED, depths, TRUE)
	if(removed_all && !cell_info.queued_for_inspection)
		cell_info.queued_for_inspection = TRUE
		SSvis_cells.inspection_queue += cell_info

/// Takes a block of space and returns a list of all the cells that apply to it
/datum/controller/subsystem/vis_cells/proc/get_visibility_cells(lower_x, lower_y, upper_x, upper_y, z)
	if(lower_x <= 0 || lower_y <= 0 || upper_x <= 0 || upper_y <= 0 || z <= 0)
		return list()
	var/list/cells_by_z = visibility_cells_by_z
	if(length(cells_by_z) < z)
		return list()
		
	var/list/our_z = cells_by_z[z]
	if(!our_z)
		return list()

	var/lower_y_key = CELL_TRANSFORM(lower_y)
	var/upper_y_key = CELL_TRANSFORM(upper_y)
	var/list/collected_cells = list()
	//Now that we've got the z layer sorted, we're gonna check the X line
	for(var/cell_x in CELL_TRANSFORM(lower_x) to min(CELL_TRANSFORM(upper_x), length(our_z)))
		var/list/our_x = our_z[cell_x]
		if(!our_x)
			continue
					
		for(var/cell_y in lower_y_key to min(upper_y_key, length(our_x)))
			var/datum/visibility_cell/cell_info = our_x[cell_y]
			if(!cell_info)
				continue
			collected_cells += cell_info
	return collected_cells

