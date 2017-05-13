
#define FIELD_NO_SHAPE 0
#define FIELD_SHAPE_RADIUS_SQUARE 1
#define FIELD_SHAPE_CUSTOM_SQUARE 2

/datum/proximity_monitor/advanced
	var/name = "\improper Energy Field"
	var/list/edge_checkers

	//Field setup specifications
	var/field_shape = FIELD_NO_SHAPE
	var/square_radius = 0
	var/square_height = 0
	var/square_width = 0
	var/square_depth_up = 0
	var/square_depth_down = 0
	//Processing
	var/requires_processing = FALSE
	var/process_checkers = FALSE
	var/process_edge_checkers = FALSE
	var/setup_edge_checkers = FALSE
	var/setup_checkers = FALSE

/datum/proximity_monitor/advanced/New()
	SSfields.register_new_field(src)
	edge_checkers = list()
	..()

/datum/proximity_monitor/advanced/Destroy()
	SSfields.unregister_field(src)
	full_cleanup()
	return ..()

/datum/proximity_monitor/advanced/process()
	if(process_checkers)
		for(var/C in checkers)
			process_checker(C)
			CHECK_TICK
	if(process_edge_checkers)
		for(var/C in edge_checkers)
			process_edge_checker(C)
			CHECK_TICK

/datum/proximity_monitor/advanced/proc/process_checker(obj/effect/abstract/proximity_checker/advanced/inner/F)

/datum/proximity_monitor/advanced/proc/process_edge_checker(obj/effect/abstract/proximity_checker/advanced/edge/F)

/datum/proximity_monitor/advanced/proc/Initialize()
	setup_field()
	post_setup_field()

/datum/proximity_monitor/advanced/full_cleanup()
	QDEL_LIST(edge_checkers)
	..()

/datum/proximity_monitor/advanced/proc/UpdateEdgeCheckers()
	if(!field_shape)
		return
	var/turf/center = get_turf(host)
	QDEL_LIST(edge_checkers)
	edge_checkers = list()
	switch(field_shape)
		if(FIELD_SHAPE_RADIUS_SQUARE)
			for(var/ix in -square_radius to square_radius)
				for(var/iy in -square_radius to square_radius)
					edge_checkers += new obj/effect/abstract/proximity_checker/advanced/inner(locate(center.x + ix, center.y + iy, center.z), _monitor = src)
					CHECK_TICK
		if(FIELD_SHAPE_CUSTOM_SQUARE)
			for(var/ix in -square_width to square_width)
				for(var/iy in -square_height to square_height)
					for(var/iz in -square_depth_down to square_depth_up)
						edge_checkers += new /obj/effect/abstract/proximity_checker/advanced/inner(locate(center.x + ix, center.y + iy, center.z + iz), _monitor = src)
						CHECK_TICK

/datum/proximity_monitor/advanced/proc/recalculate_field(ignore_movement_check = FALSE)	//Call every time the field moves (done automatically if you use update_center) or a setup specification is changed.
	if((field_shape == FIELD_NO_SHAPE) || (!ignore_movement_check && (host.loc == last_host_loc)))
		return
	for(var/atom/I in edge_checkers)
		cleanup_edge_turf(I.loc, I)
	UpdateEdgeCheckers()
	for(var/atom/I in edge_checkers)
		setup_edge_turf(I.loc, I)
	if(field_shape == FIELD_SHAPE_RADIUS_SQUARE)	//uses proxchecker code partially.
		var/list/old = checkers.Copy()
		SetRange(square_radius, TRUE)
		var/list/needs_setup = checkers.Copy()
		needs_setup -= old
		var/list/needs_cleanup = old.Copy()
		needs_cleanup -= checkers
		for(var/atom/i in needs_setup)
			setup_field_turf(i.loc, i)
		for(var/atom/i in needs_cleanup)
			cleanup_field_turf(i.loc, i)
		return
	var/list/turf/old_turfs = list()
	for(var/atom/A in checkers)
		old_turfs += A.loc
	if(field_shape == FIELD_SHAPE_CUSTOM_SQUARE)
		var/turf/center = get_turf(host)
		var/list/turf/turfs = block(locate(center.x-square_width, center.y-square_height, center.z-square_depth_down), locate(center.x+square_width, center.y+square_height, center.z+square_depth_up))
		var/list/checkers_local = checkers
		var/old_checkers_len = checkers_local.len
		var/turfs_len = turfs.len
		var/old_checkers_used = min(turfs_len, old_checkers_len)
		//reuse what we can
		for(var/I in 1 to old_checkers_len)
			if(I <= old_checkers_used)
				var/obj/effect/abstract/proximity_checker/pc = checkers_local[I]
				pc.loc = turfs[I]
			else
				qdel(checkers_local[I])	//delete the leftovers
		if(old_checkers_len < turfs_len)
			//create what we lack
			for(var/I in (old_checkers_used + 1) to turfs_len)
				checkers_local += new /obj/effect/abstract/proximity_checker(turfs[I], src)
		else
			checkers_local.Cut(old_checkers_used + 1, old_checkers_len)
	var/list/turf/new_turfs = list()
	for(var/atom/A in checkers)
		new_turfs += A.loc
	var/list/turf/turfs_needing_setup = new_turfs.Copy()
	turfs_needing_setup -= old_turfs
	for(var/turf/T in turfs_needing_setup)
		setup_field_turf(T)
	var/list/turf/turfs_needing_cleanup = old_turfs.Copy()
	turfs_needing_cleanup -= new_turfs
	for(var/turf/T in turfs_needing_cleanup)
		cleanup_field_turf(T)

