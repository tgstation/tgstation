GLOBAL_LIST_EMPTY(shuttle_frames_by_turf)

/datum/shuttle_frame
	/// The turfs that are part of this frame
	var/list/turfs = list()

	/// Turfs that are changing, but shouldn't be removed from the frame immediately in case they are still valid frame turfs after the change
	var/list/possibly_valid_changing_turfs = list()

	/// List of turfs to start the split check with (to avoid redundant flood fill checks)
	var/list/deferred_update_turfs = list()

	/// Turfs to check for the existence of shuttles - used for expanding custom shuttles
	var/list/shuttle_tracking_turfs = list()

	/// A list of shuttles on tracking turfs, each associated with a list of which tracking turfs the shuttle overlaps
	var/list/adjacent_shuttles = list()

	/// Turfs that are in our list of turfs, but also have had a shuttle land on them
	var/list/shuttle_covered_turfs = list()

/datum/shuttle_frame/New(list/initial_turfs)
	if(initial_turfs)
		add_turfs(initial_turfs)

/datum/shuttle_frame/proc/start_tracking_turf_for_shuttles(turf/to_track, dir)
	if(!shuttle_tracking_turfs[to_track])
		var/obj/docking_port/mobile/custom/shuttle = SSshuttle.get_containing_shuttle(to_track)
		if(istype(shuttle))
			if(!adjacent_shuttles[shuttle])
				start_tracking_shuttle(shuttle)
			adjacent_shuttles[shuttle][to_track] = TRUE
		RegisterSignals(to_track, list(COMSIG_TURF_ON_SHUTTLE_MOVE, COMSIG_TURF_REMOVED_FROM_SHUTTLE), PROC_REF(shuttle_leave_react))
		RegisterSignals(to_track, list(COMSIG_TURF_AFTER_SHUTTLE_MOVE, COMSIG_TURF_ADDED_TO_SHUTTLE), PROC_REF(shuttle_arrive_react))
	shuttle_tracking_turfs[to_track] |= dir

/datum/shuttle_frame/proc/stop_tracking_turf_for_shuttles(turf/to_stop_tracking)
	for(var/obj/docking_port/mobile/custom/shuttle as anything in adjacent_shuttles)
		var/list/turfs_tracking_shuttle = adjacent_shuttles[shuttle]
		if(turfs_tracking_shuttle[to_stop_tracking])
			turfs_tracking_shuttle -= to_stop_tracking
			if(!length(turfs_tracking_shuttle))
				stop_tracking_shuttle(shuttle)
	shuttle_tracking_turfs -= to_stop_tracking
	UnregisterSignal(to_stop_tracking, list(COMSIG_TURF_ON_SHUTTLE_MOVE, COMSIG_TURF_REMOVED_FROM_SHUTTLE, COMSIG_TURF_AFTER_SHUTTLE_MOVE, COMSIG_TURF_ADDED_TO_SHUTTLE))

/datum/shuttle_frame/proc/shuttle_leave_react(turf/source)
	SIGNAL_HANDLER
	for(var/obj/docking_port/mobile/custom/shuttle as anything in adjacent_shuttles)
		var/list/turfs_tracking_shuttle = adjacent_shuttles[shuttle]
		if(turfs_tracking_shuttle[source])
			turfs_tracking_shuttle -= source
			if(!length(turfs_tracking_shuttle))
				stop_tracking_shuttle(shuttle)
			break

/datum/shuttle_frame/proc/shuttle_arrive_react(turf/source)
	SIGNAL_HANDLER
	var/obj/docking_port/mobile/custom/shuttle = SSshuttle.get_containing_shuttle(source)
	if(istype(shuttle))
		start_tracking_shuttle(shuttle)
	adjacent_shuttles[shuttle][source] = TRUE

/datum/shuttle_frame/proc/start_tracking_shuttle(obj/docking_port/mobile/custom/shuttle)
	adjacent_shuttles[shuttle] = list()

/datum/shuttle_frame/proc/stop_tracking_shuttle(obj/docking_port/mobile/custom/shuttle)
	adjacent_shuttles -= shuttle

