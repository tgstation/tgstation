/**
 * allow players to easily use items such as iron rods, rcds on open space without
 * having to pixelhunt for portions not occupied by object or mob visuals.
 */
/datum/element/openspace_item_click_handler

/datum/element/openspace_item_click_handler/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_afterattack))

/datum/element/openspace_item_click_handler/Detach(datum/source)
	UnregisterSignal(source, COMSIG_ITEM_AFTERATTACK)
	return ..()

//Invokes the proctype with a turf above as target.
/datum/element/openspace_item_click_handler/proc/on_afterattack(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER
	if(target.z == user.z)
		return
	var/turf/turf_above = get_step_multiz(target, UP)
	if(turf_above?.z == user.z)
		INVOKE_ASYNC(source, TYPE_PROC_REF(/obj/item, handle_openspace_click), turf_above, user, user.CanReach(turf_above, source), click_parameters)
	return COMPONENT_AFTERATTACK_PROCESSED_ITEM
