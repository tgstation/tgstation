// global datum that will preload variables on atoms instanciation
GLOBAL_VAR_INIT(use_preloader, FALSE)
GLOBAL_DATUM_INIT(_preloader, /datum/map_preloader, new)

/// Preloader datum
/datum/map_preloader
	parent_type = /datum
	var/list/attributes
	var/target_path
	var/turn_angle
	var/swap_x
	var/swap_y
	var/swap_xy

/world/proc/preloader_setup(list/the_attributes, path, turn_angle, swap_x, swap_y, swap_xy)
	if(length(the_attributes) || turn_angle)
		GLOB.use_preloader = TRUE
		var/datum/map_preloader/preloader_local = GLOB._preloader
		preloader_local.attributes = the_attributes
		preloader_local.target_path = path
		preloader_local.turn_angle = turn_angle
		preloader_local.swap_x = swap_x
		preloader_local.swap_y = swap_y
		preloader_local.swap_xy = swap_xy

/world/proc/preloader_load(atom/what)
	GLOB.use_preloader = FALSE
	var/datum/map_preloader/preloader_local = GLOB._preloader
	for(var/attribute in preloader_local.attributes)
		var/value = preloader_local.attributes[attribute]
		if(islist(value))
			value = deepCopyList(value)
		#ifdef TESTING
		if(what.vars[attribute] == value)
			var/message = "<font color=green>[what.type]</font> at [AREACOORD(what)] - <b>VAR:</b> <font color=red>[attribute] = [isnull(value) ? "null" : (isnum(value) ? value : "\"[value]\"")]</font>"
			log_mapping("DIRTY VAR: [message]")
			GLOB.dirty_vars += message
		#endif
		what.vars[attribute] = value
	// handle post processing, so things like directions on subtypes don't break.
	if(preloader_local.turn_angle)		//safe way to check for if this is necessary
		what.dir = turn(what.dir, preloader_local.turn_angle)
		var/px = what.pixel_x
		var/py = what.pixel_y
		if(preloader_local.swap_y)			//same order of operations as the load rotation, mirror and then x/y swapping.
			py = -py
		if(preloader_local.swap_x)
			px = -px
		if(preloader_local.swap_xy)
			var/opx = px
			px = py
			py = opx
		what.pixel_x = px
		what.pixel_y = py

/area/template_noop
	name = "Area Passthrough"

/turf/template_noop
	name = "Turf Passthrough"
	icon_state = "noop"
	bullet_bounce_sound = null