/datum/shuttle_frame/proc/add_turf(turf/new_turf)
	if(GLOB.shuttle_frames_by_turf[new_turf])
		stack_trace("turf already assigned to shuttle frame")
		return
	turfs[new_turf] = TRUE
	if(SSshuttle.get_containing_shuttle(new_turf))
		shuttle_covered_turfs[new_turf] = TRUE
	if(shuttle_tracking_turfs[new_turf])
		stop_tracking_turf_for_shuttles(new_turf)
	RegisterSignal(new_turf, COMSIG_TURF_ON_SHUTTLE_MOVE, PROC_REF(shuttle_uncover_react))
	RegisterSignal(new_turf, COMSIG_TURF_AFTER_SHUTTLE_MOVE, PROC_REF(shuttle_cover_react))
	GLOB.shuttle_frames_by_turf[new_turf] = src
	for(var/dir in GLOB.cardinals)
		var/turf/neighbor = get_step(new_turf, dir)
		if(turfs[neighbor])
			continue
		start_tracking_turf_for_shuttles(neighbor, REVERSE_DIR(dir))

/datum/shuttle_frame/proc/shuttle_cover_react(turf/source)
	shuttle_covered_turfs[source] = TRUE

/datum/shuttle_frame/proc/shuttle_uncover_react(turf/source)
	shuttle_covered_turfs -= source

/datum/shuttle_frame/proc/add_turfs(list/turfs)
	for(var/turf in turfs)
		add_turf(turf)

/datum/shuttle_frame/proc/remove_turf(turf/removed_turf)
	if(possibly_valid_changing_turfs[removed_turf])
		return
	UnregisterSignal(removed_turf, list(COMSIG_TURF_ON_SHUTTLE_MOVE, COMSIG_TURF_AFTER_SHUTTLE_MOVE))
	for(var/dir in GLOB.cardinals)
		var/turf/check_turf = get_step(removed_turf, dir)
		if(!turfs[check_turf])
			shuttle_tracking_turfs[check_turf] &= ~REVERSE_DIR(dir)
			if(!shuttle_tracking_turfs[check_turf])
				stop_tracking_turf_for_shuttles(check_turf)
			continue
		else
			shuttle_tracking_turfs[removed_turf] |= dir
		deferred_update_turfs[check_turf] = TRUE
	shuttle_covered_turfs -= removed_turf
	turfs -= removed_turf
	GLOB.shuttle_frames_by_turf -= removed_turf
	if(!length(turfs))
		qdel(src)
	else
		addtimer(CALLBACK(src, PROC_REF(auto_propagate_turf_removal)), 0, TIMER_UNIQUE | TIMER_DELETE_ME)

/datum/shuttle_frame/proc/remove_turfs(list/turfs)
	for(var/turf in turfs)
		remove_turf(turf)

/datum/shuttle_frame/proc/auto_propagate_turf_removal()
	var/list/islands = list()
	var/list/island_queues = list()
	for(var/deferred_update_turf in deferred_update_turfs)
		if(!turfs[deferred_update_turf])
			continue
		var/list/new_island = list()
		new_island[deferred_update_turf] = TRUE
		islands += list(list())
		island_queues += list(new_island)
	deferred_update_turfs.Cut()
	var/islands_modified = TRUE
	while(islands_modified && length(islands) > 1)
		islands_modified = FALSE
		for(var/island_idx in 1 to length(islands))
			var/list/island = islands[island_idx]
			var/list/queue = island_queues[island_idx]
			if(!length(queue))
				continue
			var/turf/check_turf = popleft(queue)
			if(!turfs[check_turf])
				continue
			island[check_turf] = TRUE
			islands_modified = TRUE
			var/list/to_enqueue = list()
			for(var/dir in GLOB.cardinals)
				var/turf/next_check_turf = get_step(check_turf, dir)
				if(!(next_check_turf && turfs[next_check_turf]) || island[next_check_turf] || queue[next_check_turf])
					continue
				to_enqueue[next_check_turf] = TRUE
			var/list/merge_indices = list()
			for(var/other_island_idx in 1 to length(islands))
				if(island_idx == other_island_idx)
					continue
				for(var/turf/enqueued_turf as anything in to_enqueue)
					if(islands[other_island_idx][enqueued_turf])
						merge_indices |= other_island_idx
						to_enqueue -= enqueued_turf
			for(var/merge_index in merge_indices)
				island |= islands[merge_index]
				queue |= island_queues[merge_index]
			queue |= to_enqueue
			var/total_removed = 0
			for(var/merge_index in merge_indices)
				var/effective_index = merge_index - total_removed
				islands.Cut(effective_index, effective_index+1)
				island_queues.Cut(effective_index, effective_index+1)
				total_removed++
			if(total_removed)
				break
	if(length(islands) < 2)
		return
	popleft(islands)
	for(var/other_island in islands)
		remove_turfs(other_island)
		new /datum/shuttle_frame(other_island)

