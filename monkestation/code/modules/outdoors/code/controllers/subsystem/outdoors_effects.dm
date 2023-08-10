//TODO: Change verbiage to outdoor_effects rather than sunlight
/datum/time_of_day
	var/name = ""
	var/color = ""
	var/start = 216000 // 6:00 am


// /datum/time_of_day/Midnight_am
//  name = "Midnight AM"
//  color = "#050d29"
//  start = "0" //12:00:00 AM

/datum/time_of_day/dawn
 name = "Dawn"
 color = "#31211b"
 start = 4 HOURS //4:00:00 AM

/datum/time_of_day/sunrise
 name = "Sunrise"
 color = "#F598AB"
 start = 5 HOURS  //5:00:00 AM

/datum/time_of_day/daytime
 name = "Daytime"
 color = "#FFFFFF"
 start = 5.5 HOURS //5:30:00 AM

/datum/time_of_day/sunset
 name = "Sunset"
 color = "#ff8a63"
 start = 19 HOURS //7:00:00 PM

/datum/time_of_day/dusk
 name = "Dusk"
 color = "#221f33"
 start = 19.5 HOURS //7:30:00 PM

/datum/time_of_day/midnight
 name = "Midnight"
 color = "#000032"
 start = 20 HOURS //8:00:00 PM


GLOBAL_VAR_INIT(GLOBAL_LIGHT_RANGE, 5)
GLOBAL_LIST_EMPTY(SUNLIGHT_QUEUE_WORK)   /* turfs to be stateChecked */
GLOBAL_LIST_EMPTY(SUNLIGHT_QUEUE_UPDATE) /* turfs to have their colors updated via corners (filter out the unroofed dudes) */
GLOBAL_LIST_EMPTY(SUNLIGHT_QUEUE_CORNER) /* turfs to have their color/lights/etc updated */

SUBSYSTEM_DEF(outdoor_effects)
	name = "Sunlight Visuals"
	wait = LIGHTING_INTERVAL
	flags = SS_TICKER
	init_order = INIT_ORDER_OUTDOOR_EFFECTS

	var/list/atom/movable/screen/fullscreen/lighting_backdrop/sunlight/sunlighting_planes = list()
	var/datum/time_of_day/current_step_datum
	var/datum/time_of_day/next_step_datum
	var/list/mutable_appearance/sunlight_overlays
	var/list/atom/movable/screen/plane_master/weather_effect/weather_planes_need_vis = list()
	var/last_color = null
	//Ensure midnight is the liast step
	var/list/datum/time_of_day/time_cycle_steps = list(new /datum/time_of_day/dawn(),
	                                                   new /datum/time_of_day/sunrise(),
	                                                   new /datum/time_of_day/daytime(),
	                                                   new /datum/time_of_day/sunset(),
	                                                   new /datum/time_of_day/dusk(),
	                                                   new /datum/time_of_day/midnight())



/datum/controller/subsystem/outdoor_effects/stat_entry(msg)
	msg = "W:[GLOB.SUNLIGHT_QUEUE_WORK.len]|U:[GLOB.SUNLIGHT_QUEUE_UPDATE.len]|C:[GLOB.SUNLIGHT_QUEUE_CORNER.len]"
	return ..()

