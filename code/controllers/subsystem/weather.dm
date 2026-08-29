/// Used for all kinds of weather, ex. lavaland ash storms.
SUBSYSTEM_DEF(weather)
	name = "Weather"
	ss_flags = SS_BACKGROUND
	dependencies = list(
		/datum/controller/subsystem/mapping,
	)
	wait = 10
	runlevels = RUNLEVEL_GAME
	var/list/processing = list()
	/// Z levels on which weather can occur -> weather that can occur -> probability of said weather occuring
	var/list/eligible_zlevels = list()
	/// Used by barometers to know when the next storm is coming
	var/list/next_hit_by_zlevel = list()
	/// Alist of all particle holders per Z-stack offset for particle weather, each particle holder associated with z-levels it should be displayed on, to be shown to clients
	var/alist/particle_holders = alist()
	/// List of all RENDER_PLANE_PARTICLE_WEATHER and RENDER_PLANE_EMISSIVE_PARTICLE_WEATHER planes
	var/list/particle_planemasters = list()

/datum/controller/subsystem/weather/fire(resumed = FALSE)
	// process active weather
	for(var/datum/weather/weather_event as anything in processing)
		if(!length(weather_event.subsystem_tasks))
			continue

		if(istype(weather_event, /datum/weather/particle))
			var/datum/weather/particle/particle_event = weather_event
			particle_event.process_particles()

		if(weather_event.stage != MAIN_STAGE)
			continue

		if(weather_event.subsystem_tasks[weather_event.task_index] == SSWEATHER_MOBS)
			if(!resumed)
				weather_event.current_mobs = GLOB.mob_living_list.Copy()
			var/list/current_mobs_cache = weather_event.current_mobs // cache for performance
			while(current_mobs_cache.len)
				var/mob/living/target = current_mobs_cache[current_mobs_cache.len]
				current_mobs_cache.len--
				if(QDELETED(target))
					continue
				if(weather_event.can_weather_act_mob(target))
					weather_event.weather_act_mob(target)
				if(MC_TICK_CHECK)
					return
			resumed = FALSE
			weather_event.task_index = WRAP_UP(weather_event.task_index, weather_event.subsystem_tasks.len)

		if(weather_event.subsystem_tasks[weather_event.task_index] == SSWEATHER_TURFS)
			if(!resumed)
				weather_event.turf_iteration = ROUND_PROB(weather_event.weather_turfs_per_tick)
			while(weather_event.turf_iteration)
				weather_event.turf_iteration--
				var/turf/selected_turf = weather_event.pick_turf()
				if(selected_turf && weather_event.can_weather_act_turf(selected_turf))
					weather_event.weather_act_turf(selected_turf)
				if(MC_TICK_CHECK)
					return
			resumed = FALSE
			weather_event.task_index = WRAP_UP(weather_event.task_index, weather_event.subsystem_tasks.len)

		if(weather_event.subsystem_tasks[weather_event.task_index] == SSWEATHER_THUNDER)
			if(!resumed)
				weather_event.thunder_iteration = ROUND_PROB(weather_event.thunder_turfs_per_tick)
			while(weather_event.thunder_iteration)
				weather_event.thunder_iteration--
				var/turf/selected_turf = weather_event.pick_turf()
				if(selected_turf && weather_event.can_weather_act_turf(selected_turf))
					weather_event.thunder_act_turf(selected_turf)
				if(MC_TICK_CHECK)
					return
			resumed = FALSE
			weather_event.task_index = WRAP_UP(weather_event.task_index, weather_event.subsystem_tasks.len)

	// start random weather on relevant levels
	for(var/z in eligible_zlevels)
		var/possible_weather = eligible_zlevels[z]
		var/datum/weather/weather_event = pick_weight(possible_weather)
		run_weather(weather_event, list(text2num(z)))
		eligible_zlevels -= z
		var/randTime = rand(5 MINUTES, 10 MINUTES)
		next_hit_by_zlevel["[z]"] = addtimer(CALLBACK(src, PROC_REF(make_eligible), z, possible_weather), randTime + initial(weather_event.weather_duration_upper), TIMER_UNIQUE|TIMER_STOPPABLE)

