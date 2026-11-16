/// Accepts living mobs that are not dead or incapacitated, and visible to the pawn.
/datum/targeting_strategy/conscious_mob

/datum/targeting_strategy/conscious_mob/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/candidate = target
	if(!isliving(candidate) || candidate.incapacitated)
		return FALSE
	return can_see(living_mob, candidate, vision_range)