/proc/assign_shuttle_construction_turf_to_frame(turf/new_turf)
	var/list/adjacent_frames = list()
	for(var/dir in GLOB.cardinals)
		var/turf/neighbor = get_step(new_turf, dir)
		if(!neighbor)
			continue
		var/datum/shuttle_frame/frame = GLOB.shuttle_frames_by_turf[neighbor]
		if(!frame)
			continue
		adjacent_frames |= frame
	switch(length(adjacent_frames))
		if(0)
			new /datum/shuttle_frame(list(new_turf))
		if(1)
			var/datum/shuttle_frame/frame = adjacent_frames[1]
			frame.add_turf(new_turf)
		else
			var/datum/shuttle_frame/frame = popleft(adjacent_frames)
			for(var/datum/shuttle_frame/other_frame as anything in adjacent_frames)
				var/list/turfs = other_frame.turfs.Copy()
				other_frame.remove_turfs(turfs)
				frame.add_turfs(turfs)
			frame.add_turf(new_turf)

/// Helper proc that tests to ensure all whiteship templates can spawn at their docking port, and logs their sizes
/// This should be a unit test, but too much of our other code breaks during shuttle movement, so not yet, not yet.
/proc/test_whiteship_sizes()
	var/obj/docking_port/stationary/port_type = /obj/docking_port/stationary/picked/whiteship
	var/datum/turf_reservation/docking_yard = SSmapping.request_turf_block_reservation(
		initial(port_type.width),
		initial(port_type.height),
		1,
	)
	var/turf/bottom_left = docking_yard.bottom_left_turfs[1]
	var/turf/spawnpoint = locate(
		bottom_left.x + initial(port_type.dwidth),
		bottom_left.y + initial(port_type.dheight),
		bottom_left.z,
	)

	var/obj/docking_port/stationary/picked/whiteship/port = new(spawnpoint)
	var/list/ids = port.shuttlekeys
	var/height = 0
	var/width = 0
	var/dheight = 0
	var/dwidth = 0
	var/delta_height = 0
	var/delta_width = 0
	for(var/id in ids)
		var/datum/map_template/shuttle/our_template = SSmapping.shuttle_templates[id]
		// We do a standard load here so any errors will properly runtimes
		var/obj/docking_port/mobile/ship = SSshuttle.action_load(our_template, port)
		if(ship)
			ship.jumpToNullSpace()
			ship = null
		// Yes this is very hacky, but we need to both allow loading a template that's too big to be an error state
		// And actually get the sizing information from every shuttle
		SSshuttle.load_template(our_template)
		var/obj/docking_port/mobile/theoretical_ship = SSshuttle.preview_shuttle
		if(theoretical_ship)
			height = max(theoretical_ship.height, height)
			width = max(theoretical_ship.width, width)
			dheight = max(theoretical_ship.dheight, dheight)
			dwidth = max(theoretical_ship.dwidth, dwidth)
			delta_height = max(theoretical_ship.height - theoretical_ship.dheight, delta_height)
			delta_width = max(theoretical_ship.width - theoretical_ship.dwidth, delta_width)
			theoretical_ship.jumpToNullSpace()
	qdel(port, TRUE)
	log_world("Whiteship sizing information. Use this to set the docking port, and the map size\n\
		Max Height: [height] \n\
		Max Width: [width] \n\
		Max DHeight: [dheight] \n\
		Max DWidth: [dwidth] \n\
		The following are the safest bet for map sizing. Anything smaller then this could in the worst case not fit in the docking port\n\
		Max Combined Width: [height + dheight] \n\
		Max Combinded Height [width + dwidth]")

