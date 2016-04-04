/mob/living/carbon/true_demon/activate_hand(selhand)

	if(istext(selhand))
		selhand = lowertext(selhand)

		if(selhand == "right" || selhand == "r")
			selhand = 0
		if(selhand == "left" || selhand == "l")
			selhand = 1

	if(selhand != src.hand)
		swap_hand()
	else
		mode()


/mob/living/carbon/true_demon/swap_hand()
	var/obj/item/held_item = get_active_hand()
	if(held_item)
		if(istype(held_item, /obj/item/weapon/twohanded))
			var/obj/item/weapon/twohanded/T = held_item
			if(T.wielded == 1)
				usr << "<span class='warning'>Your other hand is too busy holding the [T.name].</span>"
				return
	hand = !hand
	if(hud_used && hud_used.inv_slots[slot_l_hand] && hud_used.inv_slots[slot_r_hand])
		var/obj/screen/inventory/hand/H
		H = hud_used.inv_slots[slot_l_hand]
		H.update_icon()
		H = hud_used.inv_slots[slot_r_hand]
		H.update_icon()


/mob/living/carbon/true_demon/unEquip(obj/item/I, force)
	if(..(I,force))
		update_inv_hands()
		return 1
	return 0

/mob/living/carbon/true_demon/proc/update_inv_hands()
	//TODO LORDPIDEY:  Figure out how to make the hands line up properly.  the l/r_hand_image should use the down sprite when facing down, left, or right, and the up sprite when facing up.
	remove_overlay(DEMON_HANDS_LAYER)
	var/list/hands_overlays = list()

	if(r_hand)

		var/r_state = r_hand.item_state
		if(!r_state)
			r_state = r_hand.icon_state

		var/image/r_hand_image = r_hand.build_worn_icon(state = r_state, default_layer = DEMON_HANDS_LAYER, default_icon_file = r_hand.righthand_file, isinhands = TRUE)

		hands_overlays += r_hand_image

		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			r_hand.layer = 20
			r_hand.screen_loc = ui_rhand
			client.screen |= r_hand

	if(l_hand)

		var/l_state = l_hand.item_state
		if(!l_state)
			l_state = l_hand.icon_state

		var/image/l_hand_image = l_hand.build_worn_icon(state = l_state, default_layer = DEMON_HANDS_LAYER, default_icon_file = l_hand.lefthand_file, isinhands = TRUE)

		hands_overlays += l_hand_image

		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			l_hand.layer = 20
			l_hand.screen_loc = ui_lhand
			client.screen |= l_hand
	if(hands_overlays.len)
		demon_overlays[DEMON_HANDS_LAYER] = hands_overlays
	apply_overlay(DEMON_HANDS_LAYER)

/mob/living/carbon/true_demon/update_inv_l_hand()
	update_inv_hands()


/mob/living/carbon/true_demon/update_inv_r_hand()
	update_inv_hands()

/mob/living/carbon/true_demon/remove_overlay(cache_index)
	if(demon_overlays[cache_index])
		overlays -= demon_overlays[cache_index]
		demon_overlays[cache_index] = null


/mob/living/carbon/true_demon/apply_overlay(cache_index)
	var/image/I = demon_overlays[cache_index]
	if(I)
		overlays += I