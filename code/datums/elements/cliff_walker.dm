/// Lets a mob walk cliffs and keeps track of if they're alive or not to add/remove the trait
/datum/element/cliff_walking

/datum/element/cliff_walking/Attach(datum/target, climb_time, climb_stun)
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	// Feel free to add more bespoke signals here if this gets implemented for more than just a few funny mobs
	RegisterSignals(target, list(COMSIG_LIVING_DEATH, COMSIG_LIVING_REVIVE), PROC_REF(update_cliff_walking))

	update_cliff_walking(target)

/datum/element/cliff_walking/Detach(datum/source, ...)
	. = ..()

	UnregisterSignal(source, list(COMSIG_LIVING_DEATH, COMSIG_LIVING_REVIVE))

/// Do some checks to see if we should walk the cliffs
/datum/element/cliff_walking/proc/update_cliff_walking(mob/living/climber)
	SIGNAL_HANDLER

	if(climber.stat != DEAD)
		ADD_TRAIT(climber, TRAIT_CLIFF_WALKER, type)
		return

	REMOVE_TRAIT(climber, TRAIT_CLIFF_WALKER, type)

	var/turf/open/cliff/cliff_tile = get_turf(climber)
	if(!iscliffturf(cliff_tile))
		return

	cliff_tile.try_fall(climber)
