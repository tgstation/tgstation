/// Accepts decorated donuts that are visible to the pawn.
/datum/targeting_strategy/decorated_donut

/datum/targeting_strategy/decorated_donut/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/food/donut/candidate = target
	if(!istype(candidate) || !candidate.is_decorated)
		return FALSE
	return can_see(living_mob, candidate, vision_range)
