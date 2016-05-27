/mob/living/carbon/true_devil/unEquip(obj/item/I, force)
	if(..(I,force))
		update_inv_hands()
		return 1
	return 0

/mob/living/carbon/true_devil/proc/update_inv_hands()
	//TODO LORDPIDEY:  Figure out how to make the hands line up properly.  the l/r_hand_image should use the down sprite when facing down, left, or right, and the up sprite when facing up.
	remove_overlay(DEVIL_HANDS_LAYER)
	var/list/hands_overlays = list()

	if(r_hand)

		var/r_state = r_hand.item_state
		if(!r_state)
			r_state = r_hand.icon_state

		var/image/r_hand_image = r_hand.build_worn_icon(state = r_state, default_layer = DEVIL_HANDS_LAYER, default_icon_file = r_hand.righthand_file, isinhands = TRUE)

		hands_overlays += r_hand_image

		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			r_hand.layer = ABOVE_HUD_LAYER
			r_hand.screen_loc = ui_rhand
			client.screen |= r_hand

	if(l_hand)

		var/l_state = l_hand.item_state
		if(!l_state)
			l_state = l_hand.icon_state

		var/image/l_hand_image = l_hand.build_worn_icon(state = l_state, default_layer = DEVIL_HANDS_LAYER, default_icon_file = l_hand.lefthand_file, isinhands = TRUE)

		hands_overlays += l_hand_image

		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			l_hand.layer = ABOVE_HUD_LAYER
			l_hand.screen_loc = ui_lhand
			client.screen |= l_hand
	if(hands_overlays.len)
		devil_overlays[DEVIL_HANDS_LAYER] = hands_overlays
	apply_overlay(DEVIL_HANDS_LAYER)

/mob/living/carbon/true_devil/update_inv_l_hand()
	update_inv_hands()


/mob/living/carbon/true_devil/update_inv_r_hand()
	update_inv_hands()

/mob/living/carbon/true_devil/remove_overlay(cache_index)
	if(devil_overlays[cache_index])
		overlays -= devil_overlays[cache_index]
		devil_overlays[cache_index] = null


/mob/living/carbon/true_devil/apply_overlay(cache_index)
	var/image/I = devil_overlays[cache_index]
	if(I)
		overlays += I