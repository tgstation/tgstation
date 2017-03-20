var/datum/controller/subsystem/lighting/SSlighting

var/list/lighting_update_lights    = list() // List of lighting sources  queued for update.
var/list/lighting_update_corners   = list() // List of lighting corners  queued for update.
var/list/lighting_update_objects  = list() // List of lighting objects queued for update.


/datum/controller/subsystem/lighting
	name = "Lighting"
	wait = 2
	init_order = -20
	flags = SS_TICKER

	var/initialized = FALSE


/datum/controller/subsystem/lighting/New()
	NEW_SS_GLOBAL(SSlighting)


/datum/controller/subsystem/lighting/stat_entry()
	..("L:[lighting_update_lights.len]|C:[lighting_update_corners.len]|O:[lighting_update_objects.len]")


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
		real_tick_limit = CURRENT_TICKLIMIT
		CURRENT_TICKLIMIT = ((real_tick_limit - world.tick_usage) / 3) + world.tick_usage
	var/i = 0
	for (i in 1 to lighting_update_lights.len)
		var/datum/light_source/L = lighting_update_lights[i]

		if (L.check() || L.destroyed || L.force_update)
			L.remove_lum()
			if (!L.destroyed)
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
		lighting_update_lights.Cut(1, i+1)
		i = 0

	if(!init_tick_checks)
		CURRENT_TICKLIMIT = ((real_tick_limit - world.tick_usage)/2)+world.tick_usage

	for (i in 1 to lighting_update_corners.len)
		var/datum/lighting_corner/C = lighting_update_corners[i]

		C.update_objects()
		C.needs_update = FALSE
		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (i)
		lighting_update_corners.Cut(1, i+1)
		i = 0


	if(!init_tick_checks)
		CURRENT_TICKLIMIT = real_tick_limit

	for (i in 1 to lighting_update_objects.len)
		var/atom/movable/lighting_object/O = lighting_update_objects[i]

		if (QDELETED(O))
			continue

		O.update()
		O.needs_update = FALSE
		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (i)
		lighting_update_objects.Cut(1, i+1)


/datum/controller/subsystem/lighting/Recover()
	initialized = SSlighting.initialized
	..()