/proc/custom_shuttle_room_check(obj/docking_port/mobile/custom/shuttle, list/neighboring_areas = list(), turf/check_turf)
	if(SSshuttle.get_containing_shuttle(check_turf) != shuttle)
		return EXTRA_ROOM_CHECK_SKIP
	var/area/check_area = check_turf.loc
	if(check_area != shuttle.default_area)
		neighboring_areas[check_area] = TRUE
		return EXTRA_ROOM_CHECK_SKIP
	var/move_mode = MOVE_AREA
	move_mode = check_turf.fromShuttleMove(move_mode = move_mode)
	if(move_mode & (MOVE_CONTENTS | MOVE_TURF))
		return
	for(var/atom/movable/movable as anything in check_turf.contents)
		CHECK_TICK
		if(movable.loc != check_turf)
			continue
		move_mode = movable.hypotheticalShuttleMove(0, move_mode, shuttle)
	if(!(move_mode & (MOVE_CONTENTS | MOVE_TURF)))
		return EXTRA_ROOM_CHECK_SKIP

/proc/shuttle_build_check(turf/origin, list/turfs, list/areas)
	var/z = origin.z
	var/using_prepassed_turfs = !!length(turfs)
	if(using_prepassed_turfs && !(turfs[origin]))
		. |= ORIGIN_NOT_ON_SHUTTLE
	if(length(SSshuttle.custom_shuttles) >= CONFIG_GET(number/max_shuttle_count))
		. |= TOO_MANY_SHUTTLES
	var/max_turfs = CONFIG_GET(number/max_shuttle_size)
	if(!using_prepassed_turfs)
		var/datum/shuttle_frame/frame = GLOB.shuttle_frames_by_turf[origin]
		if(!frame)
			. |= ORIGIN_NOT_ON_SHUTTLE
		else
			turfs += (frame.turfs - frame.shuttle_covered_turfs)
	var/turf_count = length(turfs)
	if(turf_count > max_turfs)
		. |= ABOVE_MAX_SHUTTLE_SIZE
	. |= shuttle_area_check(turfs.Copy(), areas, z)

/proc/shuttle_expand_check(turf/origin, obj/docking_port/mobile/shuttle, list/turfs, list/areas)
	var/z = origin.z
	var/using_prepassed_turfs = !!length(turfs)
	if(using_prepassed_turfs && !(turfs[origin]))
		. |= ORIGIN_NOT_ON_SHUTTLE
	var/max_turfs = CONFIG_GET(number/max_shuttle_size) - shuttle.turf_count
	var/list/adjacent_shuttles
	if(!using_prepassed_turfs)
		var/datum/shuttle_frame/frame = GLOB.shuttle_frames_by_turf[origin]
		if(!frame)
			. |= ORIGIN_NOT_ON_SHUTTLE
		else
			turfs += (frame.turfs - frame.shuttle_covered_turfs)
			adjacent_shuttles = frame.adjacent_shuttles
	var/turf_count = length(turfs)
	if(turf_count > max_turfs)
		. |= ABOVE_MAX_SHUTTLE_SIZE
	if(adjacent_shuttles && !adjacent_shuttles[shuttle])
		. |= FRAME_NOT_ADJACENT_TO_LINKED_SHUTTLE
	. |= shuttle_area_check(turfs.Copy(), areas, z)

/*
 * Check to see if the following conditions are met:
 * 1. All turfs in the region are within whitelisted areas
 * 2. The region does not contain the APC of a non-custom area
 * 3. If the region contains the APC of a custom area, it contains the entire area
 */
