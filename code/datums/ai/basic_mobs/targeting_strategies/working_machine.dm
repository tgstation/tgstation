/// Accepts machinery that is not broken and is visible to the pawn.
/datum/targeting_strategy/working_machine

/datum/targeting_strategy/working_machine/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/obj/machinery/candidate = target
	if(!istype(candidate) || (candidate.machine_stat & BROKEN))
		return FALSE
	return can_see(living_mob, candidate, vision_range)
