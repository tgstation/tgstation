/datum/element/associated_loc_updater
	element_flags = ELEMENT_DETACH

/datum/element/associated_loc_updater/Attach(datum/target)
	if(!isobj(target))
		return ELEMENT_INCOMPATIBLE
	. = ..()

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/on_target_moved)

	var/obj/object_target = target
	if(!isturf(object_target.loc))
		return

	object_target.associated_loc = object_target.loc

	LAZYOR(object_target.associated_loc.nullspaced_contents, object_target)

/datum/element/associated_loc_updater/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)

	var/obj/object_target = source
	if(!isturf(object_target.associated_loc))
		return

	LAZYREMOVE(object_target.associated_loc.nullspaced_contents, object_target)

	object_target.associated_loc = null

/datum/element/associated_loc_updater/proc/on_target_moved(obj/target, atom/old_loc)
	SIGNAL_HANDLER

	if(isturf(old_loc))
		var/turf/old_turf = old_loc
		LAZYREMOVE(old_turf.nullspaced_contents, target)
		target.associated_loc = null

	if(isturf(target.loc))
		var/turf/new_turf = target.loc
		LAZYOR(new_turf.nullspaced_contents, target)
		target.associated_loc = new_turf

