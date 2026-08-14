/// Base strategy for checking if a turf is walkable
/datum/targeting_strategy/walkable_turf

/datum/targeting_strategy/walkable_turf/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/turf/candidate = target
	return !candidate.is_blocked_turf()
