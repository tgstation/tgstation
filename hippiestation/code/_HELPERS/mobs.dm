/proc/random_unique_moth_name(gender, attempts_to_find_unique_name=10)
	for(var/i=1, i<=attempts_to_find_unique_name, i++)
		. = capitalize(moth_name(gender))

		if(i != attempts_to_find_unique_name && !findname(.))
			break

/proc/slot_to_string(slot)
	switch(slot)
		if(slot_back)
			. = "Backpack"
		if(slot_wear_mask)
			. = "Mask"
		if(slot_hands)
			. = "Hands"
		if(slot_belt)
			. = "Belt"
		if(slot_ears)
			. = "Ears"
		if(slot_glasses)
			. = "Glasses"
		if(slot_gloves)
			. = "Gloves"
		if(slot_neck)
			. = "Neck"
		if(slot_head)
			. = "Head"
		if(slot_shoes)
			. = "Shoes"
		if(slot_wear_suit)
			. = "Suit"
		if(slot_w_uniform)
			. = "Jumpsuit"
		if(slot_in_backpack)
			. = "In backpack"