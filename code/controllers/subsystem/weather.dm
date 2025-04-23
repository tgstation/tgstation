/// Used for all kinds of weather, ex. lavaland ash storms.
SUBSYSTEM_DEF(weather)
	name = "Weather"
	flags = SS_BACKGROUND
	dependencies = list(
		/datum/controller/subsystem/mapping,
	)
	wait = 10
	runlevels = RUNLEVEL_GAME
	var/list/processing = list()
	var/list/eligible_zlevels = list()
	var/list/next_hit_by_zlevel = list() //Used by barometers to know when the next storm is coming

/datum/controller/subsystem/weather/fire(resumed = FALSE)
	// process active weather
	for(var/datum/weather/weather_event as anything in processing)
		if(!length(weather_event.subsystem_tasks) || weather_event.stage != MAIN_STAGE)
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
	for(var/V in subtypesof(/datum/weather))
		var/datum/weather/W = V
		var/probability = initial(W.probability)
		var/target_trait = initial(W.target_trait)

		// any weather with a probability set may occur at random
		if (probability)
			for(var/z in SSmapping.levels_by_trait(target_trait))
				LAZYINITLIST(eligible_zlevels["[z]"])
				eligible_zlevels["[z]"][W] = probability
	return SS_INIT_SUCCESS

/datum/controller/subsystem/weather/proc/update_z_level(datum/space_level/level)
	var/z = level.z_value
	for(var/datum/weather/weather as anything in subtypesof(/datum/weather))
		var/probability = initial(weather.probability)
		var/target_trait = initial(weather.target_trait)
		if(probability && level.traits[target_trait])
			LAZYINITLIST(eligible_zlevels["[z]"])
			eligible_zlevels["[z]"][weather] = probability

/datum/controller/subsystem/weather/proc/run_weather(datum/weather/weather_datum_type, z_levels, list/weather_data)
	if (istext(weather_datum_type))
		for (var/V in subtypesof(/datum/weather))
			var/datum/weather/W = V
			if (initial(W.name) == weather_datum_type)
				weather_datum_type = V
				break
	if (!ispath(weather_datum_type, /datum/weather))
		CRASH("run_weather called with invalid weather_datum_type: [weather_datum_type || "null"]")

	if (isnull(z_levels))
		z_levels = SSmapping.levels_by_trait(initial(weather_datum_type.target_trait))
	else if (isnum(z_levels))
		z_levels = list(z_levels)
	else if (!islist(z_levels))
		CRASH("run_weather called with invalid z_levels: [z_levels || "null"]")


	var/datum/weather/W = new weather_datum_type(z_levels, weather_data)
	W.telegraph()

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
