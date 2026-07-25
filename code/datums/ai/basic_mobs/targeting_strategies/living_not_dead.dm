/// Accepts living mobs that are not dead and visible to the pawn. Skips faction checks,
/// so it's suitable for finding allies (e.g. a hivebot looking for another hivebot).
/datum/targeting_strategy/living_not_dead

/datum/targeting_strategy/living_not_dead/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/candidate = target
	if(!isliving(candidate) || candidate.stat == DEAD)
		return FALSE
	return can_see(living_mob, candidate, vision_range)
