/// Accepts light fixtures that are not already broken and are visible to the pawn.
/datum/targeting_strategy/unbroken_light

/datum/targeting_strategy/unbroken_light/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/obj/machinery/light/candidate = target
	if(!istype(candidate) || candidate.status == LIGHT_BROKEN)
		return FALSE
	return can_see(living_mob, candidate, vision_range)
