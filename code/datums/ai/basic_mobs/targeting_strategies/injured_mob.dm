/// Accepts mobs below their maximum health (no line-of-sight requirement).
/datum/targeting_strategy/injured_mob

/datum/targeting_strategy/injured_mob/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	var/mob/living/candidate = target
	if(!isliving(candidate))
		return FALSE
	return candidate.health < candidate.maxHealth
