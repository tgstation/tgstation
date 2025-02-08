//Causes fire damage to anyone not standing on a dense object.
/datum/weather/floor_is_lava
	name = "the floor is lava"
	desc = "The ground turns into surprisingly cool lava, lightly damaging anything on the floor."

	telegraph_message = span_warning("You feel the ground beneath you getting hot. Waves of heat distort the air.")
	telegraph_duration = 150

	weather_message = span_userdanger("ЧЁРТ, БЕГИ В ДРУГУЮ СТОРОНУ")
	weather_duration_lower = 300
	weather_duration_upper = 10000000
	weather_overlay = "lava"

	end_message = span_danger("The ground cools and returns to its usual form.")
	end_duration = 0

	area_type = /area/space
	target_trait = ZTRAIT_STATION

	overlay_layer = ABOVE_OPEN_TURF_LAYER //Covers floors only
	overlay_plane = FLOOR_PLANE
	immunity_type = TRAIT_LAVA_IMMUNE
	/// We don't draw on walls, so this ends up lookin weird
	/// Can't really use like, the emissive system here because I am not about to make
	/// all walls block emissive
	use_glow = FALSE


/datum/weather/floor_is_lava/can_weather_act(mob/living/mob_to_check)
	if(!mob_to_check.client) //Only sentient people are going along with it!
		return FALSE
	. = ..()
	if(!. || issilicon(mob_to_check) || istype(mob_to_check.buckled, /obj/structure/bed))
		return FALSE

/datum/weather/floor_is_lava/weather_act(mob/living/victim)
	victim.adjustFireLoss(3)
