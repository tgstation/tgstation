/datum/element/can_be_held
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

/datum/element/can_be_held/Attach(datum/source)
	. = ..()

	if(!isliving(source))
		return ELEMENT_INCOMPATIBLE

	ADD_TRAIT(source, TRAIT_CAN_BE_HELD, ELEMENT_TRAIT(type))

	RegisterSignal(source, COMSIG_MOUSEDROP_ONTO, PROC_REF(on_mousedrop_onto))

/datum/element/can_be_held/Detach(datum/source)
	REMOVE_TRAIT(source, TRAIT_CAN_BE_HELD, ELEMENT_TRAIT(type))
	UnregisterSignal(source, COMSIG_MOUSEDROP_ONTO, PROC_REF(on_mousedrop_onto))
	return ..()

/// Handles the mob being dropped onto the user mob.
/datum/element/can_be_held/proc/on_mousedrop_onto(datum/source, atom/over, mob/user)
	SIGNAL_HANDLER

	if(!isliving(user))
		return

	var/mob/living/holder_to_be = user

	if(!holder_to_be.trying_to_hold_mob(source))
		return

	INVOKE_ASYNC(holder_to_be, TYPE_PROC_REF(/mob/living, mob_try_pickup), source)
	return COMPONENT_CANCEL_MOUSEDROP_ONTO




