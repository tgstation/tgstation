/**
 * Apply this element to a turf (usually a wall) and it will be destroyed instantly by any explosion.
 * Most walls can already be destroyed by explosions so this is largely for usually indestructible ones.
 * For applying it in a map editor, use /obj/effect/mapping_helpers/bombable_wall
 */
/datum/component/bombable_turf
	/// Overlay we show to let you know it can be blown up
	var/mutable_appearance/overlay

/datum/component/bombable_turf/Initialize()
	. = ..()
	if(!isturf(parent))
		return ELEMENT_INCOMPATIBLE
	var/turf/turf_parent = parent
	turf_parent.explosive_resistance = 1
	overlay = mutable_appearance('icons/turf/overlays.dmi', "explodable", turf_parent.layer + 0.1)
	turf_parent.add_overlay(overlay)

/datum/component/bombable_turf/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_EX_ACT, PROC_REF(detonate))
	RegisterSignal(parent, COMSIG_TURF_CHANGE, PROC_REF(turf_changed))

/datum/component/bombable_turf/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_EX_ACT, COMSIG_TURF_CHANGE))
	return ..()

/datum/component/bombable_turf/Destroy(force, silent)
	var/atom/atom_parent = parent
	atom_parent.cut_overlay(overlay)
	overlay = null
	return ..()

/// If we get blowed up, move to the next turf
/datum/component/bombable_turf/proc/detonate(turf/source)
	SIGNAL_HANDLER
	source.ScrapeAway()

/// If this turf becomes something else we either just went off or regardless don't want this any more
/datum/component/bombable_turf/proc/turf_changed(turf/source)
	SIGNAL_HANDLER
	source.explosive_resistance = initial(source.explosive_resistance)
	qdel(src)
