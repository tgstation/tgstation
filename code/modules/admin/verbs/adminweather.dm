ADMIN_VERB(run_weather, R_ADMIN|R_FUN, "Run Weather", "Triggers specific weather on the z-level you choose.", ADMIN_CATEGORY_WEATHER)
	var/datum/weather/weather_type = input(user, "Choose a weather", "Weather")  as null|anything in sort_list(subtypesof(/datum/weather), GLOBAL_PROC_REF(cmp_typepaths_asc))
	if(!weather_type)
		return

	var/turf/T = get_turf(user.mob)
	var/z_level = input(user, "Z-Level to target?", "Z-Level", T?.z) as num|null
	if(!isnum(z_level))
		return

	var/area_type
	area_type = input(user, "You can choose a specific area (includes subtypes) if you wish", "Area")  as null|anything in sort_list(subtypesof(/area), GLOBAL_PROC_REF(cmp_typepaths_asc))

	var/weather_bitflags = input_bitfield(
		usr,
		"Weather flags - Select the flags for your weather event",
		"weather_flags",
		weather_type::weather_flags,
	)

	var/reagent_type
	if(ispath(weather_type, /datum/weather/rain_storm))
		reagent_type = input(user, "Choose a reagent for your rain", "Reagent")  as null|anything in sort_list(subtypesof(/datum/reagent), GLOBAL_PROC_REF(cmp_typepaths_asc))
		if(!reagent_type)
			return

	SSweather.run_weather(weather_type, z_level, area_type, weather_bitflags, reagent_type)

	message_admins("[key_name_admin(user)] started weather of type [weather_type] on the z-level [z_level].")
	log_admin("[key_name(user)] started weather of type [weather_type] on the z-level [z_level].")
	BLACKBOX_LOG_ADMIN_VERB("Run Weather")

ADMIN_VERB(stop_weather, R_ADMIN|R_DEBUG, "Stop All Active Weather", "Stop all currently active weather.", ADMIN_CATEGORY_WEATHER)
	log_admin("[key_name(user)] stopped all currently active weather.")
	message_admins("[key_name_admin(user)] stopped all currently active weather.")
	for(var/datum/weather/current_weather as anything in SSweather.processing)
		if(current_weather in SSweather.processing)
			current_weather.end()
	BLACKBOX_LOG_ADMIN_VERB("Stop All Active Weather")
