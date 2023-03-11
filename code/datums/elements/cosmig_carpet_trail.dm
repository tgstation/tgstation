/datum/element/cosmig_carpet_trail
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/cosmig_carpet_trail/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(generate_carpet))

/datum/element/cosmig_carpet_trail/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)

/datum/element/cosmig_carpet_trail/proc/generate_carpet(atom/movable/snail)
	SIGNAL_HANDLER

	var/turf/open/open_turf = get_turf(snail)
	if(istype(open_turf))
		new /obj/effect/cosmig_field/fast(open_turf)
		return TRUE