/proc/shuttle_area_check(list/turfs, list/areas, z)
	for(var/area/custom_area as anything in GLOB.custom_areas)
		var/list/area_turfs = custom_area.get_turfs_by_zlevel(z)
		var/turf_count = length(area_turfs)
		if(!turf_count)
			continue
		var/list/turfs_not_in_frame = area_turfs - turfs
		var/turfs_not_in_frame_count = length(turfs_not_in_frame)
		if(turfs_not_in_frame_count == turf_count)
			continue
		if(turfs_not_in_frame_count)
			if(custom_area.apc)
				var/obj/machinery/power/apc/apc = custom_area.apc
				var/list/wallmount_comps = apc.GetComponents(/datum/component/wall_mounted)
				var/datum/component/wall_mounted/wallmount_comp = length(wallmount_comps) && wallmount_comps[1]
				if(turfs[get_turf(apc)] || (wallmount_comp && turfs[wallmount_comp.hanging_wall_turf]))
					. |= CUSTOM_AREA_NOT_COMPLETELY_CONTAINED
		else if(areas)
			areas[custom_area] = area_turfs - turfs_not_in_frame
		turfs -= area_turfs
	while(length(turfs))
		var/turf/checked_turf = pick(turfs)
		var/area/checked_area = checked_turf.loc
		var/list/area_turfs = checked_area.get_turfs_by_zlevel(z)
		if(!checked_area.allow_shuttle_docking)
			. |= INTERSECTS_NON_WHITELISTED_AREA
		if(checked_area.apc)
			var/obj/machinery/power/apc/apc = checked_area.apc
			var/list/wallmount_comps = apc.GetComponents(/datum/component/wall_mounted)
			var/datum/component/wall_mounted/wallmount_comp = length(wallmount_comps) && wallmount_comps[1]
			if(turfs[get_turf(apc)] || (wallmount_comp && turfs[wallmount_comp.hanging_wall_turf]))
				. |= CONTAINS_APC_OF_NON_CUSTOM_AREA
		turfs -= area_turfs

/proc/convert_areas_to_shuttle_areas(list/turfs, list/in_areas, list/out_areas, list/underlying_areas, area_type = /area/shuttle/custom)
	for(var/area/area as anything in in_areas)
		var/area/new_area = new area_type()
		new_area.setup(area.name)
		out_areas += new_area
		var/list/area_turfs = in_areas[area]
		var/datum/component/custom_area/custom_area = area.GetComponent(/datum/component/custom_area)
		if(custom_area)
			underlying_areas += (custom_area.previous_areas & area_turfs)
		set_turfs_to_area(area_turfs, new_area)
		turfs -= area_turfs
		new_area.reg_in_areas_in_z()
		new_area.create_area_lighting_objects()
		new_area.power_change()
		for(var/obj/machinery/door/firedoor/firelock as anything in area.firedoors)
			firelock.CalculateAffectingAreas()
		if(!area.has_contained_turfs())
			qdel(area)

