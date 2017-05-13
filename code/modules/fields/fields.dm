
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

/datum/proximity_monitor/advanced/proc/process_inner_turf(obj/effect/abstract/proximity_checker/advanced/inner)

/datum/proximity_monitor/advanced/proc/process_edge_turf(obj/effect/abstract/proximity_checker/advanced/edge)

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
					edge_checkers += /obj/effect/abstract/proximity_checker/advanced/inner(locate(center.x + ix, center.y + iy, center.z), _monitor = src)
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
	if(field_shape == FIELD_SHAPE_RADIUS_SQUARE)	//uses proxchecker code partially.
		var/list/old = checkers.Copy()
		SetRange(square_radius, TRUE)
		UpdateEdgeCheckers()
		for(var/I in edge_checkers)
			setup_edge_checker(I)
		var/list/needs_setup = checkers.Copy()
		needs_setup -= old
		var/list/needs_cleanup = old.Copy()
		needs_cleanup -= checkers
		for(var/i in needs_setup)
			setup_checker(i.loc)
		for(var/i in needs_cleanup)
			cleanup_field_turf(i.loc)
		return
	update_new_turfs()
	var/list/turf/needs_setup = checkers_new.Copy()
	if(setup_checkers)
		for(var/turf/T in checkers)
			if(!(T in needs_setup))
				cleanup_field_turf(T)
			else
				needs_setup -= T
			CHECK_TICK
		for(var/turf/T in needs_setup)
			setup_field_turf(T)
			CHECK_TICK

/datum/proximity_monitor/advanced/proc/field_turf_canpass(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/inner/F, turf/entering)
	return TRUE

/datum/proximity_monitor/advanced/proc/field_turf_uncross(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/inner/F)
	return TRUE

/datum/proximity_monitor/advanced/proc/field_turf_crossed(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/inner/F)
	return TRUE

/datum/proximity_monitor/advanced/proc/field_turf_uncrossed(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/inner/F)
	return TRUE

/datum/proximity_monitor/advanced/proc/field_edge_canpass(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/edge/F, turf/entering)
	return TRUE

/datum/proximity_monitor/advanced/proc/field_edge_uncross(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/edge/F)
	return TRUE

/datum/proximity_monitor/advanced/proc/field_edge_crossed(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/edge/F)
	return TRUE

/datum/proximity_monitor/advanced/proc/field_edge_uncrossed(atom/movable/AM, obj/effect/abstract/proximity_checker/advanced/edge/F)
	return TRUE

/datum/proximity_monitor/advanced/proc/update_center(turf/T, recalculate_field = TRUE)
	center = T
	if(recalculate_field)
		recalculate_field()

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

//DEBUG FIELDS
/datum/proximity_monitor/advanced/debug
	name = "\improper Color Matrix Field"
	field_shape = FIELD_SHAPE_RADIUS_SQUARE
	square_radius = 5
	var/set_fieldturf_color = "#aaffff"
	var/set_edgeturf_color = "#ffaaff"
	setup_checkers = TRUE
	setup_edge_checkers = TRUE

/datum/proximity_monitor/advanced/debug/recalculate_field()
	..()

/datum/proximity_monitor/advanced/debug/post_setup_field()
	..()

/datum/proximity_monitor/advanced/debug/setup_edge_turf(turf/T)
	T.color = set_edgeturf_color
	..()

/datum/proximity_monitor/advanced/debug/cleanup_edge_turf(turf/T)
	T.color = initial(T.color)
	..()
	if(T in checkers)
		T.color = set_fieldturf_color

/datum/proximity_monitor/advanced/debug/setup_field_turf(turf/T)
	T.color = set_fieldturf_color
	..()

/datum/proximity_monitor/advanced/debug/cleanup_field_turf(turf/T)
	T.color = initial(T.color)
	..()

//DEBUG FIELD ITEM
/obj/item/device/multitool/field_debug
	name = "strange multitool"
	desc = "Seems to project a colored field!"
	var/list/field_params = list("field_shape" = FIELD_SHAPE_RADIUS_SQUARE, "square_radius" = 5, "set_fieldturf_color" = "#aaffff", "set_edgeturf_color" = "#ffaaff")
	var/field_type = /datum/proximity_monitor/advanced/debug
	var/operating = FALSE
	var/datum/proximity_monitor/advanced/current = null
	var/turf/center = null

/obj/item/device/multitool/field_debug/New()
	START_PROCESSING(SSobj, src)
	center = get_turf(src)
	..()

/obj/item/device/multitool/field_debug/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(current)
	..()

/obj/item/device/multitool/field_debug/proc/setup_debug_field()
	var/list/new_params = field_params.Copy()
	new_params["center"] = center
	current = make_field(field_type, new_params)

/obj/item/device/multitool/field_debug/attack_self(mob/user)
	operating = !operating
	to_chat(user, "You turn the [src] [operating? "on":"off"].")
	if(!istype(current) && operating)
		setup_debug_field()
	else if(!operating)
		QDEL_NULL(current)

/obj/item/device/multitool/field_debug/on_mob_move()
	check_turf(get_turf(src))

/obj/item/device/multitool/field_debug/process()
	check_turf(get_turf(src))

/obj/item/device/multitool/field_debug/proc/check_turf(turf/T)
	if(!istype(T) || !istype(current))
		return
	if(T != center)
		center = T
	current.update_center(T)
