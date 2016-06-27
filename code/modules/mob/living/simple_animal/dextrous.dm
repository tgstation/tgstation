//Simple animals with hands and the ability to use them.
/mob/living/simple_animal/dextrous
	icon = 'icons/mob/mob.dmi'
	icon_state = "adult roro"

/mob/living/simple_animal/dextrous/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/dextrous(src, ui_style2icon(client.prefs.UI_style))

/mob/living/simple_animal/dextrous/activate_hand(selhand)
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

/mob/living/simple_animal/dextrous/swap_hand()
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

/mob/living/simple_animal/dextrous/UnarmedAttack(atom/A, proximity)
	if(!ismob(A))
		A.attack_hand(src)
		update_hand_icons()

/mob/living/simple_animal/dextrous/proc/update_hand_icons()
	if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
		if(r_hand)
			r_hand.layer = ABOVE_HUD_LAYER
			r_hand.screen_loc = ui_rhand
			client.screen |= r_hand
		if(l_hand)
			l_hand.layer = ABOVE_HUD_LAYER
			l_hand.screen_loc = ui_lhand
			client.screen |= l_hand
