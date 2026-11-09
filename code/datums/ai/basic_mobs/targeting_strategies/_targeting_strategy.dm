///Datum for basic mobs to define what they can attack,
///Global, just like ai_behaviors
/datum/targeting_strategy

///Returns true or false depending on if the target can be attacked by the mob.
///Base proc checks if target is within vision_range distance.
/datum/targeting_strategy/proc/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	if(QDELETED(target))
		return FALSE

	if(!vision_range)
		return TRUE

	return get_dist(living_mob, target) <= vision_range

/// Returns an atom the target might be hiding inside of, or null if none.
/datum/targeting_strategy/proc/find_hidden_mobs(mob/living/living_mob, atom/target)
	return null

/// Returns TRUE if we should keep tracking an existing target when no new candidates are visible.
/// Called with the loss range (typically larger than vision_range).
/// Default delegates to is_valid_target so all normal checks still apply.
/datum/targeting_strategy/proc/can_keep_target(mob/living/living_mob, atom/target, range, datum/ai_controller/controller = null)
	return is_valid_target(living_mob, target, range, controller)

/// Simply always returns true if you have a target, so only use this if you're pre-checking the targets somewhere else
/datum/targeting_strategy/anything

/datum/targeting_strategy/anything/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	return TRUE

///A very simple targeting strategy that checks that the target is a valid fishing spot.
/datum/targeting_strategy/fishing

/datum/targeting_strategy/fishing/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	return HAS_TRAIT(target, TRAIT_FISHING_SPOT)