/datum/proximity_monitor/proc/field_turf_canpass(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/inner/F, turf/entering)
	return TRUE

/datum/proximity_monitor/proc/field_turf_uncross(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/inner/F)
	return TRUE

/datum/proximity_monitor/proc/field_turf_crossed(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/inner/F)
	return TRUE

/datum/proximity_monitor/proc/field_turf_uncrossed(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/inner/F)
	return TRUE

/datum/proximity_monitor/proc/field_edge_canpass(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/edge/F, turf/entering)
	return TRUE

/datum/proximity_monitor/proc/field_edge_uncross(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/edge/F)
	return TRUE

/datum/proximity_monitor/proc/field_edge_crossed(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/edge/F)
	return TRUE

/datum/proximity_monitor/proc/field_edge_uncrossed(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/edge/F)
	return TRUE

/datum/proximity_monitor/advanced/proc/post_setup_field()

/datum/proximity_monitor/advanced/proc/setup_field()

/datum/proximity_monitor/advanced/proc/cleanup_field_turf(turf/T)

/datum/proximity_monitor/advanced/proc/cleanup_edge_turf(turf/T)

/datum/proximity_monitor/advanced/proc/setup_field_turf(turf/T)

/datum/proximity_monitor/advanced/proc/setup_edge_turf(turf/T)

//Gets edge direction/corner, only works with square radius/WDH fields!
/datum/proximity_monitor/advanced/proc/get_edgechecker_direction(obj/effect/abstract/proximity_checker/advanced/edge/C, turf/center_override = null)
	var/turf/checking_from = get_turf(host)
	if(istype(center_override))
		checking_from = center_override
	if(field_shape != FIELD_SHAPE_RADIUS_SQUARE && field_shape != FIELD_SHAPE_CUSTOM_SQUARE)
		return
	if(!(C in edge_checkers))
		return
	var/turf/T = get_turf(C)
	switch(field_shape)
		if(FIELD_SHAPE_RADIUS_SQUARE)
			if(((T.x == (checking_from.x + square_radius)) || (T.x == (checking_from.x - square_radius))) && ((T.y == (checking_from.y + square_radius)) || (T.y == (checking_from.y - square_radius))))
				return get_dir(checking_from, T)
			if(T.x == (checking_from.x + square_radius))
				return EAST
			if(T.x == (checking_from.x - square_radius))
				return WEST
			if(T.y == (checking_from.y - square_radius))
				return SOUTH
			if(T.y == (checking_from.y + square_radius))
				return NORTH
		if(FIELD_SHAPE_CUSTOM_SQUARE)
			if(((T.x == (checking_from.x + square_width)) || (T.x == (checking_from.x - square_width))) && ((T.y == (checking_from.y + square_height)) || (T.y == (checking_from.y - square_height))))
				return get_dir(checking_from, T)
			if(T.x == (checking_from.x + square_width))
				return EAST
			if(T.x == (checking_from.x - square_width))
				return WEST
			if(T.y == (checking_from.y - square_height))
				return SOUTH
			if(T.y == (checking_from.y + square_height))
				return NORTH
