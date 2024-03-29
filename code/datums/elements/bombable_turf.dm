/**
 * Apply this to a turf (usually a wall) and it will be destroyed instantly by any explosion.
 * Most walls can already be destroyed by explosions so this is largely for usually indestructible ones.
 * For applying it in a map editor, use /obj/effect/mapping_helpers/bombable_wall
 */
/datum/element/bombable_turf

/datum/element/bombable_turf/Attach(turf/target)
	. = ..()
	if(!isturf(target))
		return ELEMENT_INCOMPATIBLE
	target.explosive_resistance = 1

	RegisterSignal(target, COMSIG_ATOM_EX_ACT, PROC_REF(detonate))
	RegisterSignal(target, COMSIG_TURF_CHANGE, PROC_REF(turf_changed))
	RegisterSignal(target, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examined))

	target.update_appearance(UPDATE_OVERLAYS)

/datum/element/bombable_turf/Detach(turf/source)
	UnregisterSignal(source, list(COMSIG_ATOM_EX_ACT, COMSIG_TURF_CHANGE, COMSIG_ATOM_UPDATE_OVERLAYS, COMSIG_ATOM_EXAMINE))
	source.explosive_resistance = initial(source.explosive_resistance)
	source.update_appearance(UPDATE_OVERLAYS)
	return ..()

/// If we get blowed up, move to the next turf
/datum/element/bombable_turf/proc/detonate(turf/source)
	SIGNAL_HANDLER
	source.ScrapeAway()

/// If this turf becomes something else we either just went off or regardless don't want this any more
/datum/element/bombable_turf/proc/turf_changed(turf/source)
	SIGNAL_HANDLER
	Detach(source)

/// Show a little crack on here
/datum/element/bombable_turf/proc/on_update_overlays(turf/source, list/overlays)
	SIGNAL_HANDLER
	overlays += mutable_appearance('icons/turf/overlays.dmi', "explodable", source.layer + 0.1)

/// Show a little extra on examine
/datum/element/bombable_turf/proc/on_examined(turf/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("It seems to be slightly cracked...")
