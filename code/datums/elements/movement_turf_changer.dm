/**
 * movement_turf_changer element; which makes the movement of a movable atom change the turf it moved to
 *
 * Used for moonicorns!
 */
/datum/element/movement_turf_changer
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	///Path of the turf added on top
	var/turf_type

/datum/element/movement_turf_changer/Attach(datum/target, turf_type)
	. = ..()

	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	src.turf_type = turf_type
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/on_moved)

/datum/element/movement_turf_changer/Detach(datum/target)
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	. = ..()

/datum/element/movement_turf_changer/proc/on_moved(atom/movable/target, atom/origin, direction, forced)
	SIGNAL_HANDLER

	var/turf/destination = target.loc
	if(!isturf(destination) || istype(destination, turf_type))
		return

	destination.PlaceOnTop(turf_type)
