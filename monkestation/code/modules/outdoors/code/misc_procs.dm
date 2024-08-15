/mob/living/carbon/proc/handle_weather(delta_time = 1)
	var/turf/turf = get_turf(src)
	if(QDELETED(turf))
		return
	if(SSmapping.level_has_all_traits(turf.z, list(ZTRAIT_ECLIPSE)) && SSparticle_weather.running_eclipse_weather)
		if(!SSparticle_weather.running_eclipse_weather || !(turf.turf_flags & TURF_WEATHER))
			current_weather_effect_type = null
		else
			current_weather_effect_type = SSparticle_weather.running_eclipse_weather
		SSparticle_weather.running_eclipse_weather.process_mob_effect(src, delta_time)
	else if(SSparticle_weather.running_weather)
		// Check if we're supposed to be something affected by weather
		if(!SSparticle_weather.running_weather || !(turf.turf_flags & TURF_WEATHER))
			current_weather_effect_type = null
		else
			current_weather_effect_type = SSparticle_weather.running_weather
		SSparticle_weather.running_weather.process_mob_effect(src, delta_time)

/// Play sound for all on-map clients on a given Z-level. Good for ambient sounds.
/proc/playsound_z(z, soundin, volume = 100, _mixer_channel)
	var/sound/S = sound(soundin)
	for(var/mob/M in GLOB.player_list)
		if(M.z in z)
			M.playsound_local(get_turf(M), soundin, volume, channel = CHANNEL_Z, soundin = S, mixer_channel = _mixer_channel)
