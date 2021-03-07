/datum/element/drag_pickup
	element_flags = ELEMENT_DETACH

/datum/element/drag_pickup/Attach(datum/target)
	if(isatom(target))
		if(ismovable(target))
			RegisterSignal(target, COMSIG_MOUSEDROP_ONTO, .proc/pick_up)
	return ..()

/datum/element/drag_pickup/Detach(datum/source, force)
	UnregisterSignal(source, COMSIG_MOUSEDROP_ONTO)
	return ..()

/datum/element/drag_pickup/proc/pick_up(atom/source, atom/over, mob/user)
	SIGNAL_HANDLER
	var/mob/living/M = user
	if(!istype(M) || M.incapacitated() || !source.Adjacent(M))
		return

	if(over == M)
		INVOKE_ASYNC(M, /mob/.proc/put_in_hands, source)

	else if(istype(over, /atom/movable/screen/inventory/hand))
		var/atom/movable/screen/inventory/hand/H = over
		M.putItemFromInventoryInHandIfPossible(source, H.held_index)
