/turf
	var/weather_affectable = TRUE
/datum/particle_weather/snow_gentle
	name = "Snow"
	display_name = "Snow"
	desc = "Light snowfall."
	particle_effect_type = /particles/weather/snow

	scale_vol_with_severity = TRUE
	weather_sounds = list(/datum/looping_sound/snow)
	weather_messages = list("It's snowing!", "You feel a chill")

	damage_type = BURN
	damage_per_tick = 0.1
	min_severity = 1
	max_severity = 10
	max_severity_change = 5
	severity_steps = 5
	immunity_type = TRAIT_SNOWSTORM_IMMUNE
	probability = 1
	target_trait = PARTICLEWEATHER_SNOW

	weather_additional_events = list("wind" = list(5, /datum/weather_event/wind))

/datum/particle_weather/snow_storm
	name = "Snowstorm"
	display_name = "Snowstorm"
	desc = "Intense snowstorm that impairs vision."
	particle_effect_type = /particles/weather/snowstorm

	scale_vol_with_severity = TRUE
	weather_sounds = list(/datum/looping_sound/snow)
	weather_messages = list("You feel a chill", "The cold wind is freezing you to the bone", "How can a man who is warm, understand a man who is cold?")

	damage_type = BURN
	damage_per_tick = 0.5
	min_severity = 40
	max_severity = 100
	max_severity_change = 60
	severity_steps = 10
	immunity_type = TRAIT_SNOWSTORM_IMMUNE
	probability = 1
	target_trait = PARTICLEWEATHER_SNOW

	weather_additional_events = list("wind" = list(10, /datum/weather_event/wind))
	weather_warnings = list("siren" = "WARNING. A POTENTIALLY DANGEROUS WEATHER ANOMALY HAS BEEN DETECTED. SEEK SHELTER IMMEDIATELY", "message" = TRUE)
	fire_smothering_strength = 4

//Makes you a lot little chilly
/datum/particle_weather/snow_storm/affect_mob_effect(mob/living/L, delta_time, calculated_damage)
	. = ..()
	if(ishuman(L))
		L.adjust_eye_blur(5)