/proc/create_shuttle(mob/user, turf/origin, list/turfs, list/areas, shuttle_dir, port_dir = NORTH, area_type = /area/shuttle/custom, docking_port_type = /obj/docking_port/mobile/custom, obj/docking_port/stationary/dock_at, name, id, replace, custom = TRUE, force)
	if(!ispath(docking_port_type, /obj/docking_port/mobile))
		CRASH("docking_port_type must be /obj/docking_port/mobile or a subpath")
	if(!ispath(area_type, /area/shuttle))
		CRASH("area_type must be /area/shuttle or a subpath")
	if(!istype(dock_at))
		dock_at = new(origin)
		dock_at.unregister()
		dock_at.delete_after = TRUE
		dock_at.shuttle_id = null
		var/area/origin_area = get_area(origin)
		dock_at.name = origin_area.name
		dock_at.dir = port_dir

	var/list/default_area_turfs = turfs.Copy()
	// Convert each custom area into a shuttle area, then remove the affected turfs from the list of turfs to add to the default area
	var/list/shuttle_areas = list()
	var/list/underlying_areas = list()
	convert_areas_to_shuttle_areas(default_area_turfs, areas, shuttle_areas, underlying_areas, area_type)
	for(var/turf/turf as anything in default_area_turfs)
		underlying_areas[turf] = turf.loc

	// Merge the remaining frame turfs into a default shuttle area
	var/list/affected_areas = list()
	var/area/default_area = new area_type()
	default_area.setup(name)
	set_turfs_to_area(default_area_turfs, default_area, affected_areas)
	default_area.reg_in_areas_in_z()
	default_area.create_area_lighting_objects()
	default_area.power_change()
	for(var/area_name in affected_areas)
		var/area/merged_area = affected_areas[area_name]
		for(var/obj/machinery/door/firedoor/firelock as anything in merged_area.firedoors)
			firelock.CalculateAffectingAreas()
		if(!merged_area.has_contained_turfs())
			qdel(merged_area)
	shuttle_areas.Insert(1, default_area)

	var/obj/docking_port/mobile/mobile_port = new docking_port_type(origin, shuttle_areas)
	mobile_port.underlying_areas_by_turf += underlying_areas
	mobile_port.name = name
	mobile_port.shuttle_id = id
	mobile_port.port_direction = REVERSE_DIR(shuttle_dir)
	mobile_port.dir = port_dir
	mobile_port.calculate_docking_port_information()
	mobile_port.turf_count = length(turfs)

	for(var/turf/turf as anything in turfs)
		turf.stack_below_baseturf(/turf/open/floor/plating, /turf/baseturf_skipover/shuttle)
		SEND_SIGNAL(turf, COMSIG_TURF_ADDED_TO_SHUTTLE, mobile_port)
		if(!turf.depth_to_find_baseturf(/turf/baseturf_skipover/shuttle))
			continue
		var/turf/new_ceiling = get_step_multiz(turf, UP) // check if a ceiling is needed
		if(new_ceiling)
			// generate ceiling
			if(!(istype(new_ceiling, /turf/open/floor/engine/hull/ceiling) || new_ceiling.depth_to_find_baseturf(/turf/open/floor/engine/hull/ceiling)))
				if(istype(new_ceiling, /turf/open/openspace) || istype(new_ceiling, /turf/open/space/openspace))
					new_ceiling.place_on_top(/turf/open/floor/engine/hull/ceiling)
				else
					new_ceiling.stack_ontop_of_baseturf(/turf/open/openspace, /turf/open/floor/engine/hull/ceiling)
					new_ceiling.stack_ontop_of_baseturf(/turf/open/space/openspace, /turf/open/floor/engine/hull/ceiling)

	mobile_port.register(replace, custom)
	if(mobile_port.get_docked() != dock_at)
		mobile_port.initiate_docking(dock_at, force = TRUE)

	message_admins("[key_name(user)] has created a shuttle at [ADMIN_VERBOSEJMP(origin)].")
	log_shuttle("[key_name(user)] has created a shuttle at [get_area(origin)].")

	return mobile_port

/proc/expand_shuttle(mob/user, obj/docking_port/mobile/shuttle, list/turfs, list/areas)
	var/list/default_area_turfs = turfs.Copy()
	// Convert each custom area into a shuttle area, then remove the affected turfs from the list of turfs to add to the default area
	var/list/shuttle_areas = list()
	var/list/underlying_areas = list()
	convert_areas_to_shuttle_areas(default_area_turfs, areas, shuttle_areas, underlying_areas, shuttle.area_type)
	for(var/turf/turf as anything in default_area_turfs)
		underlying_areas[turf] = turf.loc

	var/list/affected_areas = list()
	var/area/default_area = shuttle.shuttle_areas[1]
	set_turfs_to_area(default_area_turfs, default_area, affected_areas)
	default_area.power_change()

	for(var/area_name in affected_areas)
		var/area/merged_area = affected_areas[area_name]
		for(var/obj/machinery/door/firedoor/firelock as anything in merged_area.firedoors)
			firelock.CalculateAffectingAreas()
		if(!merged_area.has_contained_turfs())
			qdel(merged_area)

	for(var/area/shuttle_area as anything in shuttle_areas)
		shuttle.shuttle_areas[shuttle_area] = TRUE

	var/list/bounds = shuttle.return_coords()
	var/x0 = bounds[1]
	var/y0 = bounds[2]
	var/x1 = bounds[3]
	var/y1 = bounds[4]
	var/bounds_need_recalculation
	for(var/turf/turf as anything in turfs)
		turf.stack_below_baseturf(/turf/open/floor/plating, /turf/baseturf_skipover/shuttle)
		SEND_SIGNAL(turf, COMSIG_TURF_ADDED_TO_SHUTTLE, shuttle)
		if(turf.depth_to_find_baseturf(/turf/baseturf_skipover/shuttle))
			var/turf/new_ceiling = get_step_multiz(turf, UP) // check if a ceiling is needed
			if(new_ceiling)
				// generate ceiling
				if(!(istype(new_ceiling, /turf/open/floor/engine/hull/ceiling) || new_ceiling.depth_to_find_baseturf(/turf/open/floor/engine/hull/ceiling)))
					if(istype(new_ceiling, /turf/open/openspace) || istype(new_ceiling, /turf/open/space/openspace))
						new_ceiling.place_on_top(/turf/open/floor/engine/hull/ceiling)
					else
						new_ceiling.stack_ontop_of_baseturf(/turf/open/openspace, /turf/open/floor/engine/hull/ceiling)
						new_ceiling.stack_ontop_of_baseturf(/turf/open/space/openspace, /turf/open/floor/engine/hull/ceiling)
		if(bounds_need_recalculation)
			continue
		if(!(ISINRANGE(turf.x, x0, x1) && ISINRANGE(turf.y, y0, y1)))
			bounds_need_recalculation = TRUE

	shuttle.turf_count += length(turfs)
	shuttle.underlying_areas_by_turf += underlying_areas
	SEND_SIGNAL(shuttle, COMSIG_SHUTTLE_EXPANDED, turfs)
	if(bounds_need_recalculation)
		QDEL_NULL(shuttle.assigned_transit)
		shuttle.calculate_docking_port_information()
	shuttle.initiate_docking(shuttle.get_docked(), force = TRUE)

	message_admins("[key_name(user)] has expanded [shuttle] at [ADMIN_VERBOSEJMP(user)].")
	log_shuttle("[key_name(user)] expanded [shuttle] at [get_area(user)].")

