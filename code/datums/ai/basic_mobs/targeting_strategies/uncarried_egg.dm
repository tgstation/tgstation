/// Accepts visible penguin eggs the pawn is not already carrying.
/datum/targeting_strategy/uncarried_egg

/datum/targeting_strategy/uncarried_egg/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	if(target in living_mob.contents)
		return FALSE
	return can_see(living_mob, target, vision_range)
