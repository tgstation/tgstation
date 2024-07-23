/**
 * allow players to easily use items such as iron rods, rcds on open space without
 * having to pixelhunt for portions not occupied by object or mob visuals.
 */
/datum/element/openspace_item_click_handler

/datum/element/openspace_item_click_handler/Attach(datum/target)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_RANGED_ITEM_INTERACTING_WITH_ATOM, PROC_REF(divert_interaction))

/datum/element/openspace_item_click_handler/Detach(datum/source)
	UnregisterSignal(source, COMSIG_RANGED_ITEM_INTERACTING_WITH_ATOM)
	return ..()

//Invokes the proctype with a turf above as target.
/datum/element/openspace_item_click_handler/proc/divert_interaction(obj/item/source, mob/user, atom/target, list/modifiers)
	SIGNAL_HANDLER
	if((target.z == 0) || (user.z == 0) || target.z == user.z)
		return NONE
	var/turf/target_turf = parse_caught_click_modifiers(modifiers, get_turf(user.client?.eye || user), user.client)
	if(target_turf?.z == user.z && user.CanReach(target_turf, source))
		INVOKE_ASYNC(source, TYPE_PROC_REF(/obj/item, handle_openspace_click), target_turf, user, modifiers)
		return ITEM_INTERACT_BLOCKING
	return NONE
