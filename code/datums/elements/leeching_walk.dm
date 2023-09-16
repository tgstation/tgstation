/// Buffs and heals the target while standing on rust.
/datum/element/leeching_walk

/datum/element/leeching_walk/Attach(datum/target)
	. = ..()
	if (!isliving(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))

/datum/element/leeching_walk/Detach(datum/source)
	. = ..()
	UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_LIFE))

/*
 * Signal proc for [COMSIG_MOVABLE_MOVED].
 *
 * Checks if we should have baton resistance on the new turf.
 */
/datum/element/leeching_walk/proc/on_move(mob/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	var/turf/mover_turf = get_turf(source)
	if(HAS_TRAIT(mover_turf, TRAIT_RUSTY))
		ADD_TRAIT(source, TRAIT_BATON_RESISTANCE, type)
		return

	REMOVE_TRAIT(source, TRAIT_BATON_RESISTANCE, type)

/**
 * Signal proc for [COMSIG_LIVING_LIFE].
 *
 * Gradually heals the heretic ([source]) on rust,
 * including baton knockdown and stamina damage.
 */
/datum/element/leeching_walk/proc/on_life(mob/living/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	var/turf/our_turf = get_turf(source)
	if(!HAS_TRAIT(our_turf, TRAIT_RUSTY))
		return

	// Heals all damage + Stamina
	source.adjustBruteLoss(-2, FALSE)
	source.adjustFireLoss(-2, FALSE)
	source.adjustToxLoss(-2, FALSE, forced = TRUE) // Slimes are people to
	source.adjustOxyLoss(-0.5, FALSE)
	source.adjustStaminaLoss(-2)
	// Reduces duration of stuns/etc
	source.AdjustAllImmobility(-0.5 SECONDS)
	// Heals blood loss
	if(source.blood_volume < BLOOD_VOLUME_NORMAL)
		source.blood_volume += 2.5 * seconds_per_tick
