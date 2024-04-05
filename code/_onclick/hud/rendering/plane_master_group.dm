/// Datum that represents one "group" of plane masters
/// So all the main window planes would be in one, all the spyglass planes in another
/// Etc
/datum/plane_master_group
	/// Our key in the group list on /datum/hud
	/// Should be unique for any group of plane masters in the world
	var/key
	/// Our parent hud
	var/datum/hud/our_hud
	/// The atom our planes are being displayed "from"
	var/atom/source

	/// The view range of our port list(width, height)
	var/list/view_range = list(0, 0)
	/// Is our viewport being offset at all? if so by how much list(width, height)
	var/list/view_offsets = list(0, 0)

	/// The lower x cell used to pull our current view cells
	var/lower_x = 0
	/// The upper x cell used to pull our current view cells
	var/upper_x = 0
	/// The lower y cell used to pull our current view cells
	var/lower_y = 0
	/// The upper y cell used to pull our current view cells
	var/upper_y = 0
	/// The z coord used to pull our current view cells
	var/z = 0
	/// List in the form depth -> amount of view cells that require the depth
	var/list/depths_in_view
	/// List of cells in our view
	var/list/cells_in_view = list()
	/// List in the form "[plane]" = object, the plane masters we own
	var/list/atom/movable/screen/plane_master/plane_masters = list()
	/// List in the form "[target_plane]" = list(relays targeting this plane)
	/// We need a way to handle async relay additions
	var/list/relays = list()
	/// list in the form invalid_render_source -> actual_render_source
	/// We need to be able to correct invalid render sources in filters and shit
	var/list/canon_source_to_reality = list()

	/// Think of multiz as a stack of z levels. Each index in that stack has its own group of plane masters
	/// This variable is the plane offset our source atom is currently "on"
	/// We use it to track what we should show/not show
	/// Goes from 0 to the max (z level stack size - 1)
	var/active_offset = 0
	/// What, if any, submap we render onto
	var/map = ""
	/// Controls the screen_loc that owned plane masters will use when generating relays. Due to a Byond bug, relays using the CENTER positional loc
	/// Will be improperly offset
	var/relay_loc = "CENTER"

/datum/plane_master_group/New(key, map = "")
	. = ..()
	src.key = key
	src.map = map
	depths_in_view = new /list(SSmapping.max_plane_offset + 1)
	build_plane_masters(0, SSmapping.max_plane_offset)
	RegisterSignal(SSdcs, COMSIG_VIS_CELL_CREATED, PROC_REF(on_cell_create))

/datum/plane_master_group/Destroy()
	orphan_hud()
	QDEL_LIST_ASSOC_VAL(plane_masters)
	source = null
	return ..()

/// Display a plane master group to some viewer, so show all our planes to it
/datum/plane_master_group/proc/attach_to(datum/hud/viewing_hud)
	if(viewing_hud.master_groups[key])
		stack_trace("Hey brother, our key [key] is already in use by a plane master group on the passed in hud, belonging to [viewing_hud.mymob]. Ya fucked up, why are there dupes")
		return

	our_hud = viewing_hud
	our_hud.master_groups[key] = src
	hook_into_source()
	show_hud()
	offset_planes()

/// Hooks our plane master group into its starting source
/datum/plane_master_group/proc/hook_into_source()
	return 

/// Hide the plane master from its current hud, fully clear it out
/datum/plane_master_group/proc/orphan_hud()
	if(our_hud)
		our_hud.master_groups -= key
		hide_hud()
		our_hud = null

/// Well, refresh our group, mostly useful for plane specific updates
/datum/plane_master_group/proc/refresh_hud()
	hide_hud()
	show_hud()

/// Fully regenerate our group, resetting our planes to their compile time values
/datum/plane_master_group/proc/rebuild_hud()
	hide_hud()
	rebuild_plane_masters()
	show_hud()
	offset_planes()

