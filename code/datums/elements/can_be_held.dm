/datum/element/can_be_held
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

/datum/element/can_be_held/Attach(datum/source)
	. = ..()

	if(!isliving(source))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(source, COMSIG_MOUSEDROP_ONTO, PROC_REF(on_mousedrop_onto))
	RegisterSignal(source, COMSIG_MOB_STRIP_MENU_OPEN, PROC_REF(on_strip_menu_open))
	RegisterSignal(source, COMSIG_STORAGE_DUMP_PRE_TRANSFER, PROC_REF(on_attempt_storage_dump))

/datum/element/can_be_held/Detach(datum/source)
	UnregisterSignal(source, list(COMSIG_MOUSEDROP_ONTO, COMSIG_MOB_STRIP_MENU_OPEN, COMSIG_STORAGE_DUMP_PRE_TRANSFER))
	return ..()

/// Used to determine the "intent" of the action that the user mob is trying to employ on the target.
/datum/element/can_be_held/proc/trying_to_hold_mob(mob/living/user, mob/living/target)
	return isliving(user) && user.grab_state == GRAB_AGGRESSIVE && user.pulling == target

/// Handles the mob being dropped onto the user mob.
/datum/element/can_be_held/proc/on_mousedrop_onto(datum/source, atom/over, mob/user)
	SIGNAL_HANDLER
	if(!trying_to_hold_mob(user, source))
		return

	INVOKE_ASYNC(source, TYPE_PROC_REF(/mob/living, mob_try_pickup), user)
	return COMPONENT_CANCEL_MOUSEDROP_ONTO

/// Blocks strip menu opening if we can reasonably assert that the mob is trying to be picked up
/datum/element/can_be_held/proc/on_strip_menu_open(datum/source, atom/over, mob/user)
	SIGNAL_HANDLER
	if(!trying_to_hold_mob(user, source))
		return

	return COMPONENT_BLOCK_STRIP_MENU_OPEN

/// Blocks storage dumping if we can reasonably assert that the mob is trying to be picked up
/datum/element/can_be_held/proc/on_attempt_storage_dump(datum/source, atom/over, mob/user)
	SIGNAL_HANDLER
	if(!trying_to_hold_mob(user, source))
		return

	return CANCEL_STORAGE_DUMP



