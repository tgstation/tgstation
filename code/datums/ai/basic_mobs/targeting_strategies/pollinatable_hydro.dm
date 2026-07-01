/// Accepts visible hydroponics trays a bee can currently pollinate.
/datum/targeting_strategy/pollinatable_hydro

/datum/targeting_strategy/pollinatable_hydro/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/obj/machinery/hydroponics/candidate = target
	if(!istype(candidate) || !candidate.can_bee_pollinate())
		return FALSE
	return can_see(living_mob, candidate, vision_range)
