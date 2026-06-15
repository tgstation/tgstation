/// Accepts dead living mobs that are visible to the pawn.
/datum/targeting_strategy/dead_mob

/datum/targeting_strategy/dead_mob/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/candidate = target
	if(!isliving(candidate) || candidate.stat != DEAD)
		return FALSE
	return can_see(living_mob, candidate, vision_range)

/// As dead_mob, but rejects corpses already being dragged by something.
/datum/targeting_strategy/dead_mob/not_pulled

/datum/targeting_strategy/dead_mob/not_pulled/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	var/mob/living/candidate = target
	if(isliving(candidate) && candidate.pulledby)
		return FALSE
	return ..()
