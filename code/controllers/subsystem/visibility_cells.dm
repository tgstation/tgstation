#define VIS_DISPLAYING_NOTHING 0
#define VIS_DISPLAYING_CELLS 1
#define VIS_DISPLAYING_EFFECTS 2

/// Alright. This system exists to let us pull the highest/lowest plane offset we need to render at a particular position
/// We store a list of "cells", clumps of turfs that we cache info on
/// Then when we need to check for info we call into those cells and request it
/// Doesn't take opacity into account because I am not interested in remaking camera code
SUBSYSTEM_DEF(vis_cells)
	name = "Visible Cells"
	flags = SS_NO_INIT
	runlevels = RUNLEVEL_LOBBY|RUNLEVELS_DEFAULT
	/// list of "visibility cells" by z level by x/y position
	/// Typically sparse but can be quite dense in some cases
	var/list/visibility_cells_by_z = list()
	/// List of cells that MIGHT be empty, gotta check
	var/list/datum/visibility_cell/inspection_queue = list()
	/// Should our cells display on creation
	var/display = VIS_DISPLAYING_NOTHING
	/// The z level overlays are displayed on, if any
	var/displayed_z = -1
	/// How many cells do we have? Purely a profiling thing
	var/cell_count = 0

/datum/controller/subsystem/vis_cells/stat_entry(msg)
	msg = "C:[cell_count] CL:[length(inspection_queue)]"
	return ..()

/datum/controller/subsystem/vis_cells/fire(resumed)
	var/list/inspection_queue = src.inspection_queue // CACHE FOR FUCKING SONIC SPEED LET'S GOOOOO
	while(length(inspection_queue))
		var/datum/visibility_cell/test = inspection_queue[length(inspection_queue)]
		var/list/counts = test.counts
		var/found_depth = FALSE
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

/datum/controller/subsystem/vis_cells/proc/generate_display_overlay(display_offset, source_offset)
	var/mutable_appearance/glow = mutable_appearance('icons/effects/effects.dmi', "atmos_top", plane = ABOVE_LIGHTING_PLANE, offset_const = source_offset)
	glow.alpha = 160
	glow.color = hsl_gradient(abs(display_offset - source_offset), 0, "#39e7b3", SSmapping.max_plane_offset, "#a7084a")
	return glow

/datum/controller/subsystem/vis_cells/proc/toggle_cell_display(atom/ref_point)
	if(display == VIS_DISPLAYING_EFFECTS)
		disable_effects_display()

	if(display == VIS_DISPLAYING_NOTHING)
		display = VIS_DISPLAYING_CELLS
		var/turf/ref_turf = get_turf(ref_point)
		displayed_z = ref_turf.z
		for(var/z in SSmapping.z_level_to_stack[displayed_z])
			var/list/x_cells = visibility_cells_by_z[z]
			for(var/list/y_cells in x_cells)
				for(var/datum/visibility_cell/cell in y_cells)
					cell.enable_display()
	else
		for(var/z in SSmapping.z_level_to_stack[displayed_z])
			var/list/x_cells = visibility_cells_by_z[z]
			for(var/list/y_cells in x_cells)
				for(var/datum/visibility_cell/cell in y_cells)
					cell.disable_display()
		display = VIS_DISPLAYING_NOTHING
		displayed_z = -1

/obj/effect/abstract/stepper 
	
/obj/effect/abstract/stepper/newtonian_move(direction, instant, start_delay)
	return	

/datum/controller/subsystem/vis_cells/proc/enable_effects_display(view_range, atom/ref_point)
	if(display == VIS_DISPLAYING_CELLS)
		toggle_cell_display()
	if(display == VIS_DISPLAYING_EFFECTS)
		disable_effects_display()
	display = VIS_DISPLAYING_EFFECTS
	var/list/view_info = getviewsize(view_range)
	var/list/possible_overlays = new /list(SSmapping.max_plane_offset + 1)
	for(var/source_offset in 1 to length(possible_overlays))
		possible_overlays[source_offset] = new /list(SSmapping.max_plane_offset + 1)
		for(var/display_offset in 1 to length(possible_overlays[source_offset]))
			possible_overlays[source_offset][display_offset] = generate_display_overlay(display_offset - 1, source_offset - 1)

	var/datum/plane_master_group/hudless/no_bitches/dummy_group = new()
	var/obj/effect/abstract/stepper/me_irl = new(null)
	dummy_group.set_source(me_irl)
	dummy_group.set_view_range(view_info)
	var/depth_size = SSmapping.max_plane_offset + 1
	var/turf/ref_turf = get_turf(ref_point)
	displayed_z = ref_turf.z
	for(var/z in SSmapping.z_level_to_stack[displayed_z])
		var/z_offset = GET_Z_PLANE_OFFSET(z)
		var/list/displays = possible_overlays[z_offset + 1]
		for(var/turf/color_turf as anything in Z_TURFS(z))
			me_irl.abstract_move(color_turf)
			var/list/depths = dummy_group.depths_in_view
			var/impactful_depth
			for(var/depth in depth_size to 1 step -1)
				if(depths[depth])
					impactful_depth = depth
					break
			if(isnull(impactful_depth))
				continue
			color_turf.overlays += displays[impactful_depth]

