/// Accepts hydroponics trays with a growing seed that are not too weedy or pest-ridden, and visible.
/datum/targeting_strategy/sniffable_hydro

/datum/targeting_strategy/sniffable_hydro/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	var/obj/machinery/hydroponics/candidate = target
	if(!istype(candidate))
		return FALSE
	if(isnull(candidate.myseed))
		return FALSE
	if(candidate.weedlevel > 5 || candidate.pestlevel > 5)
		return FALSE
	return can_see(living_mob, candidate, vision_range)
