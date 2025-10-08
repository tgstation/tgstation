/**
 * drag_pickup element; for allowing things to be picked up by dragging.
 *
 * Used for paper bins.
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

/datum/element/drag_pickup/proc/pick_up(atom/source, atom/over, mob/user)
	SIGNAL_HANDLER

	var/mob/living/picker = user
	if(!istype(picker) || !user.can_perform_action(source, FORBID_TELEKINESIS_REACH))
		return
	var/obj/pickup_object = source
	if (pickup_object)
		if (pickup_object.anchored)
			return COMPONENT_CANCEL_MOUSEDROP_ONTO

	if(over == picker)
		INVOKE_ASYNC(picker, TYPE_PROC_REF(/mob/, put_in_hands), source)
	else if(istype(over, /atom/movable/screen/inventory/hand))
		var/atom/movable/screen/inventory/hand/Selected_hand = over
		picker.putItemFromInventoryInHandIfPossible(source, Selected_hand.held_index)
	return COMPONENT_CANCEL_MOUSEDROP_ONTO