/datum/controller/subsystem/outdoor_effects/proc/fullPlonk()
	for (var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		for (var/turf/T in block(locate(1,1,z), locate(world.maxx,world.maxy,z)))
			var/area/TArea = T.loc
			if (TArea.static_lighting)
				GLOB.SUNLIGHT_QUEUE_WORK += T

/datum/controller/subsystem/outdoor_effects/Initialize(timeofday)
	if(!initialized)
		get_time_of_day()
		InitializeTurfs()
		initialized = TRUE
	fire(FALSE, TRUE)
	..()

/datum/controller/subsystem/outdoor_effects/proc/InitializeTurfs(list/targets)
	for (var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		for (var/turf/T in block(locate(1,1,z), locate(world.maxx,world.maxy,z)))
			var/area/TArea = T.loc
			if (TArea.static_lighting)
				GLOB.SUNLIGHT_QUEUE_WORK += T


/datum/controller/subsystem/outdoor_effects/proc/check_cycle()
	if(station_time() > next_step_datum.start)
		get_time_of_day()
		return TRUE
	return FALSE

/datum/controller/subsystem/outdoor_effects/proc/get_time_of_day()

	//Set our current color as last_color so newly initialized sunlight screens have a color
	if(current_step_datum)
		last_color = current_step_datum.color

	//Get the next time step (first time where NOW > START_TIME)
	//If we don't find one - grab the LAST time step (which should be midnight)
	var/time = station_time()
	var/datum/time_of_day/new_step = null

	for(var/i in 1 to length(time_cycle_steps))
		if(time >= time_cycle_steps[i].start)
			new_step = time_cycle_steps[i]
			next_step_datum = i == length(time_cycle_steps) ? time_cycle_steps[1] : time_cycle_steps[i + 1]

	//New time is the last time step in list (midnight) - next time will be the first step
	if(!new_step)
		new_step = time_cycle_steps[length(time_cycle_steps)]
		next_step_datum = time_cycle_steps[1]

	current_step_datum = new_step

	//If it is round-start, we wouldn't have had a current_step_datum, so set our last_color to the current one
	if(!last_color)
		last_color = current_step_datum.color

/* set sunlight color + add weather effect to clients */
/datum/controller/subsystem/outdoor_effects/fire(resumed, init_tick_checks)
	MC_SPLIT_TICK_INIT(3)
	if(!init_tick_checks)
		MC_SPLIT_TICK
	var/i = 0

	//Add our weather particle obj to any new weather screens
	if(SSparticle_weather.initialized)
		for (i in 1 to weather_planes_need_vis.len)
			var/atom/movable/screen/plane_master/weather_effect/W = weather_planes_need_vis[i]
			if(W)
				W.vis_contents = list(SSparticle_weather.get_weather_effect(W))
			if(init_tick_checks)
				CHECK_TICK
			else if (MC_TICK_CHECK)
				break
		if (i)
			weather_planes_need_vis.Cut(1, i+1)
			i = 0

	for (i in 1 to GLOB.SUNLIGHT_QUEUE_WORK.len)
		var/turf/T = GLOB.SUNLIGHT_QUEUE_WORK[i]
		if(T)
			T.get_sky_and_weather_states()
			if(T.outdoor_effect)
				GLOB.SUNLIGHT_QUEUE_UPDATE += T.outdoor_effect

		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (i)
		GLOB.SUNLIGHT_QUEUE_WORK.Cut(1, i+1)
		i = 0


	if(!init_tick_checks)
		MC_SPLIT_TICK

	for (i in 1 to GLOB.SUNLIGHT_QUEUE_UPDATE.len)
		var/atom/movable/outdoor_effect/U = GLOB.SUNLIGHT_QUEUE_UPDATE[i]
		if(U)
			U.process_state()
			update_outdoor_effect_overlays(U)

		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if (i)
		GLOB.SUNLIGHT_QUEUE_UPDATE.Cut(1, i+1)
		i = 0


	if(!init_tick_checks)
		MC_SPLIT_TICK

	for (i in 1 to GLOB.SUNLIGHT_QUEUE_CORNER.len)
		var/turf/T = GLOB.SUNLIGHT_QUEUE_CORNER[i]
		var/atom/movable/outdoor_effect/U = T.outdoor_effect

		/* if we haven't initialized but we are affected, create new and check state */
		if(!U)
			T.outdoor_effect = new /atom/movable/outdoor_effect(T)
			T.get_sky_and_weather_states()
			U = T.outdoor_effect

			/* in case we aren't indoor somehow, wack us into the proc queue, we will be skipped on next indoor check */
			if(U.state != SKY_BLOCKED)
				GLOB.SUNLIGHT_QUEUE_UPDATE += T.outdoor_effect

		if(U.state != SKY_BLOCKED)
			continue

		//This might need to be run more liberally
		update_outdoor_effect_overlays(U)


		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break

	if (i)
		GLOB.SUNLIGHT_QUEUE_CORNER.Cut(1, i+1)
		i = 0

	if(check_cycle())
		for (var/atom/movable/screen/fullscreen/lighting_backdrop/sunlight/SP in sunlighting_planes)
			transition_sunlight_color(SP)


//Transition from our last color to our current color (i.e if it is going from daylight (white) to sunset (red), we transition to red in the first hour of sunset)
/datum/controller/subsystem/outdoor_effects/proc/transition_sunlight_color(atom/movable/screen/fullscreen/lighting_backdrop/sunlight/SP)
	/* transistion in an hour or time diff from now to our next step, whichever is smaller */
	var timeDiff = min((1 HOURS / SSticker.station_time_rate_multiplier ),daytimeDiff(station_time(), next_step_datum.start))
	animate(SP,color=current_step_datum.color, time = timeDiff)

// Updates overlays and vis_contents for outdoor effects
/datum/controller/subsystem/outdoor_effects/proc/update_outdoor_effect_overlays(atom/movable/outdoor_effect/OE)
	if(!SSmapping.level_trait(OE.z, ZTRAIT_DAYCYCLE))
		OE.overlays = OE.weatherproof ? list() : list(get_weather_overlay())
	else
		var/mutable_appearance/MA
		if (OE.state != SKY_BLOCKED)
			MA = get_sunlight_overlay(1,1,1,1) /* fully lit */
		else //Indoor - do proper corner checks
			/* check if we are globally affected or not */
			var/static/datum/lighting_corner/dummy/dummy_lighting_corner = new

			var/datum/lighting_corner/cr = OE.source_turf.lighting_corner_SW || dummy_lighting_corner
			var/datum/lighting_corner/cg = OE.source_turf.lighting_corner_SE || dummy_lighting_corner
			var/datum/lighting_corner/cb = OE.source_turf.lighting_corner_NW || dummy_lighting_corner
			var/datum/lighting_corner/ca = OE.source_turf.lighting_corner_NE || dummy_lighting_corner

			var/fr = cr.sun_falloff
			var/fg = cg.sun_falloff
			var/fb = cb.sun_falloff
			var/fa = ca.sun_falloff

			MA = get_sunlight_overlay(fr, fg, fb, fa)

		OE.sunlight_overlay = MA
		//Get weather overlay if not weatherproof
		OE.overlays = OE.weatherproof ? list(OE.sunlight_overlay) : list(OE.sunlight_overlay, get_weather_overlay())
		OE.luminosity = MA.luminosity

//Retrieve an overlay from the list - create if necessary
/datum/controller/subsystem/outdoor_effects/proc/get_sunlight_overlay(fr, fg, fb, fa)

	var/index = "[fr]|[fg]|[fb]|[fa]"
	LAZYINITLIST(sunlight_overlays)
	if(!sunlight_overlays[index])
		sunlight_overlays[index] = create_sunlight_overlay(fr, fg, fb, fa)
	return sunlight_overlays[index]

//get our weather overlay
/datum/controller/subsystem/outdoor_effects/proc/get_weather_overlay()
	var/mutable_appearance/MA = new /mutable_appearance()
	MA.blend_mode   	  = BLEND_OVERLAY
	MA.icon 			  = 'monkestation/code/modules/outdoors/icons/effects/weather_overlay.dmi'
	MA.icon_state 		  = "weather_overlay"
	MA.plane			  = WEATHER_OVERLAY_PLANE /* we put this on a lower level than lighting so we dont multiply anything */
	MA.invisibility 	  = INVISIBILITY_LIGHTING
	return MA

//Create an overlay appearance from corner values
/datum/controller/subsystem/outdoor_effects/proc/create_sunlight_overlay(fr, fg, fb, fa)

	var/mutable_appearance/MA = new /mutable_appearance()

	MA.blend_mode   = BLEND_OVERLAY
	MA.icon		 = LIGHTING_ICON
	MA.icon_state   = null
	MA.plane		= SUNLIGHTING_PLANE /* we put this on a lower level than lighting so we dont multiply anything */
	MA.invisibility = INVISIBILITY_LIGHTING


	//MA gets applied as an overlay, but we pull luminosity out to set our outdoor_effect object's lum
	#if LIGHTING_SOFT_THRESHOLD != 0
	MA.luminosity = max(fr, fg, fb, fa) > LIGHTING_SOFT_THRESHOLD
	#else
	MA.luminosity = max(fr, fg, fb, fa) > 1e-6
	#endif

	if((fr & fg & fb & fa) && (fr + fg + fb + fa == 4)) /* this will likely never happen */
		MA.color = LIGHTING_BASE_MATRIX
	else if(!MA.luminosity)
		MA.color = SUNLIGHT_DARK_MATRIX
	else
		MA.color = list(
					fr, fr, fr,  00 ,
					fg, fg, fg,  00 ,
					fb, fb, fb,  00 ,
					fa, fa, fa,  00 ,
					00, 00, 00,  01 )
	return MA
