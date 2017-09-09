/proc/random_unique_moth_name(gender, attempts_to_find_unique_name=10)
	for(var/i=1, i<=attempts_to_find_unique_name, i++)
		. = capitalize(moth_name(gender))

		if(i != attempts_to_find_unique_name && !findname(.))
			break

/proc/slot_to_string(slot)
	switch(slot)
		if(slot_back)
			return "Backpack"
		if(slot_wear_mask)
			return "Mask"
		if(slot_hands)
			return "Hands"
		if(slot_belt)
			return "Belt"
		if(slot_ears)
			return "Ears"
		if(slot_glasses)
			return "Glasses"
		if(slot_gloves)
			return "Gloves"
		if(slot_neck)
			return "Neck"
		if(slot_head)
			return "Head"
		if(slot_shoes)
			return "Shoes"
		if(slot_wear_suit)
			return "Suit"
		if(slot_w_uniform)
			return "Jumpsuit"
		if(slot_in_backpack)
			return "In backpack"