/datum/controller/subsystem/vis_cells/proc/disable_effects_display()
	var/list/all_overlays = list()
	for(var/source_offset in 1 to SSmapping.max_plane_offset + 1)
		for(var/display_offset in 1 to SSmapping.max_plane_offset + 1)
			all_overlays += generate_display_overlay(display_offset - 1, source_offset - 1)

	for(var/z in SSmapping.z_level_to_stack[displayed_z])
		for(var/turf/uncolor_turf as anything in Z_TURFS(z))
			uncolor_turf.overlays -= all_overlays
	display = VIS_DISPLAYING_NOTHING
	displayed_z = -1

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
	/// The MA we are currently displaying
	var/mutable_appearance/display

/datum/visibility_cell/New(x, y, z)
	src.x = x
	src.y = y
	src.z = z
	SSvis_cells.cell_count += 1
	if(SSvis_cells.display == VIS_DISPLAYING_CELLS && (SSvis_cells.displayed_z in SSmapping.z_level_to_stack[z]))
		enable_display()
	SEND_GLOBAL_SIGNAL(COMSIG_VIS_CELL_CREATED, src)
	return ..()

/datum/visibility_cell/proc/get_turfs_in_cell()
	var/lower_x = CELL_KEY_TO_POSITION(x)
	var/lower_y = CELL_KEY_TO_POSITION(y)
	var/turf/lower_corner = locate(lower_x, lower_y, z)
	return CORNER_BLOCK(lower_corner, CELL_SIZE, CELL_SIZE)

/datum/visibility_cell/proc/get_current_overlay()
	var/display_offset = null
	var/list/depths = counts
	for(var/depth in length(depths) to 1 step -1)
		if(depths[depth])
			display_offset = depth - 1
			break
	if(!display_offset)
		return null
	var/offset = GET_Z_PLANE_OFFSET(z)
	return SSvis_cells.generate_display_overlay(display_offset, offset)

/datum/visibility_cell/proc/enable_display()	
	RegisterSignal(src, COMSIG_CELL_DEPTH_CHANGED, PROC_REF(refresh_display))
	var/mutable_appearance/glow = get_current_overlay()
	for(var/turf/in_range as anything in get_turfs_in_cell())
		in_range.overlays += glow
	display = glow

/datum/visibility_cell/proc/refresh_display()
	var/mutable_appearance/display = src.display
	var/mutable_appearance/glow = get_current_overlay()
	for(var/turf/in_range as anything in get_turfs_in_cell())
		in_range.overlays -= display
		in_range.overlays += glow
	src.display = glow

/datum/visibility_cell/proc/disable_display()
	UnregisterSignal(src, COMSIG_CELL_DEPTH_CHANGED)
	var/mutable_appearance/display = src.display
	for(var/turf/in_range as anything in get_turfs_in_cell())
		in_range.overlays -= display
	src.display = null

/datum/visibility_cell/Destroy()
	if(SSvis_cells.display == VIS_DISPLAYING_CELLS && (SSvis_cells.displayed_z in SSmapping.z_level_to_stack[z]))
		disable_display()
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
	UNSETEMPTY(plane_visibility)

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
		inspection_queue += cell_info

/// Takes a block of space and returns a list of all the cells that apply to it
/// Expects the block in terms of cell coords rather then map coords
/datum/controller/subsystem/vis_cells/proc/get_visibility_cells(lower_x, lower_y, upper_x, upper_y, z)
	if(lower_x <= 0 || lower_y <= 0 || upper_x <= 0 || upper_y <= 0 || z <= 0)
		return list()
	var/list/cells_by_z = visibility_cells_by_z
	if(length(cells_by_z) < z)
		return list()
		
	var/list/our_z = cells_by_z[z]
	if(!our_z)
		return list()

	var/lower_y_key = lower_y
	var/upper_y_key = upper_y
	var/list/collected_cells = list()
	//Now that we've got the z layer sorted, we're gonna check the X line
	for(var/cell_x in lower_x to min(upper_x, length(our_z)))
		var/list/our_x = our_z[cell_x]
		if(!our_x)
			continue
					
		for(var/cell_y in lower_y_key to min(upper_y_key, length(our_x)))
			var/datum/visibility_cell/cell_info = our_x[cell_y]
			if(!cell_info)
				continue
			collected_cells += cell_info
	return collected_cells

#undef VIS_DISPLAYING_NOTHING
#undef VIS_DISPLAYING_CELLS
#undef VIS_DISPLAYING_EFFECTS
