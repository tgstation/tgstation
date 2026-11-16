/// Targets non-incapable human carbons with a mind. Used for interaction targets (traders, etc.).
/datum/targeting_strategy/capable_human

/datum/targeting_strategy/capable_human/is_valid_target(mob/living/living_mob, atom/the_target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(the_target))
		return FALSE
	var/mob/living/carbon/human/human_target = the_target
	if(human_target.incapacitated || isnull(human_target.mind))
		return FALSE
	return TRUE
