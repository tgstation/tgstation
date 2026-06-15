/// Accepts living (non-dead) deer that are visible to the pawn.
/datum/targeting_strategy/playable_deer

/datum/targeting_strategy/playable_deer/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	var/mob/living/candidate = target
	if(!isliving(candidate) || candidate.stat == DEAD)
		return FALSE
	return can_see(living_mob, candidate, vision_range)
