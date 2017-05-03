
//Movable and easily code-modified fields! Allows for custom AOE effects that affect movement and anything inside of them, and can do custom turf effects!
//Supports automatic recalculation/reset on movement.
//If there's any way to make this less CPU intensive than I've managed, gimme a call or do it yourself! - kevinz000

//Field shapes
#define FIELD_NO_SHAPE 0		//Does not update turfs automatically
#define FIELD_SHAPE_RADIUS_SQUARE 1	//Uses square_radius and square_depth_up/down
#define FIELD_SHAPE_CUSTOM_SQUARE 2	//Uses square_height and square_width and square_depth_up/down

//Proc to make fields. make_field(field_type, field_params_in_associative_list)
/proc/make_field(field_type, list/field_params, override_checks = FALSE, start_field = TRUE)
	var/datum/field/F = new field_type()
	if(!F.assume_params(field_params) && !override_checks)
		world << "DEBUG: Field failed to properly assume params"
		QDEL_NULL(F)
	if(!F.check_variables() && !override_checks)
		QDEL_NULL(F)
		world << "DEBUG: Field failed variables check"
	if(start_field && (F || override_checks))
		F.Initialize()
	return F

/datum/field
	var/turf/center = null
	var/last_x = 0
	var/last_y = 0
	var/last_z = 0
	//Field setup specifications
	var/field_shape = FIELD_NO_SHAPE
	var/square_radius = 0
	var/square_height = 0
	var/square_width = 0
	var/square_depth_up = 0
	var/square_depth_down = 0
	//Processing
	var/requires_processing = FALSE
	var/process_inner_turfs = FALSE	//Don't do this unless it's absolutely necessary
	var/process_edge_turfs = FALSE	//Don't do this either unless it's absolutely necessary, you can just track what things are inside manually or on the initial setup.
	var/setup_edge_turfs = FALSE	//Setup edge turfs/all field turfs. Set either or both to ON when you need it, it's defaulting to off unless you do to save CPU.
	var/setup_field_turfs = FALSE

	var/list/turf/field_turfs = list()
	var/list/turf/edge_turfs = list()
	var/list/turf/field_turfs_new = list()
	var/list/turf/edge_turfs_new = list()

/datum/field/New()
	SSfields.register_new_field(src)
	..()

/datum/field/Destroy()
	SSfields.unregister_field(src)
	full_cleanup()
	..()

/datum/field/proc/assume_params(list/field_params)
	var/pass_check = TRUE
	for(var/param in field_params)
		world << "DEBUG: Attempting to set var [param] to [field_params[param]]"
		if(vars[param] || isnull(vars[param]) || (param in vars))
			vars[param] = field_params[param]
			world << "DEBUG: vars [param] being set to [field_params[param]]"
		else
			pass_check = FALSE
			world << "DEBUG: [param] not in vars!"
	return pass_check

/datum/field/proc/check_variables()
	var/pass = TRUE
	if(field_shape == FIELD_NO_SHAPE)	//If you're going to make a manually updated field you shouldn't be using automatic checks so don't.
		pass = FALSE
		world << "DEBUG: Field has no shape"
	if(square_radius < 0 || square_height < 0 || square_width < 0 || square_depth_up < 0 || square_depth_down < 0)
		pass = FALSE
		world << "DEBUG: Field radius error"
	if(!istype(center))
		pass = FALSE
		world << "DEBUG: No center of field!"
	return pass

/datum/field/process()
	if(process_inner_turfs)
		for(var/turf/T in field_turfs)
			process_inner_turf(T)
			CHECK_TICK		//Really crappy lagchecks, needs improvement once someone starts using processed fields.
	if(process_edge_turfs)
		for(var/turf/T in edge_turfs)
			process_edge_turf(T)
			CHECK_TICK	//Same here.

/datum/field/proc/process_inner_turf(turf/T)
	return

/datum/field/proc/process_edge_turf(turf/T)
	return

/datum/field/proc/Initialize()
	setup_field()
	post_setup_field()

/datum/field/proc/full_cleanup()	 //Full cleanup for when you change something that would require complete resetting.
	for(var/turf/T in edge_turfs)
		cleanup_edge_turf(T)
	edge_turfs = list()
	for(var/turf/T in field_turfs)
		cleanup_field_turf(T)
	field_turfs = list()
	edge_turfs_new = list()
	field_turfs = list()

/datum/field/proc/recalculate_field(ignore_movement_check = FALSE)	//Call every time the field moves (done automatically if you use update_center) or a setup specification is changed.
	if(!(ignore_movement_check || ((last_x != center.x || last_y != center.y || last_z != center.z) && (field_shape != FIELD_NO_SHAPE))))
		return
	update_new_turfs()
	var/list/turf/needs_setup = field_turfs_new.Copy()
	if(setup_field_turfs)
		for(var/turf/T in field_turfs)
			if(!(T in field_turfs_new))
				cleanup_field_turf(T)
				field_turfs -= T
			else
				needs_setup -= T
		for(var/turf/T in needs_setup)
			setup_field_turf(T)
			field_turfs += T
	if(setup_edge_turfs)
		for(var/turf/T in edge_turfs)
			cleanup_edge_turf(T)
			edge_turfs -= T
		for(var/turf/T in edge_turfs_new)
			setup_edge_turf(T)
			edge_turfs += T

