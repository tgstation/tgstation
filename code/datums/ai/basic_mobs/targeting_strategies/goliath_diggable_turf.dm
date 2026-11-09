/// Accepts undig asteroid turfs. Pair with a range_turfs source.
/datum/targeting_strategy/goliath_diggable_turf

/datum/targeting_strategy/goliath_diggable_turf/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/turf/open/misc/asteroid/candidate = target
	if(!istype(candidate) || candidate.dug)
		return FALSE
	return TRUE
