
// Status effect helpers for living mobs

/**
 * Applies a given status effect to this mob.
 *
 * new_effect - TYPEPATH of a status effect to apply.
 * Additional status effect arguments can be passed.
 *
 * Returns the instance of the created effected, if successful.
 * Returns 'null' if unsuccessful.
 */
/mob/living/proc/apply_status_effect(datum/status_effect/new_effect, ...)
	RETURN_TYPE(/datum/status_effect)

	// The arguments we pass to the start effect. The 1st argument is this mob.
	var/list/arguments = args.Copy()
	arguments[1] = src

	// If the status effect we're applying doesn't allow multiple effects, we need to handle it
	if(initial(new_effect.status_type) != STATUS_EFFECT_MULTIPLE)
		for(var/datum/status_effect/existing_effect as anything in status_effects)
			if(existing_effect.id != initial(new_effect.id))
				continue

			switch(existing_effect.status_type)
				// Multiple are allowed, continue as normal. (Not normally reachable)
				if(STATUS_EFFECT_MULTIPLE)
					break
				// Only one is allowed of this type - early return
				if(STATUS_EFFECT_UNIQUE)
					return
				// Replace the existing instance (deletes it).
				if(STATUS_EFFECT_REPLACE)
					existing_effect.be_replaced()
				// Refresh the existing type, then early return
				if(STATUS_EFFECT_REFRESH)
					existing_effect.refresh(arglist(arguments))
					return

	// Create the status effect with our mob + our arguments
	var/datum/status_effect/new_instance = new new_effect(arguments)
	if(!QDELETED(new_instance))
		return new_instance

/**
 * Removes all instances of a given status effect from this mob
 *
 * removed_effect - TYPEPATH of a status effect to remove.
 * Additional status effect arguments can be passed - these are passed into before_remove.
 *
 * Returns TRUE if at least one was removed.
 */
/mob/living/proc/remove_status_effect(datum/status_effect/removed_effect, ...)
	var/list/arguments = args.Copy(2)

	. = FALSE
	for(var/datum/status_effect/existing_effect as anything in status_effects)
		if(existing_effect.id == initial(removed_effect.id) && existing_effect.before_remove(arguments))
			qdel(existing_effect)
			. = TRUE

	return .

/**
 * Checks if this mob has a status effect that shares the passed effect's ID
 *
 * checked_effect - TYPEPATH of a status effect to check for. Checks for its ID, not it's typepath
 *
 * Returns an instance of a status effect, or NULL if none were found.
 */
/mob/living/proc/has_status_effect(datum/status_effect/checked_effect)
	RETURN_TYPE(/datum/status_effect)

	for(var/datum/status_effect/present_effect as anything in status_effects)
		if(present_effect.id == initial(checked_effect.id))
			return present_effect

	return null

/**
 * Returns a list of all status effects that share the passed effect type's ID
 *
 * checked_effect - TYPEPATH of a status effect to check for. Checks for its ID, not it's typepath
 *
 * Returns a list
 */
/mob/living/proc/has_status_effect_list(datum/status_effect/checked_effect)
	RETURN_TYPE(/list)

	var/list/effects_found = list()
	for(var/datum/status_effect/present_effect as anything in status_effects)
		if(present_effect.id == initial(checked_effect.id))
			effects_found += present_effect

	return effects_found
