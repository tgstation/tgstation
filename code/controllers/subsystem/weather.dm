//Used for all kinds of weather, ex. lavaland ash storms.

var/datum/subsystem/weather/SSweather
/datum/subsystem/weather
	name = "Weather"
	flags = SS_BACKGROUND
	wait = 10
	var/list/processing = list()
	var/list/existing_weather = list()
	var/list/eligible_zlevels = list(ZLEVEL_LAVALAND)

/datum/subsystem/weather/New()
	NEW_SS_GLOBAL(SSweather)
	for(var/V in subtypesof(/datum/weather))
		var/datum/weather/W = V
		existing_weather += new W

/datum/subsystem/weather/fire()
	for(var/datum/weather/W in processing)
		if(W.aesthetic)
			continue
		for(var/mob/living/L in mob_list)
			var/area/A = get_area(L)
			if(L.z == W.target_z && L.weather_immunities & !W.immunity_type && A in W.impacted_areas)
				W.impact(L)
	for(var/Z in eligible_zlevels)
		var/list/possible_weather_for_this_z = list()
		for(var/datum/weather/WE in existing_weather)
			if(WE.target_z == Z && WE.probability) //Another check so that it doesn't run extra weather
				possible_weather_for_this_z[WE] = WE.probability
		var/datum/weather/W = pickweight(possible_weather_for_this_z)
		run_weather(W.name)
		eligible_zlevels -= Z
		addtimer(src, "make_z_eligible", rand(3000, 6000) + W.weather_duration_upper, Z) //Around 5-10 minutes between weathers

/datum/subsystem/weather/proc/run_weather(weather_name)
	if(!weather_name)
		return
	for(var/datum/weather/W in existing_weather)
		if(W.name == weather_name)
			W.telegraph()

/datum/subsystem/weather/proc/make_z_eligible(zlevel)
	eligible_zlevels |= zlevel
