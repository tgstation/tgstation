/**
 * Mob Killed Tally; which ticks up a blackbox when the mob dies
 *
 * Used for all the mining mobs!
 */
/datum/element/mob_killed_tally
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Which tally needs to be ticked up in the blackbox
	var/tally_string

/datum/element/mob_killed_tally/Attach(datum/target, tally_string)
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))

	src.tally_string = tally_string

/datum/element/mob_killed_tally/Detach(datum/target)
	UnregisterSignal(target, COMSIG_LIVING_DEATH)
	return ..()

/datum/element/mob_killed_tally/proc/on_death(mob/living/target, gibbed)
	SIGNAL_HANDLER

	SSblackbox.record_feedback("tally", tally_string, 1, target.type)
