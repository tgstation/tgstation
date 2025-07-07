//Darude sandstorm starts playing
/datum/weather/sand_storm
	name = "severe sandstorm"
	desc = "A severe dust storm that engulfs an area, dealing intense damage to the unprotected."

	telegraph_message = span_danger("You see a dust cloud rising over the horizon. That can't be good...")
	telegraph_duration = 30 SECONDS
	telegraph_overlay = "dust_med"
	telegraph_sound = 'sound/effects/siren.ogg'

	weather_message = span_userdanger("<i>Hot sand and wind batter you! Get inside!</i>")
	weather_duration_lower = 1 MINUTES
	weather_duration_upper = 2 MINUTES
	weather_overlay = "dust_high"

	end_message = span_bolddanger("The shrieking wind whips away the last of the sand and falls to its usual murmur. It should be safe to go outside now.")
	end_duration = 30 SECONDS
	end_overlay = "dust_med"

	area_type = /area
	target_trait = ZTRAIT_SANDSTORM
	immunity_type = TRAIT_SANDSTORM_IMMUNE
	probability = 90

	weather_flags = (WEATHER_MOBS | WEATHER_BAROMETER)

/datum/weather/sand_storm/telegraph()
	GLOB.sand_storm_sounds.Cut()
	for(var/area/impacted_area as anything in impacted_areas)
		GLOB.sand_storm_sounds[impacted_area] = /datum/looping_sound/weak_outside_ashstorm
	return ..()

/datum/weather/sand_storm/start()
	GLOB.sand_storm_sounds.Cut()
	for(var/area/impacted_area as anything in impacted_areas)
		GLOB.sand_storm_sounds[impacted_area] = /datum/looping_sound/active_outside_ashstorm
	return ..()

/datum/weather/sand_storm/wind_down()
	GLOB.sand_storm_sounds.Cut()
	for(var/area/impacted_area as anything in impacted_areas)
		GLOB.sand_storm_sounds[impacted_area] = /datum/looping_sound/weak_outside_ashstorm
	return ..()

/datum/weather/sand_storm/weather_act_mob(mob/living/victim)
	victim.adjustBruteLoss(5, required_bodytype = BODYTYPE_ORGANIC)
	return ..()

/datum/weather/sand_storm/harmless
	name = "sandfall"
	desc = "A passing sandstorm blankets the area in sand."

	telegraph_message = span_danger("The wind begins to intensify, blowing sand up from the ground...")
	telegraph_overlay = "dust_low"
	telegraph_sound = null

	weather_message = span_notice("Gentle sand wafts down around you like grotesque snow. The storm seems to have passed you by...")
	weather_overlay = "dust_med"

	end_message = span_notice("The sandfall slows, stops. Another layer of sand on the mesa beneath your feet.")
	end_overlay = "dust_low"

	probability = 10
	weather_flags = parent_type::weather_flags & ~WEATHER_MOBS
