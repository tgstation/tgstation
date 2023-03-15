//quickswap items!

/mob/living/carbon/human/verb/equip_swap()//works similar to goon, will attempt to swap between held item and equipped item
	set hidden = 1
	var/obj/item/clothing/I = get_active_held_item()
	if (I)
		if(!equip_to_appropriate_slot(I))
			for(var/obj/item/clothing/inv in get_equipped_items())
				if(I.slot_flags & inv.slot_flags)
					if(inv.clothing_flags & NOTDROPPABLE)
						to_chat(usr, "<span class='userdanger'>[inv.nodrop_message]</span>")
						return
					if(putItemFromInventoryInHandIfPossible(inv, get_inactive_hand_index(), invdrop = FALSE))
						I.equip_to_best_slot(src)
		else
			update_inv_hands()