/datum/field/proc/on_move_field_turf(atom/movable/AM, turf/entering, atom/exiting)	//Exiting is an atom because turfs allow for all atoms to be "forget"/oldturf.
	return TRUE	//Return FALSE to prevent movement.

/datum/field/proc/on_move_edge_turf(atom/movable/AM, turf/entering, atom/exiting)
	return TRUE	//Return FALSE to prevent movement.

/datum/field/proc/update_center(turf/T, recalculate_field = TRUE)
	center = T
	if(recalculate_field)
		recalculate_field()

/datum/field/proc/post_setup_field()
	return

/datum/field/proc/setup_field()
	update_new_turfs()
	if(setup_field_turfs)
		for(var/turf/T in field_turfs_new)
			setup_field_turf(T)
			field_turfs |= T
			CHECK_TICK
	if(setup_edge_turfs)
		for(var/turf/T in edge_turfs_new)
			setup_edge_turf(T)
			edge_turfs |= T
			CHECK_TICK

/datum/field/proc/cleanup_field_turf(turf/T)
	T.fields -= src
	return

/datum/field/proc/cleanup_edge_turf(turf/T)
	T.field_edges -= src
	return

/datum/field/proc/setup_field_turf(turf/T)
	if(src in T.fields)
		world << "DEBUG: [src] ALREADY IN [T] FIELDS!"
	T.fields += src
	return

/datum/field/proc/setup_edge_turf(turf/T)
	if(src in T.field_edges)
		world << "DEBUG: [src] ALREADY IN [T] FIELD EDGES!"
	T.field_edges += src
	return

/datum/field/proc/update_new_turfs()
	if(!istype(center))
		return FALSE
	last_x = center.x
	last_y = center.y
	last_z = center.z
	field_turfs_new = list()
	edge_turfs_new = list()
	switch(field_shape)
		if(FIELD_NO_SHAPE)
			return FALSE
		if(FIELD_SHAPE_RADIUS_SQUARE)
			for(var/turf/T in block(locate(center.x-square_radius,center.y-square_radius,center.z-square_depth_down),locate(center.x+square_radius, center.y+square_radius,center.z+square_depth_up)))
				field_turfs_new += T
			edge_turfs_new = field_turfs_new.Copy()
			if(square_radius >= 1)
				var/list/turf/center_turfs = list()
				for(var/turf/T in block(locate(center.x-square_radius+1,center.y-square_radius+1,center.z-square_depth_down),locate(center.x+square_radius-1, center.y+square_radius-1,center.z+square_depth_up)))
					center_turfs += T
				for(var/turf/T in center_turfs)
					edge_turfs_new -= T
		if(FIELD_SHAPE_CUSTOM_SQUARE)
			for(var/turf/T in block(locate(center.x-square_width,center.y-square_height,center.z-square_depth_down),locate(center.x+square_width, center.y+square_height,center.z+square_depth_up)))
				field_turfs_new += T
			edge_turfs_new = field_turfs_new.Copy()
			if(square_height >= 1 && square_width >= 1)
				var/list/turf/center_turfs = list()
				for(var/turf/T in block(locate(center.x-square_width+1,center.y-square_height+1,center.z-square_depth_down),locate(center.x+square_width-1, center.y+square_height-1,center.z+square_depth_up)))
					center_turfs += T
				for(var/turf/T in center_turfs)
					edge_turfs_new -= T

//DEBUG FIELDS
/datum/field/debug
	field_shape = FIELD_SHAPE_RADIUS_SQUARE
	square_radius = 5
	var/set_fieldturf_color = "#aaffff"
	var/set_edgeturf_color = "#ffaaff"
	setup_field_turfs = TRUE

/datum/field/debug/setup_edge_turf(turf/T)
	T.color = set_edgeturf_color
	..()

/datum/field/debug/cleanup_edge_turf(turf/T)
	T.color = initial(T.color)
	..()

/datum/field/debug/setup_field_turf(turf/T)
	T.color = set_fieldturf_color
	..()

/datum/field/debug/cleanup_field_turf(turf/T)
	T.color = initial(T.color)
	..()

//DEBUG FIELD ITEM
/obj/item/device/multitool/field_debug
	name = "strange multitool"
	desc = "Seems to project a colored field!"
	var/list/field_params = list("field_shape" = FIELD_SHAPE_RADIUS_SQUARE, "square_radius" = 5, "set_fieldturf_color" = "#aaffff", "set_edgeturf_color" = "#ffaaff")
	var/field_type = /datum/field/debug
	var/operating = FALSE
	var/datum/field/current = null
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
