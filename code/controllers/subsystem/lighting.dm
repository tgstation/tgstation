GLOBAL_LIST_EMPTY(lighting_update_lights) // List of lighting sources  queued for update.
GLOBAL_LIST_EMPTY(lighting_update_corners) // List of lighting corners  queued for update.
GLOBAL_LIST_EMPTY(lighting_update_objects) // List of lighting objects queued for update.

SUBSYSTEM_DEF(lighting)
	name = "Lighting"
	wait = 2
	init_order = -20
	flags = SS_TICKER

	var/initialized = FALSE

/datum/controller/subsystem/lighting/stat_entry()
	..("L:[GLOB.lighting_update_lights.len]|C:[GLOB.lighting_update_corners.len]|O:[GLOB.lighting_update_objects.len]")


/datum/controller/subsystem/lighting/Initialize(timeofday)
	if (config.starlight)
		for(var/area/A in world)
			if (A.dynamic_lighting == DYNAMIC_LIGHTING_IFSTARLIGHT)
				A.luminosity = 0

	create_all_lighting_objects()
	initialized = TRUE
	
	fire(FALSE, TRUE)

	..()

/datum/controller/subsystem/lighting/fire(resumed, init_tick_checks)
	var/real_tick_limit
	if(!init_tick_checks)
		real_tick_limit = GLOB.CURRENT_TICKLIMIT
		GLOB.CURRENT_TICKLIMIT = ((real_tick_limit - world.tick_usage) / 3) + world.tick_usage
	var/i = 0
	for (i in 1 to GLOB.lighting_update_lights.len)
		var/datum/light_source/L = GLOB.lighting_update_lights[i]

		if (L.check() || QDELETED(L) || L.force_update)
			L.remove_lum()
			if (!QDELETED(L))
				L.apply_lum()

		else if (L.vis_update) //We smartly update only tiles that became (in) visible to use.
			L.smart_vis_update()

		L.vis_update   = FALSE
		L.force_update = FALSE
		L.needs_update = FALSE
		
		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (i)
		GLOB.lighting_update_lights.Cut(1, i+1)
		i = 0

	if(!init_tick_checks)
		GLOB.CURRENT_TICKLIMIT = ((real_tick_limit - world.tick_usage)/2)+world.tick_usage

	for (i in 1 to GLOB.lighting_update_corners.len)
		var/datum/lighting_corner/C = GLOB.lighting_update_corners[i]

		C.update_objects()
		C.needs_update = FALSE
		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (i)
		GLOB.lighting_update_corners.Cut(1, i+1)
		i = 0


	if(!init_tick_checks)
		GLOB.CURRENT_TICKLIMIT = real_tick_limit

	for (i in 1 to GLOB.lighting_update_objects.len)
		var/atom/movable/lighting_object/O = GLOB.lighting_update_objects[i]

		if (QDELETED(O))
			continue

		O.update()
		O.needs_update = FALSE
		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (i)
		GLOB.lighting_update_objects.Cut(1, i+1)


/datum/controller/subsystem/lighting/Recover()
	initialized = SSlighting.initialized
	..()
