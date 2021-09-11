/datum/spatial_grid_cell
	///our x index in the list of cells
	var/cell_x
	///our y index in the list of cells
	var/cell_y

	//every data point in a grid cell is separated by usecase

	///every hearing sensitive movable inside this cell
	var/list/hearing_contents = list()
	///every client possessed movable inside this cell
	var/list/client_contents = list()

/datum/spatial_grid_cell/New(cell_x, cell_y, cell_z)
	. = ..()
	src.cell_x = cell_x
	src.cell_y = cell_y

/datum/spatial_grid_cell/Destroy(force, ...)
	if(!force)//fuck you dont destroy this
		return

	. = ..()

SUBSYSTEM_DEF(spatial_grid)
	can_fire = FALSE
	init_order = INIT_ORDER_SPATIAL_GRID
	name = "Spatial Grid"

	///list of the spatial_grid_cell datums per z level, arranged in the order of y index then x index
	var/list/grids_by_z_level = list()

/datum/controller/subsystem/spatial_grid/Initialize(start_timeofday)
	. = ..()
	var/cells_per_side = world.maxx / SPATIAL_GRID_CELLSIZE //assume world.maxx == world.maxy
	for(var/datum/space_level/z_level as anything in SSmapping.z_list)
		var/list/new_cell_grid = list()

		grids_by_z_level += list(new_cell_grid)

		for(var/y in 1 to cells_per_side)
			new_cell_grid += list(list())
			for(var/x in 1 to cells_per_side)
				var/datum/spatial_grid_cell/cell = new(x, y)
				new_cell_grid[y] += cell

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
	var/min_x = max(CEILING((center_x - range) * (1 / SPATIAL_GRID_CELLSIZE), 1), 1)
	var/min_y = max(CEILING((center_y - range) * (1 / SPATIAL_GRID_CELLSIZE), 1), 1)//calculating these indices only takes around 2 microseconds

	//the maximum x and y cell indexes to test
	var/max_x = min(CEILING((center_x + range) * (1 / SPATIAL_GRID_CELLSIZE), 1), grid_cells_per_axis)
	var/max_y = min(CEILING((center_y + range) * (1 / SPATIAL_GRID_CELLSIZE), 1), grid_cells_per_axis)

	var/list/grid_level = grids_by_z_level[center_turf.z]
	switch(type)
		if(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS)
			for(var/list/grid_row as anything in grid_level.Copy(min_y, max_y + 1))//from testing, slightly faster than iterating numbers from min_index to max_index
				for(var/datum/spatial_grid_cell/cell as anything in grid_row.Copy(min_x, max_x + 1))
					contents_to_return += cell.client_contents

		if(SPATIAL_GRID_CONTENTS_TYPE_HEARING)
			for(var/list/grid_row as anything in grid_level.Copy(min_y, max_y + 1))
				for(var/datum/spatial_grid_cell/cell as anything in grid_row.Copy(min_x, max_x + 1))
					contents_to_return += cell.hearing_contents

	if(!include_center)
		contents_to_return -= center

	if(!length(contents_to_return))
		return contents_to_return //we know that all of our contents are whats already in center

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

		//this turf search algorithm is the worst scaling part of this proc, scaling worse than view() for moderate ranges and > 50 length contents_to_return
		//luckily its significantly faster than view for large ranges in large spaces and/or relatively few contents_to_return
		var/turf/inbetween_turf = center_turf
		while(TRUE)
			inbetween_turf = get_step(inbetween_turf, get_dir(inbetween_turf, target_turf))

			if(inbetween_turf == target_turf)//we've gotten to target's turf without returning due to turf opacity, so we must be able to see target
				break

			if(inbetween_turf.opacity || inbetween_turf.opacity_sources)//this turf or something on it is opaque so we cant see through it
				contents_to_return -= target
				break

	return contents_to_return

///get the grid cell encomapassing targets coordinates and of the specified type
/datum/controller/subsystem/spatial_grid/proc/get_cell_of(atom/target)
	var/turf/target_turf = get_turf(target)

	var/list/grid = grids_by_z_level[target_turf.z]

	var/datum/spatial_grid_cell/cell_to_return = grid[CEILING(target_turf.y / SPATIAL_GRID_CELLSIZE, 1)][CEILING(target_turf.x / SPATIAL_GRID_CELLSIZE, 1)]
	return cell_to_return

///get all grid cells intersecting radius around center
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

	for(var/list/grid_row as anything in grid_level.Copy(min_y, max_y+1))
		for(var/datum/spatial_grid_cell/cell as anything in grid_row.Copy(min_x, max_x + 1))
			intersecting_grid_cells += cell

	return intersecting_grid_cells
