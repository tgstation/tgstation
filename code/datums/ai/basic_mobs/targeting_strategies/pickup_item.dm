///Ensures the item is actually on a turf, else we can't go there to pick it up!
/datum/targeting_strategy/pickup_item

/datum/targeting_strategy/pickup_item/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	if(!isturf(target.loc))
		return FALSE
	return TRUE
