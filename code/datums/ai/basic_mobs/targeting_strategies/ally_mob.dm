/// Accepts visible mobs that are allies of the pawn (and not the pawn itself).
/datum/targeting_strategy/ally_mob

/datum/targeting_strategy/ally_mob/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	if(target == living_mob || !living_mob.has_ally(target))
		return FALSE
	return can_see(living_mob, target, vision_range)