/proc/clear_empty_shuttle_turfs(obj/docking_port/mobile/shuttle)
	var/shuttle_z = shuttle.z
	var/bounds_need_recalculation
	var/docking_port_needs_relocated
	var/list/bounds = shuttle.return_coords()
	var/x0 = bounds[1]
	var/y0 = bounds[2]
	var/x1 = bounds[3]
	var/y1 = bounds[4]
	for(var/area/area as anything in shuttle.shuttle_areas)
		var/list/turfs = area.get_turfs_by_zlevel(shuttle_z)
		turfs = turfs.Copy()
		for(var/turf/turf as anything in turfs)
			var/move_mode = turf.fromShuttleMove(move_mode = MOVE_AREA)
			if(move_mode & (MOVE_TURF | MOVE_CONTENTS))
				continue
			for(var/atom/movable/movable as anything in turf.contents)
				//CHECK_TICK
				if(movable.loc != turf)
					continue
				if(movable == shuttle)
					continue
				move_mode = movable.hypotheticalShuttleMove(0, move_mode, shuttle)
			if(move_mode & (MOVE_TURF | MOVE_CONTENTS))
				continue
			if(shuttle.loc == turf)
				docking_port_needs_relocated = TRUE
				bounds_need_recalculation = TRUE
			var/area/new_area = shuttle.underlying_areas_by_turf[turf]
			if(!istype(new_area))
				new_area = GLOB.areas_by_type[SHUTTLE_DEFAULT_UNDERLYING_AREA]
			if(!istype(new_area))
				new_area = new SHUTTLE_DEFAULT_UNDERLYING_AREA(null)
			shuttle.underlying_areas_by_turf -= turf
			shuttle.turf_count--
			turfs -= turf
			turf.change_area(area, new_area)
			SEND_SIGNAL(turf, COMSIG_TURF_REMOVED_FROM_SHUTTLE, shuttle)
			if(bounds_need_recalculation)
				continue
			if(turf.x == x0 || turf.x == x1 || turf.y == y0 || turf.y == y1)
				bounds_need_recalculation = TRUE
		if(!length(turfs))
			var/obj/docking_port/mobile/custom/as_custom = shuttle
			if(!(istype(as_custom) && area == as_custom.default_area))
				shuttle.shuttle_areas -= area
				qdel(area)
	if(!shuttle.turf_count)
		qdel(shuttle)
		return
	if(docking_port_needs_relocated)
		shuttle.forceMove(pick(shuttle.underlying_areas_by_turf))
	if(bounds_need_recalculation)
		QDEL_NULL(shuttle.assigned_transit)
		shuttle.calculate_docking_port_information()