/datum/controller/subsystem/weather/Initialize()
	for(var/datum/weather/weather as anything in valid_subtypesof(/datum/weather))
		var/probability = initial(weather.probability)
		var/target_trait = initial(weather.target_trait)

		// any weather with a probability set may occur at random
		if (probability)
			for(var/z in SSmapping.levels_by_trait(target_trait))
				LAZYINITLIST(eligible_zlevels["[z]"])
				eligible_zlevels["[z]"][weather] = probability
	return SS_INIT_SUCCESS

/datum/controller/subsystem/weather/proc/add_weather_objects(list/new_holders, z_level)
	for (var/offset in 1 to length(new_holders))
		var/list/holder_list = new_holders[offset]
		if (isnull(particle_holders[offset]))
			particle_holders[offset] = list()
		particle_holders[offset] += holder_list

		// We add it to vis_contents of planemasters rather than client screen as planemasters already
		// manage their own visibility based on owner's z level
		for (var/atom/movable/screen/plane_master/plane_master as anything in particle_planemasters)
			var/mob/owner = plane_master.home.our_hud?.mymob
			if (!owner) // Vibecheck
				continue
			// Could be caching these per-mob but its basically just a list lookup wrapper
			var/list/stack_levels = SSmapping.get_connected_levels(get_turf(owner.client?.eye || owner))
			for (var/obj/effect/abstract/weather_holder/holder as anything in holder_list)
				if (holder.plane != plane_master.plane)
					continue

				if (!length(holder_list[holder] & stack_levels))
					continue

				plane_master.vis_contents |= holder

/datum/controller/subsystem/weather/proc/remove_weather_objects(list/old_holders)
	for (var/offset in 1 to length(old_holders))
		var/list/holder_list = old_holders[offset]
		particle_holders[offset] -= holder_list

		for (var/atom/movable/screen/plane_master/plane_master as anything in particle_planemasters)
			plane_master.vis_contents -= holder_list

/datum/controller/subsystem/weather/proc/update_z_level(datum/space_level/level)
	var/z = level.z_value
	for(var/datum/weather/weather as anything in valid_subtypesof(/datum/weather))
		var/probability = initial(weather.probability)
		var/target_trait = initial(weather.target_trait)
		if(probability && level.traits[target_trait])
			LAZYINITLIST(eligible_zlevels["[z]"])
			eligible_zlevels["[z]"][weather] = probability

/datum/controller/subsystem/weather/proc/run_weather(datum/weather/weather_datum_type, z_levels, list/weather_data)
	if (istext(weather_datum_type))
		for (var/datum/weather/weather as anything in valid_subtypesof(/datum/weather))
			if (initial(weather.name) == weather_datum_type)
				weather_datum_type = weather
				break
	if (!ispath(weather_datum_type, /datum/weather))
		CRASH("run_weather called with invalid weather_datum_type: [weather_datum_type || "null"]")

	if (isnull(z_levels))
		z_levels = SSmapping.levels_by_trait(initial(weather_datum_type.target_trait))
	else if (isnum(z_levels))
		z_levels = list(z_levels)
	else if (!islist(z_levels))
		CRASH("run_weather called with invalid z_levels: [z_levels || "null"]")

	var/datum/weather/weather = new weather_datum_type(z_levels, weather_data)
	weather.telegraph(weather_data)
	return weather

/datum/controller/subsystem/weather/proc/make_eligible(z, possible_weather)
	eligible_zlevels[z] = possible_weather
	next_hit_by_zlevel["[z]"] = null

/datum/controller/subsystem/weather/proc/get_weather(z, area/active_area)
	var/datum/weather/A
	for(var/V in processing)
		var/datum/weather/W = V
		if((z in W.impacted_z_levels) && W.area_type == active_area.type)
			A = W
			break
	return A

///Returns an active storm by its type
/datum/controller/subsystem/weather/proc/get_weather_by_type(type)
	return locate(type) in processing
