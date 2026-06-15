/// Accepts visible items that aren't anchored or already being pulled.
/datum/targeting_strategy/stealable_item

/datum/targeting_strategy/stealable_item/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/candidate = target
	if(!isitem(candidate) || candidate.anchored || candidate.pulledby)
		return FALSE
	return can_see(living_mob, candidate, vision_range)
