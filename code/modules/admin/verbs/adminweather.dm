ADMIN_VERB(run_weather, R_ADMIN|R_FUN, "Run Weather", "Triggers specific weather on the z-level you choose.", ADMIN_CATEGORY_EVENTS)

	var/list/weather_choices = list()
	if(!length(weather_choices))
		for(var/datum/weather/weather_type as anything in subtypesof(/datum/weather))
			weather_choices[initial(weather_type.type)] = weather_type

	var/datum/weather/weather_choice = tgui_input_list(user, "Choose a weather to run", "Weather", weather_choices)
	if(!weather_choice)
		return
	weather_choice = weather_choices[weather_choice]

	var/turf/current_turf = get_turf(user.mob)
	var/z_level = tgui_input_number(user, "Z-Level to target", "Z-Level", min_value = 1, max_value = world.maxz, default = current_turf?.z)
	if(!isnum(z_level))
		return

	var/static/list/custom_options = list("Default", "Custom", "Cancel")
	var/custom_choice = tgui_alert(user, "How would you like to run the weather settings?", "Custom Weather", custom_options)
	switch(custom_choice)
		if("Default")
			SSweather.run_weather(weather_choice, z_level) // default settings
			message_admins("[key_name_admin(user)] started weather of type [weather_choice] on the z-level [z_level].")
			log_admin("[key_name(user)] started weather of type [weather_choice] on the z-level [z_level].")
			BLACKBOX_LOG_ADMIN_VERB("Run Weather")
			return
		if("Cancel")
			return

	var/list/area_choices = list()
	if(!length(area_choices))
		for(var/area/area_type as anything in typesof(/area))
			area_choices[initial(area_type.type)] = area_type

	var/area/area_choice = tgui_input_list(user, "Select an area for weather to target", "Target Area", area_choices)
	if(!area_choice)
		return
	area_choice = area_choices[area_choice]

	var/weather_bitflags = input_bitfield(
		user,
		"Weather flags - Select the flags for your weather event",
		"weather_flags",
		weather_choice::weather_flags,
	)

	var/datum/reagent/reagent_choice
	if((weather_bitflags & (WEATHER_TURFS|WEATHER_MOBS)))
		var/static/list/reagent_options = list("Yes", "No", "Cancel")
		var/reagent_option = tgui_alert(user, "Would you like to make the weather use a custom reagent?", "Weather Reagent", reagent_options)
		switch(reagent_option)
			if("Cancel")
				return
			if("Yes")
				var/static/list/reagent_choices = list()
				if(!length(reagent_choices))
					for(var/datum/reagent/reagent_type as anything in subtypesof(/datum/reagent))
						reagent_choices[initial(reagent_type.type)] = reagent_type

				reagent_choice = tgui_input_list(user, "Select a reagent for the rain", "Rain Reagent", reagent_choices)
				if(!reagent_choice)
					return
				reagent_choice = reagent_choices[reagent_choice]

	var/thunder_value
	if(weather_bitflags & (WEATHER_THUNDER))
		var/static/list/thunder_choices = GLOB.thunder_chance_options

		var/thunder_choice = tgui_input_list(user, "How much thunder would you like", "Thunder", thunder_choices)
		if(!thunder_choice)
			return
		thunder_value = GLOB.thunder_chance_options[thunder_choice]

	var/list/weather_data = list(
		area = area_choice,
		weather_flags = weather_bitflags,
		thunder_chance = thunder_value,
		reagent = reagent_choice,
	)

	SSweather.run_weather(weather_choice, z_level, weather_data)

	message_admins("[key_name_admin(user)] started weather of type [weather_choice] on the z-level [z_level].")
	log_admin("[key_name(user)] started weather of type [weather_choice] on the z-level [z_level].")
	BLACKBOX_LOG_ADMIN_VERB("Run Weather")

ADMIN_VERB(stop_weather, R_ADMIN|R_DEBUG, "Stop All Active Weather", "Stop all currently active weather.", ADMIN_CATEGORY_EVENTS)
	log_admin("[key_name(user)] stopped all currently active weather.")
	message_admins("[key_name_admin(user)] stopped all currently active weather.")
	for(var/datum/weather/current_weather as anything in SSweather.processing)
		if(current_weather in SSweather.processing)
			current_weather.end()
	BLACKBOX_LOG_ADMIN_VERB("Stop All Active Weather")
