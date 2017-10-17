/mob/living/carbon/monkey/can_equip(obj/item/I, slot, disable_warning = 0)
	switch(slot)
		if(slot_hands)
			if(get_empty_held_indexes())
				return EQUIP_ABLE
			return EQUIP_UNABLE
		if(slot_wear_mask)
			if(wear_mask)
				return EQUIP_UNABLE
			if( !(I.slot_flags & SLOT_MASK) )
				return EQUIP_UNABLE
			return EQUIP_ABLE
		if(slot_neck)
			if(wear_neck)
				return EQUIP_UNABLE
			if( !(I.slot_flags & SLOT_NECK) )
				return EQUIP_UNABLE
			return EQUIP_ABLE
		if(slot_head)
			if(head)
				return EQUIP_UNABLE
			if( !(I.slot_flags & SLOT_HEAD) )
				return EQUIP_UNABLE
			return EQUIP_ABLE
		if(slot_back)
			if(back)
				return EQUIP_UNABLE
			if( !(I.slot_flags & SLOT_BACK) )
				return EQUIP_UNABLE
			return EQUIP_ABLE
	return EQUIP_UNABLE //Unsupported slot
