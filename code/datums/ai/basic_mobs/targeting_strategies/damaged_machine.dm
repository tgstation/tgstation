/// Accepts machinery below max integrity that is visible to the pawn.
/datum/targeting_strategy/damaged_machine

/datum/targeting_strategy/damaged_machine/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/obj/machinery/candidate = target
	if(!istype(candidate) || candidate.get_integrity() >= candidate.max_integrity)
		return FALSE
	return can_see(living_mob, candidate, vision_range)
