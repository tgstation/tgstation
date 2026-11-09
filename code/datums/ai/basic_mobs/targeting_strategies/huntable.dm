/// Accepts any visible target that isn't a dead mob. Mirrors the legacy hunt finder's validity check.
/datum/targeting_strategy/huntable

/datum/targeting_strategy/huntable/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	if(isliving(target))
		var/mob/living/living_target = target
		if(living_target.stat == DEAD)
			return FALSE
	return can_see(living_mob, target, vision_range)
