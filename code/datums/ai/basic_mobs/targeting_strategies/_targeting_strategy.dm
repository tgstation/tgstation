///Datum for basic mobs to define what they can attack,
///Global, just like ai_behaviors
/datum/targeting_strategy

///Returns true or false depending on if the target can be attacked by the mob
/datum/targeting_strategy/proc/is_valid_target(mob/living/living_mob, atom/target, vision_range)
	return

/// Returns an atom the target might be hiding inside of, or null if none.
/datum/targeting_strategy/proc/find_hidden_mobs(mob/living/living_mob, atom/target)
	return null

/// Simply always returns true if you have a target, so only use this if you're pre-checking the targets somewhere else
/datum/targeting_strategy/anything

/datum/targeting_strategy/anything/is_valid_target(mob/living/living_mob, atom/target, vision_range)
	return !!target

///A very simple targeting strategy that checks that the target is a valid fishing spot.
/datum/targeting_strategy/fishing

/datum/targeting_strategy/fishing/is_valid_target(mob/living/living_mob, atom/target, vision_range)
	return HAS_TRAIT(target, TRAIT_FISHING_SPOT)
