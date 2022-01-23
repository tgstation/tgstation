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

	object_target.move_associated_loc(object_target.loc)

/datum/element/associated_loc_updater/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)

	var/obj/object_target = source

	object_target.move_associated_loc(null)

/datum/element/associated_loc_updater/proc/on_target_moved(obj/target, atom/old_loc)
	SIGNAL_HANDLER

	target.move_associated_loc(target.loc)

