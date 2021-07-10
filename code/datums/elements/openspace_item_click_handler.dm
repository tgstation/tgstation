/**
 * allow players to easily use items such as iron rods, rcds on open space without
 * having to pixelhunt for portions not occupied by object or mob visuals.
 */
/datum/element/openspace_item_click_handler
	element_flags = ELEMENT_DETACH

/datum/element/openspace_item_click_handler/Attach(datum/target)
	..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, .proc/on_afterattack)

/datum/element/openspace_item_click_handler/Detach(datum/source)
	UnregisterSignal(source, COMSIG_ITEM_AFTERATTACK)
	..()

/datum/element/openspace_item_click_handler/proc/on_afterattack(item/source, atom/target, mob/user, proximity_flag, click_parameters)
	if(target.z == user.z)
		return
	var/turf/turf_above = get_step_multiz(target, UP)
	if(turf_above?.z == user.z)
		user.next_click = null  // reset the cooldown and try again on the turf above.
		user.ClickOn(turf_above, click_parameters)
	return
