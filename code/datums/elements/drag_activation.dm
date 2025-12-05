/**
 * drag_to_activate element
 *
 * Allowing things to be activated by mouse dragging.
 * Useful for objects which have a TGUI window on interaction.
 */
/datum/element/drag_to_activate

/datum/element/drag_to_activate/Attach(datum/target)
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOUSEDROP_ONTO, PROC_REF(activate))
	return ..()

/datum/element/drag_to_activate/Detach(datum/source)
	UnregisterSignal(source, COMSIG_MOUSEDROP_ONTO)
	return ..()

/datum/element/drag_to_activate/proc/activate(atom/movable/source, atom/over, mob/user)
	SIGNAL_HANDLER

	if(!user.can_perform_action(source, FORBID_TELEKINESIS_REACH))
		return NONE

	var/obj/item/item_source = source
	if(!istype(over, /atom/movable/screen))
		INVOKE_ASYNC(item_source, TYPE_PROC_REF(/obj/item, attack_self), user)
		source.add_fingerprint(user)
		return COMPONENT_CANCEL_MOUSEDROP_ONTO
