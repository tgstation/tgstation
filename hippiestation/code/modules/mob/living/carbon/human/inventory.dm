/mob/proc/quick_equip_and_return_success()
	var/obj/item/I = get_active_held_item()
	if(I)
		if(I.equip_to_best_slot(src))
			return TRUE
	return FALSE
