/// Accepts ice turfs that can have a hole made in them and are visible to the pawn.
/// Pair with a range_turfs source.
/datum/targeting_strategy/drillable_ice

/datum/targeting_strategy/drillable_ice/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/turf/open/misc/ice/candidate = target
	if(!istype(candidate) || !candidate.can_make_hole)
		return FALSE
	return can_see(living_mob, candidate, vision_range)
