/datum/weather/void_storm
	name = "void storm"
	desc = "A rare and highly anomalous event often accompanied by unknown entities shredding spacetime continouum. We'd advise you to start running."

	telegraph_duration = 2 SECONDS
	telegraph_overlay = "light_snow"

	weather_message = span_hypnophrase("You feel the air around you getting colder... and void's sweet embrace...")
	weather_overlay = "snow_storm"
	weather_color = COLOR_BLACK
	weather_duration_lower = 60 SECONDS
	weather_duration_upper = 120 SECONDS

	use_glow = FALSE

	end_duration = 10 SECONDS

	area_type = /area
	protect_indoors = FALSE
	target_trait = ZTRAIT_VOIDSTORM

	immunity_type = TRAIT_VOIDSTORM_IMMUNE

	barometer_predictable = FALSE
	perpetual = TRUE

	/// List of areas that were once impacted areas but are not anymore. Used for updating the weather overlay based whether the ascended heretic is in the area.
	var/list/former_impacted_areas = list()

/datum/weather/void_storm/can_weather_act(mob/living/mob_to_check)
	. = ..()
	if(IS_HERETIC_OR_MONSTER(mob_to_check))
		return FALSE

/datum/weather/void_storm/weather_act(mob/living/victim)
	var/need_mob_update = FALSE
	need_mob_update += victim.adjustFireLoss(1, updating_health = FALSE)
	need_mob_update += victim.adjustOxyLoss(rand(1, 3), updating_health = FALSE)
	if(need_mob_update)
		victim.updatehealth()
	victim.adjust_eye_blur(rand(0 SECONDS, 2 SECONDS))
	victim.adjust_bodytemperature(-30 * TEMPERATURE_DAMAGE_COEFFICIENT)

// Goes through former_impacted_areas and sets the overlay of each back to the telegraph overlay, to indicate the ascended heretic is no longer in that area.
/datum/weather/void_storm/update_areas()
	for(var/area/former_area as anything in former_impacted_areas)
		former_area.icon_state = telegraph_overlay
		former_impacted_areas -= former_area
	return ..()
