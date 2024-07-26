/datum/particle_weather/rain_gentle
	name = "Rain"
	display_name = "Rain"
	desc = "Gentle Rain, la la description."
	particle_effect_type = /particles/weather/rain

	scale_vol_with_severity = TRUE
	weather_sounds = list(/datum/looping_sound/rain)
	indoor_weather_sounds = list(/datum/looping_sound/indoor_rain)
	weather_messages = list("The rain cools your skin.", "The rain bluring your eyes.")

	damage_type = TOX
	min_severity = 1
	max_severity = 10
	max_severity_change = 5
	severity_steps = 5
	//immunity_type = TRAIT_RAINSTORM_IMMUNE
	probability = 1
	target_trait = PARTICLEWEATHER_RAIN

	weather_additional_events = list("thunder" = list(3, /datum/weather_event/thunder), "wind" = list(4, /datum/weather_event/wind))
	weather_warnings = list("siren" = null, "message" = FALSE)
	fire_smothering_strength = 6
	eclipse = TRUE

/datum/particle_weather/rain_storm
	name = "Rain Storm"
	display_name = "Rain Storm"
	desc = "Intense rain."
	particle_effect_type = /particles/weather/rain/storm

	scale_vol_with_severity = TRUE
	weather_sounds = list(/datum/looping_sound/rain)
	indoor_weather_sounds = list(/datum/looping_sound/indoor_rain)
	weather_messages = list("The rain cools your skin.", "The storm is really picking up!")

	damage_type = TOX
	min_severity = 4
	max_severity = 150
	max_severity_change = 50
	severity_steps = 50
	//immunity_type = TRAIT_RAINSTORM_IMMUNE
	probability = 1
	target_trait = PARTICLEWEATHER_RAIN

	weather_additional_events = list("thunder" = list(6, /datum/weather_event/thunder), "wind" = list(8, /datum/weather_event/wind))
	weather_warnings = list("siren" = null, "message" = FALSE)
	fire_smothering_strength = 6
	eclipse = TRUE
