/datum/targeting_strategy/injured_mob/not_self/injured_raptor

/datum/targeting_strategy/injured_mob/not_self/injured_raptor/is_valid_target(mob/living/living_mob, mob/living/basic/raptor/target, vision_range, datum/ai_controller/controller = null)
	if(!istype(target))
		return FALSE
	return ..()
