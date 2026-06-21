/// Base strategy for picking an open, walkable turf to wander to. Subtypes decide which terrain to accept.
/datum/targeting_strategy/walkable_turf

/datum/targeting_strategy/walkable_turf/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	var/turf/candidate = target
	if(!isturf(candidate) || isclosedturf(candidate) || is_space_or_openspace(candidate))
		return FALSE
	return !candidate.is_blocked_turf()

/// Accepts open, walkable water turfs.
/datum/targeting_strategy/walkable_turf/water_turf

/datum/targeting_strategy/walkable_turf/water_turf/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	return iswaterturf(target)

/// Accepts open, walkable land (non-water) turfs.
/datum/targeting_strategy/walkable_turf/land_turf

/datum/targeting_strategy/walkable_turf/land_turf/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	return !iswaterturf(target)
