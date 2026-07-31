/// Accepts pieces of paper that have nothing written on them yet.
/datum/targeting_strategy/empty_paper

/datum/targeting_strategy/empty_paper/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/paper/candidate = target
	if(!istype(candidate) || !candidate.is_empty())
		return FALSE
	return TRUE
