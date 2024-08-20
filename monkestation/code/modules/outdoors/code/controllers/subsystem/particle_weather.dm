SUBSYSTEM_DEF(particle_weather)
	name = "Particle Weather"
	flags = SS_BACKGROUND
	wait = 30 SECONDS
	runlevels = RUNLEVEL_GAME
	var/list/elligble_weathers = list()
	var/list/elligble_eclipse_weathers = list()
	var/datum/particle_weather/running_weather
	var/datum/particle_weather/running_eclipse_weather

	var/datum/particle_weather/next_hit
	COOLDOWN_DECLARE(next_weather_start)

	var/datum/particle_weather/next_hit_eclipse
	COOLDOWN_DECLARE(next_weather_start_eclipse)

	var/particles/weather/particle_effect
	var/datum/weather_effect/weather_special_effect
	var/obj/weather_effect/weather_effect

	var/particles/weather/particle_effect_eclipse
	var/datum/weather_effect/weather_special_effect_eclipse
	var/obj/weather_effect/weather_effect_eclipse

	var/enabled = TRUE

/datum/controller/subsystem/particle_weather/stat_entry(msg)
	if(enabled)
		if(running_weather?.running)
			var/time_left = COOLDOWN_TIMELEFT(running_weather, time_left)/10
			var/time_left_eclipse = COOLDOWN_TIMELEFT(running_eclipse_weather, time_left)/10
			if(running_weather?.display_name)
				msg = "P:Current event station: [running_weather.display_name] - [time_left] seconds left, Current event Eclipse: [running_eclipse_weather.display_name] - [time_left_eclipse] seconds left"
			else if(running_weather)
				msg = "P:Current event of unknown type ([running_weather]) - [time_left] seconds left"
		else if(running_weather)
			var/time_left = COOLDOWN_TIMELEFT(src, next_weather_start)
			if(running_weather?.display_name)
				msg = "P:Next event: [running_weather.display_name] hit in [time_left] seconds"
			else if(running_weather)
				msg = "P:Next event of unknown type ([running_weather]) hit in [time_left] seconds"
		else
			msg = "P:No event"
	else
		msg = "Disabled"
	return ..()

/datum/controller/subsystem/particle_weather/fire()
	// process active weather
	if(!running_weather && next_hit && COOLDOWN_FINISHED(src, next_weather_start))
		run_weather(next_hit)

	if(!running_eclipse_weather && next_hit_eclipse && COOLDOWN_FINISHED(src, next_weather_start_eclipse))
		run_weather(next_hit_eclipse, eclipse = TRUE)

	if(!running_weather && !next_hit && length(elligble_weathers))
		for(var/our_event in elligble_weathers)
			if(our_event && prob(elligble_weathers[our_event]))
				next_hit = new our_event()
				COOLDOWN_START(src, next_weather_start, rand(-3000, 3000) + initial(next_hit.weather_duration_upper) / 5)
				break

	if(!running_eclipse_weather && !next_hit_eclipse && length(elligble_eclipse_weathers))
		for(var/our_event in elligble_eclipse_weathers)
			if(our_event && prob(elligble_eclipse_weathers[our_event]))
				next_hit_eclipse = new our_event("Eclipse")
				COOLDOWN_START(src, next_weather_start_eclipse, rand(-3000, 3000) + initial(next_hit_eclipse.weather_duration_upper) / 5)
				break

	if(running_eclipse_weather)
		running_eclipse_weather.tick()

		if(weather_special_effect_eclipse)
			SEND_GLOBAL_SIGNAL(COMSIG_GLOB_WEATHER_EFFECT, weather_special_effect_eclipse)

	if(running_weather)
		running_weather.tick()

		if(weather_special_effect)
			SEND_GLOBAL_SIGNAL(COMSIG_GLOB_WEATHER_EFFECT, weather_special_effect)


//This has been mangled - currently only supports 1 weather effect serverwide so I can finish this
/datum/controller/subsystem/particle_weather/Initialize(start_timeofday)
	if(CONFIG_GET(flag/disable_particle_weather))
		disable()
		return SS_INIT_NO_NEED
	for(var/i in subtypesof(/datum/particle_weather))
		var/datum/particle_weather/particle_weather = new i
		if(particle_weather.target_trait in SSmapping.config.particle_weathers)
			elligble_weathers[i] = particle_weather.probability

		if(particle_weather.eclipse)
			elligble_eclipse_weathers[i] = particle_weather.probability

	return SS_INIT_SUCCESS

/datum/controller/subsystem/particle_weather/proc/disable()
	flags |= SS_NO_FIRE
	enabled = FALSE
	stop_weather()

/datum/controller/subsystem/particle_weather/proc/run_weather(datum/particle_weather/weather_datum_type, force = FALSE, eclipse = FALSE)
	if(!enabled)
		return
	if(eclipse)
		if(running_eclipse_weather)
			if(force)
				running_eclipse_weather.end()
			else
				return

		if(!istype(weather_datum_type, /datum/particle_weather))
			CRASH("run_weather called with invalid weather_datum_type: [weather_datum_type || "null"]")
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_WEATHER_CHANGE)
		running_eclipse_weather = weather_datum_type
		running_eclipse_weather.start()
		weather_datum_type = null
	else
		if(running_weather)
			if(force)
				running_weather.end()
			else
				return

		if(!istype(weather_datum_type, /datum/particle_weather))
			CRASH("run_weather called with invalid weather_datum_type: [weather_datum_type || "null"]")
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_WEATHER_CHANGE)
		running_weather = weather_datum_type
		running_weather.start()
		weather_datum_type = null

/datum/controller/subsystem/particle_weather/proc/make_eligible(datum/particle_weather/possible_weather, probability = 10)
	elligble_weathers[possible_weather] = probability

/datum/controller/subsystem/particle_weather/proc/get_weather_effect(atom/movable/screen/plane_master/weather_effect/W)
	if(W.z_type == "Default")
		if(!weather_effect)
			weather_effect = new /obj()
			weather_effect.particles = particle_effect
			weather_effect.filters += filter(type="alpha", render_source="[WEATHER_RENDER_TARGET] #[W.offset]")
			weather_effect.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		return weather_effect
	else if(W.z_type == "Eclipse")
		if(!weather_effect_eclipse)
			weather_effect_eclipse = new /obj()
			weather_effect_eclipse.filters += filter(type="alpha", render_source="[WEATHER_ECLIPSE_RENDER_TARGET] #[W.offset]")
			weather_effect_eclipse.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		return weather_effect_eclipse

/datum/controller/subsystem/particle_weather/proc/set_particle_effect(particles/P, z_type)
	if(z_type == "Default")
		if(!P || !weather_effect)
			return
		particle_effect = P
		weather_effect.particles = particle_effect
	else if(z_type == "Eclipse")
		if(!P || !weather_effect_eclipse)
			return
		particle_effect_eclipse = P
		weather_effect_eclipse.particles = particle_effect_eclipse

/datum/controller/subsystem/particle_weather/proc/stop_weather(z_type)
	if(z_type == "Default")
		QDEL_NULL(running_weather)
		QDEL_NULL(particle_effect)
		//QDEL_NULL(weather_effect)
		QDEL_NULL(weather_special_effect)
	else if(z_type == "Eclipse")
		QDEL_NULL(running_eclipse_weather)
		QDEL_NULL(particle_effect_eclipse)
		//QDEL_NULL(weather_effect_eclipse)
		QDEL_NULL(weather_special_effect_eclipse)

/obj/weather_effect
	plane = LIGHTING_PLANE
