/// Accepts visible cables sitting on accessible open floor tiles.
/datum/targeting_strategy/accessible_cable

/datum/targeting_strategy/accessible_cable/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/obj/structure/cable/candidate = target
	if(!istype(candidate) || !can_see(living_mob, candidate, vision_range))
		return FALSE
	var/turf/open/floor/below_the_cable = get_turf(candidate)
	if(!istype(below_the_cable))
		return FALSE
	return below_the_cable.underfloor_accessibility >= UNDERFLOOR_INTERACTABLE
