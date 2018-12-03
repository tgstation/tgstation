/mob/living/carbon/monkey/can_equip(obj/item/I, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	switch(slot)
		if(SLOT_HANDS)
			if(get_empty_held_indexes())
				return TRUE
			return FALSE
		if(SLOT_WEAR_MASK)
			if(wear_mask)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_MASK) )
				return FALSE
			return TRUE
		if(SLOT_NECK)
			if(wear_neck)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_NECK) )
				return FALSE
			return TRUE
		if(SLOT_HEAD)
			if(head)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_HEAD) )
				return FALSE
			return TRUE
		if(SLOT_BACK)
			if(back)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_BACK) )
				return FALSE
			return TRUE
	return FALSE //Unsupported slot



