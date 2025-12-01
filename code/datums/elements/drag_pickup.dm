/**
 * drag_pickup element
 *
 * Allowing things to be picked up or unequipped by mouse-dragging.
 * Useful for objects which have an interaction on click
 */
/datum/element/drag_pickup

/datum/element/drag_pickup/Attach(datum/target)
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOUSEDROP_ONTO, PROC_REF(pick_up))
	return ..()

/datum/element/drag_pickup/Detach(datum/source)
	UnregisterSignal(source, COMSIG_MOUSEDROP_ONTO)
	return ..()

/datum/element/drag_pickup/proc/pick_up(atom/movable/source, atom/over, mob/user)
	SIGNAL_HANDLER

	if(!user.can_perform_action(source, FORBID_TELEKINESIS_REACH))
		return NONE
	if(source.anchored)
		return NONE
	if(source.loc == user && isitem(source))
		var/obj/item/item_source = source
		if(!item_source.can_mob_unequip(user))
			return COMPONENT_CANCEL_MOUSEDROP_ONTO

	if(over == user)
		INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, put_in_hands), source)
	else if(istype(over, /atom/movable/screen/inventory/hand))
		var/atom/movable/screen/inventory/hand/selected_hand = over
		user.putItemFromInventoryInHandIfPossible(source, selected_hand.held_index)
		source.add_fingerprint(user)
	return COMPONENT_CANCEL_MOUSEDROP_ONTO
