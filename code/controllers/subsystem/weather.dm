#define STARTUP_STAGE 1
#define MAIN_STAGE 2
#define WIND_DOWN_STAGE 3
#define END_STAGE 4

//Used for all kinds of weather, ex. lavaland ash storms.
SUBSYSTEM_DEF(weather)
	name = "Weather"
	flags = SS_BACKGROUND
	wait = 10
	runlevels = RUNLEVEL_GAME
	var/list/processing = list()
	var/list/eligible_zlevels = list()

/datum/controller/subsystem/weather/fire()
	// process active weather
	for(var/V in processing)
		var/datum/weather/W = V
		if(W.aesthetic || W.stage != MAIN_STAGE)
			continue
		for(var/i in GLOB.mob_living_list)
			var/mob/living/L = i
			if(W.can_weather_act(L))
				W.weather_act(L)

	// start random weather on relevant levels
	for(var/z in eligible_zlevels)
		var/possible_weather = eligible_zlevels[z]
		var/datum/weather/W = pickweight(possible_weather)
		run_weather(W, list(text2num(z)))
		eligible_zlevels -= z
		addtimer(CALLBACK(src, .proc/make_eligible, z, possible_weather), rand(3000, 6000) + initial(W.weather_duration_upper), TIMER_UNIQUE) //Around 5-10 minutes between weathers

/datum/controller/subsystem/weather/Initialize(start_timeofday)
	for(var/V in subtypesof(/datum/weather))
		var/datum/weather/W = V
		var/probability = initial(W.probability)
		var/target_trait = initial(W.target_trait)

		// any weather with a probability set may occur at random
		if (probability)
			for(var/z in SSmapping.levels_by_trait(target_trait))
				LAZYINITLIST(eligible_zlevels["[z]"])
				eligible_zlevels["[z]"][W] = probability
	..()

/datum/controller/subsystem/weather/proc/run_weather(datum/weather/weather_datum_type, z_levels)
	if (istext(weather_datum_type))
		for (var/V in subtypesof(/datum/weather))
			var/datum/weather/W = V
			if (initial(W.name) == weather_datum_type)
				weather_datum_type = V
				break
	if (!ispath(weather_datum_type, /datum/weather))
		CRASH("run_weather called with invalid weather_datum_type: [weather_datum_type || "null"]")
		return

	if (isnull(z_levels))
		z_levels = SSmapping.levels_by_trait(initial(weather_datum_type.target_trait))
	else if (isnum(z_levels))
		z_levels = list(z_levels)
	else if (!islist(z_levels))
		CRASH("run_weather called with invalid z_levels: [z_levels || "null"]")
		return

	var/datum/weather/W = new weather_datum_type(z_levels)
	W.telegraph()

/datum/controller/subsystem/weather/proc/make_eligible(z, possible_weather)
	eligible_zlevels[z] = possible_weather
