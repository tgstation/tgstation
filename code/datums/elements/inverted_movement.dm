/datum/element/inverted_movement

/datum/element/inverted_movement/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(invert_movement))

/datum/element/inverted_movement/Detach(datum/source)
	UnregisterSignal(source, COMSIG_MOB_CLIENT_PRE_MOVE)
	return ..()

/datum/element/inverted_movement/proc/invert_movement(mob/living/source, move_args)
	SIGNAL_HANDLER
	var/new_direct = REVERSE_DIR(move_args[MOVE_ARG_DIRECTION])
	move_args[MOVE_ARG_DIRECTION] = new_direct
	move_args[MOVE_ARG_NEW_LOC] = get_step(source, new_direct)
