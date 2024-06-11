/**
 * allow players to easily use items such as iron rods, rcds on open space without
 * having to pixelhunt for portions not occupied by object or mob visuals.
 */
/datum/element/openspace_item_click_handler

/datum/element/openspace_item_click_handler/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ITEM_INTERACTING_WITH_ATOM, PROC_REF(divert_interaction))

/datum/element/openspace_item_click_handler/Detach(datum/source)
	UnregisterSignal(source, COMSIG_ITEM_INTERACTING_WITH_ATOM)
	return ..()

//Invokes the proctype with a turf above as target.
/datum/element/openspace_item_click_handler/proc/divert_interaction(obj/item/source, mob/user, atom/target, click_parameters)
	SIGNAL_HANDLER
	if(target.z == user.z)
		return NONE
	var/turf/checked_turf = get_turf(target)
	while(!isnull(checked_turf))
		checked_turf = GET_TURF_ABOVE(checked_turf)
		if(checked_turf?.z == user.z && user.CanReach(checked_turf, source))
			INVOKE_ASYNC(source, TYPE_PROC_REF(/obj/item, handle_openspace_click), checked_turf, user, click_parameters)
			break

	return ITEM_INTERACT_BLOCKING
