//Prevents calling anything in update_icon() like update_icon_state() or update_overlays()

/datum/element/update_icon_blocker/Attach(atom/target)
	if(!istype(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ATOM_UPDATE_ICON, .proc/block_update_icon)
	return ..()

/datum/element/update_icon_blocker/proc/block_update_icon()
	return COMSIG_ATOM_NO_UPDATE_ICON_STATE | COMSIG_ATOM_NO_UPDATE_OVERLAYS
