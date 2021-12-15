
/mob/living/carbon/human/species/alien/update_icons()
	cut_overlays()
	for(var/I in overlays_standing)
		add_overlay(I)

	var/asleep = IsSleeping()
	if(stat == DEAD)
		//If we mostly took damage from fire
		if(getFireLoss() > 125)
			icon_state = "alien[caste]_husked"
		else
			icon_state = "alien[caste]_dead"

	else if((stat == UNCONSCIOUS && !asleep) || stat == HARD_CRIT || stat == SOFT_CRIT || IsParalyzed())
		icon_state = "alien[caste]_unconscious"

	else if(body_position == LYING_DOWN)
		icon_state = "alien[caste]_sleep"
	else if(mob_size == MOB_SIZE_LARGE)
		icon_state = "alien[caste]"
		if(drooling)
			add_overlay("alienspit_[caste]")
	else
		icon_state = "alien[caste]"
		if(drooling)
			add_overlay("alienspit")

	pixel_x = base_pixel_x + body_position_pixel_x_offset
	pixel_y = base_pixel_y + body_position_pixel_y_offset
	update_inv_hands()
	update_inv_handcuffed()

//Royals have bigger sprites, so inhand things must be handled differently.
/mob/living/carbon/human/species/alien/royal/update_inv_hands()
	..()
	remove_overlay(HANDS_LAYER)
	var/list/hands = list()

	var/obj/item/l_hand = get_item_for_held_index(1)
	if(l_hand)
		var/itm_state = l_hand.inhand_icon_state
		if(!itm_state)
			itm_state = l_hand.icon_state
		var/mutable_appearance/l_hand_item = mutable_appearance(alt_inhands_file, "[itm_state][caste]_l", -HANDS_LAYER)
		if(l_hand.blocks_emissive)
			l_hand_item.overlays += emissive_blocker(l_hand_item.icon, l_hand_item.icon_state, alpha = l_hand_item.alpha)
		hands += l_hand_item

	var/obj/item/r_hand = get_item_for_held_index(2)
	if(r_hand)
		var/itm_state = r_hand.inhand_icon_state
		if(!itm_state)
			itm_state = r_hand.icon_state
		var/mutable_appearance/r_hand_item = mutable_appearance(alt_inhands_file, "[itm_state][caste]_r", -HANDS_LAYER)
		if(r_hand.blocks_emissive)
			r_hand_item.overlays += emissive_blocker(r_hand_item.icon, r_hand_item.icon_state, alpha = r_hand_item.alpha)
		hands += r_hand_item

	overlays_standing[HANDS_LAYER] = hands
	apply_overlay(HANDS_LAYER)
