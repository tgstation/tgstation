/datum/weather/rain_storm
	name = "rain"
	desc = "Heavy thunderstorms rain down below, drenching anyone caught in it."

	telegraph_message = span_danger("Thunder rumbles far above. You hear droplets drumming against the canopy.")
	telegraph_overlay = "rain_low"
	telegraph_duration = 30 SECONDS

	weather_message = span_userdanger("<i>Rain pours down around you!</i>")
	weather_overlay = "rain_high"

	end_message = span_bolddanger("The downpour gradually slows to a light shower.")
	end_overlay = "rain_low"
	end_duration = 30 SECONDS

	weather_duration_lower = 3 MINUTES
	weather_duration_upper = 5 MINUTES

	weather_color = null
	thunder_color = null

	area_type = /area
	target_trait = ZTRAIT_RAINSTORM
	immunity_type = TRAIT_RAINSTORM_IMMUNE
	probability = 0
	turf_weather_chance = 0.01
	turf_thunder_chance = THUNDER_CHANCE_AVERAGE

	weather_flags = (WEATHER_TURFS | WEATHER_MOBS | WEATHER_THUNDER | WEATHER_BAROMETER | WEATHER_NOTIFICATION)
	whitelist_weather_reagents = list(/datum/reagent/water)

/datum/weather/rain_storm/telegraph()
	GLOB.rain_storm_sounds.Cut()
	for(var/area/impacted_area as anything in impacted_areas)
		GLOB.rain_storm_sounds[impacted_area] = /datum/looping_sound/rain/start
	return ..()

/datum/weather/rain_storm/start()
	GLOB.rain_storm_sounds.Cut()
	for(var/area/impacted_area as anything in impacted_areas)
		GLOB.rain_storm_sounds[impacted_area] = /datum/looping_sound/rain/middle
	return ..()

/datum/weather/rain_storm/wind_down()
	GLOB.rain_storm_sounds.Cut()
	for(var/area/impacted_area as anything in impacted_areas)
		GLOB.rain_storm_sounds[impacted_area] = /datum/looping_sound/rain/end
	return ..()

/datum/weather/rain_storm/end()
	GLOB.rain_storm_sounds.Cut()
	return ..()

/datum/weather/rain_storm/blood
	whitelist_weather_reagents = list(/datum/reagent/blood)

/datum/weather/rain_storm/plasma
	whitelist_weather_reagents = list(/datum/reagent/toxin/plasma)

/datum/weather/rain_storm/acid
	desc = "The planet's thunderstorms are by nature acidic, and will incinerate anyone standing beneath them without protection."

	telegraph_duration = 40 SECONDS
	telegraph_message = span_warning("Thunder rumbles far above. You hear acidic droplets hissing against the canopy. Seek shelter!")
	telegraph_sound = 'sound/effects/siren.ogg'

	weather_message = span_userdanger("<i>Acidic rain pours down around you! Get inside!</i>")
	weather_duration_lower = 1 MINUTES
	weather_duration_upper = 2 MINUTES

	end_duration = 10 SECONDS
	end_message = span_bolddanger("The downpour gradually slows to a light shower. It should be safe outside now.")

	// these are weighted by acidpwr which causes more damage the higher it is
	whitelist_weather_reagents = list(
		/datum/reagent/toxin/acid/nitracid = 3,
		/datum/reagent/toxin/acid = 2,
		/datum/reagent/toxin/acid/fluacid = 1,
	)

