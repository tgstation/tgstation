//update_icon() may change the onmob icons
//Very good name, I know
/datum/element/update_icon_updates_onmob
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///The ITEM_SLOT_X flags to update on the parent mob. (Ex: ITEM_SLOT_HANDS|ITEM_SLOT_FEET)
	var/update_flags = NONE
	///Should the element call [/mob/proc/update_body()] in addition to clothing updates?
	var/update_body = FALSE

/datum/element/update_icon_updates_onmob/Attach(datum/target, flags, body = FALSE)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ATOM_UPDATED_ICON, PROC_REF(update_onmob))
	update_flags = flags
	update_body = body

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
