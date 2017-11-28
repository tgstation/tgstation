/mob/living/carbon/monkey/can_equip(obj/item/I, slot, disable_warning = 0)
	switch(slot)
		if(slot_hands)
			if(get_empty_held_indexes())
				return TRUE
			return FALSE
		if(slot_wear_mask)
			if(wear_mask)
				return FALSE
			if( !(I.slot_flags & SLOT_MASK) )
				return FALSE
			return TRUE
		if(slot_neck)
			if(wear_neck)
				return FALSE
			if( !(I.slot_flags & SLOT_NECK) )
				return FALSE
			return TRUE
		if(slot_head)
			if(head)
				return FALSE
			if( !(I.slot_flags & SLOT_HEAD) )
				return FALSE
			return TRUE
		if(slot_back)
			if(back)
				return FALSE
			if( !(I.slot_flags & SLOT_BACK) )
				return FALSE
			return TRUE
	return FALSE //Unsupported slot