/// Regenerate our plane masters, this is useful if we don't have a mob but still want to rebuild. Such in the case of changing the screen_loc of relays
/datum/plane_master_group/proc/rebuild_plane_masters()
	QDEL_LIST_ASSOC_VAL(plane_masters)
	build_plane_masters(0, SSmapping.max_plane_offset)

/datum/plane_master_group/proc/hide_hud()
	for(var/thing in plane_masters)
		var/atom/movable/screen/plane_master/plane = plane_masters[thing]
		plane.hide_from(our_hud.mymob)

/datum/plane_master_group/proc/show_hud()
	for(var/thing in plane_masters)
		var/atom/movable/screen/plane_master/plane = plane_masters[thing]
		show_plane(plane)

/// Updates our view size so we can recalc what depths should be in view
/datum/plane_master_group/proc/set_view_range(view_range)
	src.view_range = getviewsize(view_range)
	update_depth() 

/// Updates our view offsets so we can recalc what depths should be in view
/datum/plane_master_group/proc/set_view_offsets(list/view_offsets)
	src.view_offsets = view_offsets
	update_depth()

/// Sets our source atom. This dictates where in the world our planes "think" we are
/datum/plane_master_group/proc/set_source(atom/source)	
	if(src.source)
		UnregisterSignal(src.source, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	src.source = source
	if(source)
		RegisterSignal(source, COMSIG_MOVABLE_MOVED, PROC_REF(source_moved))
		RegisterSignal(source, COMSIG_QDELETING, PROC_REF(source_deleted))
	SEND_SIGNAL(src, COSMIG_PLANE_SOURCE_CHANGED, source)
	update_depth()

/datum/plane_master_group/proc/source_moved(datum/source)
	SIGNAL_HANDLER
	update_depth()

/datum/plane_master_group/proc/source_deleted(datum/source)
	SIGNAL_HANDLER
	set_source(null)

/// This is mostly a proc so it can be overriden by popups, since they have unique behavior they want to do
/datum/plane_master_group/proc/show_plane(atom/movable/screen/plane_master/plane)
	plane.show_to(our_hud.mymob)

/// Nice wrapper for the "[]"ing
/datum/plane_master_group/proc/get_plane(plane)
	return plane_masters["[plane]"]

/// Returns a list of all the plane master types we want to create
/datum/plane_master_group/proc/get_plane_types()
	return subtypesof(/atom/movable/screen/plane_master) - /atom/movable/screen/plane_master/rendering_plate

/// Actually generate our plane masters, in some offset range (where offset is the z layers to render to, because each "layer" in a multiz stack gets its own plane master cube)
/datum/plane_master_group/proc/build_plane_masters(starting_offset, ending_offset)
	for(var/atom/movable/screen/plane_master/mytype as anything in get_plane_types())
		for(var/plane_offset in starting_offset to ending_offset)
			if(plane_offset != 0 && !initial(mytype.allows_offsetting))
				continue
			var/atom/movable/screen/plane_master/instance = new mytype(null, null, src, plane_offset)
			plane_masters["[instance.plane]"] = instance
			prep_plane_instance(instance)

/// Similarly, exists so subtypes can do unique behavior to planes on creation
/datum/plane_master_group/proc/prep_plane_instance(atom/movable/screen/plane_master/instance)
	return

// It would be nice to setup parallaxing for stairs and things when doing this
// So they look nicer. if you can't it's all good, if you think you can sanely look at monster's work
// It's hard, and potentially expensive. be careful
/datum/plane_master_group/proc/offset_planes(use_scale = TRUE)
	// Check if this feature is disabled for the client, in which case don't use scale.
	var/mob/our_mob = our_hud?.mymob
	if(!our_mob?.client?.prefs?.read_preference(/datum/preference/toggle/multiz_parallax))
		use_scale = FALSE

	// No offset? piss off
	if(!SSmapping.max_plane_offset)
		return

	var/old_offset = active_offset
	var/new_offset = GET_TURF_PLANE_OFFSET(source)
	active_offset = new_offset
	var/list/offset_info = get_offsets()
	// We clamp here both because it lets us avoid contridicting ourselves and because it ensures these values are never null
	var/lowest_possible_offset = offset_info[1]
	var/highest_possible_offset = offset_info[2] 

	// Each time we go "down" a visual z level, we'll reduce the scale by this amount
	// Chosen because mothblocks liked it, didn't cause motion sickness while also giving a sense of height
	var/scale_by = 0.965
	if(!use_scale)
		// This is a workaround for two things
		// First of all, if a mob can see objects but not turfs, they will not be shown the holder objects we use for
		// What I'd like to do is revert to images if this case throws, but image vis_contents is broken
		// https://www.byond.com/forum/post/2821969
		// If that's ever fixed, please just use that. thanks :)
		scale_by = 1

	var/list/offsets = list()
	var/multiz_boundary = our_mob?.client?.prefs?.read_preference(/datum/preference/numeric/multiz_performance)

	for(var/offset in 0 to SSmapping.max_plane_offset)
		// Multiz boundaries disable transforms
		if(multiz_boundary != MULTIZ_PERFORMANCE_DISABLE && (multiz_boundary < abs(offset)))
			offsets += null
			continue

		// No transformations if we're landing ON you
		if(offset == 0)
			offsets += null
			continue

		var/scale = scale_by ** (offset)
		var/matrix/multiz_shrink = matrix()
		multiz_shrink.Scale(scale)
		offsets += multiz_shrink

	for(var/plane_key in plane_masters)
		var/atom/movable/screen/plane_master/plane = plane_masters[plane_key]
		if(!plane.allows_offsetting)
			continue

		var/visual_offset = plane.offset - new_offset
		var/should_rescale = TRUE
		if(plane.distance_from_owner == -visual_offset)
			should_rescale = FALSE
		// If we aren't being displayed, don't fuckin render ya hear me?
		// inverse the offset so it's in a nicer to think about space (- == below)
		if(!plane.set_distance_from_owner(our_mob, visual_offset * -1, multiz_boundary, lowest_possible_offset, highest_possible_offset))
			continue

		if(!plane.multiz_scaled)
			continue
		if(!should_rescale)
			continue

		// Set the transform to what we expect it to be at this point
		plane.transform = offsets[max((plane.offset - old_offset), 0) + 1]
		// So this will always animate nicely
		animate(plane, transform = offsets[max(visual_offset, 0) + 1], 0.05 SECONDS, easing = LINEAR_EASING)

/// Returns a list in the form list(lowest_possible_offset, highest_possible_offset)
/datum/plane_master_group/proc/get_offsets()
	var/lowest_possible_offset = -1
	var/highest_possible_offset = INFINITY
	for(var/depth in 1 to length(depths_in_view))
		if(!depths_in_view[depth])
			continue
		if(highest_possible_offset == INFINITY)
			highest_possible_offset = depth - 1
		lowest_possible_offset = depth - 1

	var/current_offset = GET_TURF_PLANE_OFFSET(source)
	lowest_possible_offset = max(lowest_possible_offset, current_offset)
	highest_possible_offset = min(highest_possible_offset, current_offset)

	return list(lowest_possible_offset, highest_possible_offset)

/// Fully recalculates the depths in our view. Expensive, but will ALWAYS work
/datum/plane_master_group/proc/reset_depth()
	remove_depth_block(lower_x, lower_y, upper_x, upper_y, z)
	depths_in_view = new /list(SSmapping.max_plane_offset + 1) // Just in case
	var/turf/source_turf = get_turf(source)
	lower_x = max(CELL_TRANSFORM(source_turf.x + view_offsets[1] - view_range[1] / 2 - 1), 1)
	lower_y = max(CELL_TRANSFORM(source_turf.y + view_offsets[2] - view_range[2] / 2 - 1), 1)
	upper_x = min(CELL_TRANSFORM(source_turf.x + view_offsets[1] + view_range[1] / 2 + 1), MAX_CELL_COUNT)
	upper_y = min(CELL_TRANSFORM(source_turf.y + view_offsets[2] + view_range[2] / 2 + 1), MAX_CELL_COUNT)
	z = source_turf.z
	add_depth_block(lower_x, lower_y, upper_x, upper_y, z)
	offset_planes()

/// Clears out depth info
/datum/plane_master_group/proc/clear_depth()
	remove_depth_block(lower_x, lower_y, upper_x, upper_y, z)
	depths_in_view = new /list(SSmapping.max_plane_offset + 1) // Just in case
	lower_x = 0
	lower_y = 0
	upper_x = 0
	upper_y = 0
	z = 0

/// Refreshes our depth stack and updates our plane masters to match it
/// Will try and do as little work as possible
/datum/plane_master_group/proc/update_depth()
	var/turf/source_turf = get_turf(source)
	if(!source_turf)
		clear_depth()
		return
	if(source_turf.z != z)
		reset_depth()
		return

	var/list/our_depths = depths_in_view
	var/list/our_cells = cells_in_view
	var/list/existing_depth = our_depths.Copy()
	var/list/existing_cells = our_cells.Copy()
	var/lower_x_cell = CELL_TRANSFORM(source_turf.x + view_offsets[1] - view_range[1] / 2 - 1) 
	var/lower_y_cell = CELL_TRANSFORM(source_turf.y + view_offsets[2] - view_range[2] / 2 - 1)
	var/upper_x_cell = CELL_TRANSFORM(source_turf.x + view_offsets[1] + view_range[1] / 2 + 1)
	var/upper_y_cell = CELL_TRANSFORM(source_turf.y + view_offsets[2] + view_range[2] / 2 + 1)
	var/list/new_cells = SSvis_cells.get_visibility_cells(lower_x_cell, lower_y_cell, upper_x_cell, upper_y_cell, source_turf.z)
	for(var/datum/visibility_cell/removed_cell as anything in existing_cells - new_cells)
		UnregisterSignal(removed_cell, list(COMSIG_CELL_DEPTH_CHANGED, COMSIG_QDELETING))
		var/list/depths = removed_cell.counts
		for(var/depth in 1 to length(depths))	
			our_depths[depth] -= depths[depth]
		our_cells -= removed_cell
	
	for(var/datum/visibility_cell/added_cell as anything in new_cells - existing_cells)
		RegisterSignal(added_cell, COMSIG_CELL_DEPTH_CHANGED, PROC_REF(cell_depth_changed))
		RegisterSignal(added_cell, COMSIG_QDELETING, PROC_REF(remove_cell))
		var/list/depths = added_cell.counts
		for(var/depth in 1 to length(depths))	
			our_depths[depth] += depths[depth]
		our_cells += added_cell

	lower_x = lower_x_cell
	lower_y = lower_y_cell
	upper_x = upper_x_cell
	upper_y = upper_y_cell
	z = source_turf.z

	for(var/depth in length(depths_in_view) to 1 step -1)
		if(!!existing_depth[depth] != !!depths_in_view[depth])
			offset_planes()
			break

/// Helper for other depth procs, adds a block of cells and DOES NOT refresh our planes
/datum/plane_master_group/proc/add_depth_block(lower_x, lower_y, upper_x, upper_y, z)
	var/list/our_depths = depths_in_view
	var/list/our_cells = cells_in_view
	var/list/datum/visibility_cell/new_cells = SSvis_cells.get_visibility_cells(lower_x, lower_y, upper_x, upper_y, z)
	for(var/datum/visibility_cell/cell as anything in new_cells)
		RegisterSignal(cell, COMSIG_CELL_DEPTH_CHANGED, PROC_REF(cell_depth_changed))
		RegisterSignal(cell, COMSIG_QDELETING, PROC_REF(remove_cell))
		var/list/depths = cell.counts
		for(var/depth in 1 to length(depths))	
			our_depths[depth] += depths[depth]
		our_cells += cell

/// Helper for other depth procs, removes a block of cells and DOES NOT refresh our planes
/datum/plane_master_group/proc/remove_depth_block(lower_x, lower_y, upper_x, upper_y, z)
	var/list/our_depths = depths_in_view
	var/list/our_cells = cells_in_view
	var/list/datum/visibility_cell/new_cells = SSvis_cells.get_visibility_cells(lower_x, lower_y, upper_x, upper_y, z)
	for(var/datum/visibility_cell/cell as anything in new_cells)
		UnregisterSignal(cell, list(COMSIG_CELL_DEPTH_CHANGED, COMSIG_QDELETING))
		var/list/depths = cell.counts
		for(var/depth in 1 to length(depths))	
			our_depths[depth] -= depths[depth]
		our_cells -= cell

/// Called whenever a cell is created in the world
/datum/plane_master_group/proc/on_cell_create(datum/source, datum/visibility_cell/new_cell, x, y)
	SIGNAL_HANDLER
	if(x < lower_x || x > upper_x || y < lower_y || y > upper_y)
		return
	// We assert that cells will not have any depth on creation
	RegisterSignal(new_cell, COMSIG_CELL_DEPTH_CHANGED, PROC_REF(cell_depth_changed))
	RegisterSignal(new_cell, COMSIG_QDELETING, PROC_REF(remove_cell))
	cells_in_view += new_cell

/// Reacts to one of our cells being deleted
/datum/plane_master_group/proc/remove_cell(datum/visibility_cell/cell)
	UnregisterSignal(cell, COMSIG_CELL_DEPTH_CHANGED)
	UnregisterSignal(cell, COMSIG_QDELETING)
	var/list/depths = cell.counts
	var/list/our_depths = depths_in_view
	var/changed = FALSE
	for(var/depth in 1 to length(depths))	
		our_depths[depth] -= depths[depth]
		if(!our_depths[depth])
			changed = TRUE
	cells_in_view -= cell
	if(changed)
		offset_planes()

/// Called whenever one of our tracked cells depth's changes
/datum/plane_master_group/proc/cell_depth_changed(datum/source, list/depths, removed = FALSE)
	SIGNAL_HANDLER
	if(removed)
		remove_depths(depths)
	else
		add_depths(depths)

/// Adds a list of depths to our set
/datum/plane_master_group/proc/add_depths(list/depths)
	var/list/our_depths = depths_in_view
	var/changed = FALSE
	for(var/depth in depths)	
		if(!our_depths[depth])
			changed = TRUE
		our_depths[depth] += 1
	if(changed)
		offset_planes()

/// Removes a list of depths from our set
/datum/plane_master_group/proc/remove_depths(list/depths)
	var/list/our_depths = depths_in_view
	var/changed = FALSE
	for(var/depth in depths)	
		our_depths[depth] -= 1
		if(!our_depths[depth])
			changed = TRUE
	if(changed)
		offset_planes()

/// Holds plane masters for popups, like camera windows
/datum/plane_master_group/popup
	/// The map view that owns this plane master group
	var/atom/movable/screen/map_view/our_view

/datum/plane_master_group/popup/New(key, map = "", atom/movable/screen/map_view/our_view)
	// We don't need to hook into this because we are explicitly owned by our view
	src.our_view = our_view
	return ..()

/datum/plane_master_group/popup/Destroy()
	. = ..()
	our_view = null

/datum/plane_master_group/popup/update_depth()
	if(our_view.just_the_center && source)
		var/list/old_depths = depths_in_view.Copy()
		clear_depth()
		depths_in_view[PLANE_TO_OFFSET(source.plane) + 1] = 1
		for(var/depth in length(depths_in_view) to 1 step -1)
			if(!!old_depths[depth] != !!depths_in_view[depth])
				offset_planes()
				break
		return 
	return ..()

// Note: We do not scale these planes, even though we could
// I think there's something wrong with transform relays on submaps. I hate byond
/datum/plane_master_group/popup/offset_planes(use_scale = TRUE)
	return ..(FALSE)

/// This is janky as hell but since something changed with CENTER positioning after build 1614 we have to switch to the bandaid LEFT,TOP positioning
/// using LEFT,TOP *at* or *before* 1614 will result in another broken offset for cameras
#define MAX_CLIENT_BUILD_WITH_WORKING_SECONDARY_MAPS 1614

/datum/plane_master_group/popup/attach_to(datum/hud/viewing_hud)
	// If we're about to display this group to a mob who's client is more recent than the last known version with working CENTER, then we need to remake the relays
	// with the correct screen_loc using the relay override
	if(viewing_hud.mymob?.client?.byond_build > MAX_CLIENT_BUILD_WITH_WORKING_SECONDARY_MAPS)
		relay_loc = "LEFT,TOP"
		rebuild_plane_masters()
	return ..()

#undef MAX_CLIENT_BUILD_WITH_WORKING_SECONDARY_MAPS

// Hook us into our mapview and its opinion on its source
/datum/plane_master_group/popup/hook_into_source()
	RegisterSignal(our_view, COMSIG_MAP_CENTER_CHANGED, PROC_REF(center_changed))
	RegisterSignal(our_view, COMSIG_MAP_BOUNDS_CHANGED, PROC_REF(bounds_changed))
	RegisterSignal(our_view, COMSIG_MAP_RENDER_MODE_CHANGED, PROC_REF(render_mode_changed))
	set_source(our_view.center)
	set_view_range(our_view.display_bounds)

/datum/plane_master_group/popup/proc/center_changed(datum/source, atom/new_center)
	SIGNAL_HANDLER
	set_source(new_center)

/datum/plane_master_group/popup/proc/bounds_changed(datum/source, list/bounds)
	SIGNAL_HANDLER
	set_view_range(bounds)

/datum/plane_master_group/popup/proc/render_mode_changed(datum/source, just_the_center)
	SIGNAL_HANDLER
	update_depth()


/// Holds the main plane master
/datum/plane_master_group/main

/datum/plane_master_group/main/hook_into_source()
	RegisterSignal(our_hud, COMSIG_HUD_EYE_CHANGED, PROC_REF(eye_changed))
	var/client/our_client = our_hud?.mymob?.client
	if(!our_client)
		return
	set_source(our_client.eye)
	attach_client(our_client)

/datum/plane_master_group/main/proc/attach_client(client/attach_to)
	if(!attach_to)
		return
	set_view_range(attach_to.view)
	set_view_offsets(list(attach_to.major_pixel_x, attach_to.major_pixel_y))
	RegisterSignal(attach_to, COMSIG_VIEW_SET, PROC_REF(view_changed), override = TRUE)
	RegisterSignal(attach_to, COMSIG_CLIENT_OFFSETS_CHANGED, PROC_REF(offsets_changed), override = TRUE)

/datum/plane_master_group/main/proc/eye_changed(client/source, atom/old_eye, atom/new_eye)
	SIGNAL_HANDLER
	set_source(new_eye)
	if(!old_eye) // If we had no eye before we assume this is a new client
		attach_client(our_hud?.mymob?.client)

/datum/plane_master_group/proc/view_changed(datum/source, new_size)
	SIGNAL_HANDLER
	set_view_range(new_size)

/datum/plane_master_group/proc/offsets_changed(datum/source, offset_x, offset_y)
	SIGNAL_HANDLER
	set_view_offsets(list(offset_x, offset_y))

/datum/plane_master_group/main/offset_planes(use_scale = TRUE)
	if(use_scale)
		return ..(our_hud.should_use_scale())
	return ..()


/// Hudless group. Exists for testing
/datum/plane_master_group/hudless
	var/mob/our_mob

/datum/plane_master_group/hudless/Destroy()
	. = ..()
	our_mob = null

/datum/plane_master_group/hudless/hide_hud()
	for(var/thing in plane_masters)
		var/atom/movable/screen/plane_master/plane = plane_masters[thing]
		plane.hide_from(our_mob)

/datum/plane_master_group/hudless/show_plane(atom/movable/screen/plane_master/plane)
	plane.show_to(our_mob)

/// Doesn't actually display anything. Double hack to allow us to build visualizations for depth sight
/datum/plane_master_group/hudless/no_bitches

/datum/plane_master_group/hudless/no_bitches/get_plane_types()
	return list()

// Shim to make things faster, yes I know it sucks
/datum/plane_master_group/hudless/no_bitches/update_depth()
	var/turf/source_turf = get_turf(source)
	if(!source_turf)
		clear_depth()
		return
	if(source_turf.z != z)
		reset_depth()
		return

	var/list/our_depths = depths_in_view
	var/list/our_cells = cells_in_view
	var/list/existing_cells = our_cells.Copy()
	var/lower_x_cell = CELL_TRANSFORM(source_turf.x + view_offsets[1] - view_range[1] / 2 - 1) 
	var/lower_y_cell = CELL_TRANSFORM(source_turf.y + view_offsets[2] - view_range[2] / 2 - 1)
	var/upper_x_cell = CELL_TRANSFORM(source_turf.x + view_offsets[1] + view_range[1] / 2 + 1)
	var/upper_y_cell = CELL_TRANSFORM(source_turf.y + view_offsets[2] + view_range[2] / 2 + 1)
	var/list/new_cells = SSvis_cells.get_visibility_cells(lower_x_cell, lower_y_cell, upper_x_cell, upper_y_cell, source_turf.z)
	for(var/datum/visibility_cell/removed_cell as anything in existing_cells - new_cells)
		var/list/depths = removed_cell.counts
		for(var/depth in 1 to length(depths))	
			our_depths[depth] -= depths[depth]
		our_cells -= removed_cell
	
	for(var/datum/visibility_cell/added_cell as anything in new_cells - existing_cells)
		var/list/depths = added_cell.counts
		for(var/depth in 1 to length(depths))	
			our_depths[depth] += depths[depth]
		our_cells += added_cell

	lower_x = lower_x_cell
	lower_y = lower_y_cell
	upper_x = upper_x_cell
	upper_y = upper_y_cell
	z = source_turf.z

/datum/plane_master_group/hudless/no_bitches/add_depth_block(lower_x, lower_y, upper_x, upper_y, z)
	var/list/our_depths = depths_in_view
	var/list/our_cells = cells_in_view
	var/list/datum/visibility_cell/new_cells = SSvis_cells.get_visibility_cells(lower_x, lower_y, upper_x, upper_y, z)
	for(var/datum/visibility_cell/cell as anything in new_cells)
		var/list/depths = cell.counts
		for(var/depth in 1 to length(depths))	
			our_depths[depth] += depths[depth]
		our_cells += cell

/datum/plane_master_group/hudless/no_bitches/remove_depth_block(lower_x, lower_y, upper_x, upper_y, z)
	var/list/our_depths = depths_in_view
	var/list/our_cells = cells_in_view
	var/list/datum/visibility_cell/new_cells = SSvis_cells.get_visibility_cells(lower_x, lower_y, upper_x, upper_y, z)
	for(var/datum/visibility_cell/cell as anything in new_cells)
		var/list/depths = cell.counts
		for(var/depth in 1 to length(depths))	
			our_depths[depth] -= depths[depth]
		our_cells -= cell

/datum/plane_master_group/hudless/no_bitches/offset_planes(use_scale)
	return	
