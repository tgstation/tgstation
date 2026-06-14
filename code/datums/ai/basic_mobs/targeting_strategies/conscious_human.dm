/// Targets conscious human carbons with a mind. Used for interaction targets (traders, etc.).
/datum/targeting_strategy/conscious_human

/datum/targeting_strategy/conscious_human/is_valid_target(mob/living/living_mob, atom/the_target, vision_range)
	if(!istype(the_target, /mob/living/carbon/human))
		return FALSE
	var/mob/living/carbon/human/human_target = the_target
	if(IS_DEAD_OR_INCAP(human_target) || !human_target.mind)
		return FALSE
	return TRUE
