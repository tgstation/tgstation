/datum/element/cosmic_carpet_trail

/datum/element/cosmic_carpet_trail/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(generate_carpet))

/datum/element/cosmic_carpet_trail/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)

/datum/element/cosmic_carpet_trail/proc/generate_carpet(atom/movable/target_object)
	SIGNAL_HANDLER

	var/turf/open/open_turf = get_turf(target_object)
	if(istype(open_turf))
		new /obj/effect/forcefield/cosmic_field/fast(open_turf)
		return TRUE
