/mob/living/carbon/alien/humanoid/doUnEquip(obj/item/I)
	. = ..()
	if(!. || !I)
		return

/mob/living/carbon/alien/humanoid/can_equip(obj/item/I, slot, disable_warning = 0)
	switch(slot)
		if(slot_hands)
			if(get_empty_held_indexes())
				return TRUE
			return FALSE
		if(slot_l_store)
			if(l_store)
				return FALSE
			if(!(I.slot_flags))
				return FALSE
			return TRUE
		if(slot_r_store)
			if(r_store)
				return FALSE
			if(!(I.slot_flags))
				return FALSE
			return TRUE
	return FALSE //Unsupported slot

/mob/living/carbon/alien/humanoid/attack_ui(slot_id)
	var/obj/item/I = get_active_held_item()
	if(!I)
		return FALSE
	switch(slot_id)
		if(slot_l_store)
			if(l_store)
				return FALSE
			l_store = I
			update_inv_pockets()
		if(slot_r_store)
			if(r_store)
				return FALSE
			r_store = I
			update_inv_pockets()
	I.equipped(src, slot_id)
	return TRUE
