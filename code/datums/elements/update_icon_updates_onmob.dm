//update_icon() may change the onmob icons
//Very good name, I know
/datum/element/update_icon_updates_onmob
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	var/update_flags = NONE
	var/update_body = FALSE

/datum/element/update_icon_updates_onmob/Attach(datum/target, flags, body = FALSE)
	. = ..()
	if(!istype(target, /obj/item))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ATOM_UPDATED_ICON, .proc/update_onmob)

/datum/element/update_icon_updates_onmob/proc/update_onmob(obj/item/target)
	SIGNAL_HANDLER

	if(ismob(target.loc))
		var/mob/M = target.loc
		if(M.is_holding(target))
			M.update_held_items()
		else
			M.update_clothing(update_flags)
			if(update_body)
				M.update_body()
