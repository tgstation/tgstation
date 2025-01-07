/**
 * ## block_turf_fingerprints
 *
 * Attach to a movable, prevents mobs from leaving fingerprints on the turf below it
 */
/datum/element/block_turf_fingerprints
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/block_turf_fingerprints/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	var/atom/movable/target_movable = target
	if(isturf(target_movable.loc))
		apply_to_turf(target_movable.loc)

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(move_turf))

/datum/element/block_turf_fingerprints/Detach(atom/movable/target)
	. = ..()
	if(isturf(target.loc))
		remove_from_turf(target.loc)

	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)

/datum/element/block_turf_fingerprints/proc/apply_to_turf(turf/the_turf)
	// It's possible two things with this element could be on the same turf, so let's avoid double-applying
	if(the_turf.interaction_flags_atom & INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND)
		// But what if the turf has this flag by default? We still need to override register a signal.
		// Otherwise we may run into a very niche bug:
		// - A turf as this flag by default
		// - A movable with this element is placed on the turf
		// - It does not gain the flag nor register a signal
		// - The turf changes, and the new turf does not gain the flag
		if(initial(the_turf.interaction_flags_atom) & INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND)
			RegisterSignal(the_turf, COMSIG_TURF_CHANGE, PROC_REF(replace_our_turf), override = TRUE)
		return

	the_turf.interaction_flags_atom |= INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND
	RegisterSignal(the_turf, COMSIG_TURF_CHANGE, PROC_REF(replace_our_turf))

/datum/element/block_turf_fingerprints/proc/remove_from_turf(turf/the_turf)
	the_turf.interaction_flags_atom &= ~INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND
	UnregisterSignal(the_turf, COMSIG_TURF_CHANGE)

/datum/element/block_turf_fingerprints/proc/move_turf(atom/movable/source, atom/old_loc)
	SIGNAL_HANDLER
	if(isturf(old_loc))
		remove_from_turf(old_loc)
	if(isturf(source.loc))
		apply_to_turf(source.loc)

/datum/element/block_turf_fingerprints/proc/replace_our_turf(datum/source, path, new_baseturfs, flags, post_change_callbacks)
	SIGNAL_HANDLER
	post_change_callbacks += CALLBACK(src, PROC_REF(apply_to_turf))
