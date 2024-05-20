/// Global list of dummy atoms in the form [z][x][y] scaled using GET_SPATIAL_INDEX
/// They sit in the bottom left corner of spatial grid cells and act as owners for things that want to be detached (mostly datums)
GLOBAL_LIST_EMPTY_TYPED(dummy_grid_atoms, /obj/effect/abstract/dummy_grid_source)

/proc/update_dummy_sources(z_level)
	var/list/layer = list()
	for(var/x in 1 to SPATIAL_GRID_CELLS_PER_SIDE(world.maxx))
		var/list/row = list()
		for(var/y in 1 to SPATIAL_GRID_CELLS_PER_SIDE(world.maxy))
			var/turf/bottom_left = locate(GRID_INDEX_TO_COORDS(x), GRID_INDEX_TO_COORDS(y), z_level)
			row += new /obj/effect/abstract/dummy_grid_source(bottom_left)
		layer += list(row)
	GLOB.dummy_grid_atoms += list(layer)

/obj/effect/abstract/dummy_grid_source
	/// List of grid contents by type
	var/list/grid_contents

/obj/effect/abstract/dummy_grid_source/Destroy(force)
	stack_trace("Deleted dummy grid source")
	return ..()

/obj/effect/abstract/dummy_grid_source/proc/get_grid_contents(grid_type)
	return grid_contents?[grid_type] || list()

/obj/effect/abstract/dummy_grid_source/proc/prepare_grid_type(grid_type)
	var/list/grid_contents = src.grid_contents
	if(!grid_contents)
		grid_contents = list()
		src.grid_contents = grid_contents
	if(grid_contents[grid_type])
		return
	grid_contents[grid_type] = list()
	SSspatial_grid.add_grid_awareness(src, grid_type)
	SSspatial_grid.add_grid_membership(src, get_turf(src), grid_type)

/obj/effect/abstract/dummy_grid_source/proc/add_to_contents(datum/thing, grid_type)
	if(!grid_contents?[grid_type])
		prepare_grid_type(grid_type)
	grid_contents[grid_type] += thing

/obj/effect/abstract/dummy_grid_source/proc/remove_from_contents(datum/thing, grid_type)
	grid_contents[grid_type] -= thing
	if(length(grid_contents[grid_type]))
		return
	grid_contents -= grid_type
	SSspatial_grid.remove_grid_membership(src, get_turf(src), grid_type)
	SSspatial_grid.remove_grid_awareness(src, grid_type)
	if(length(grid_contents))
		return
	grid_contents = null
