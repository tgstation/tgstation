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
	if(hud_used.l_hand_hud_object && hud_used.r_hand_hud_object)
		if(hand)
			hud_used.l_hand_hud_object.icon_state = "hand_l_active"
			hud_used.r_hand_hud_object.icon_state = "hand_r_inactive"
		else
			hud_used.l_hand_hud_object.icon_state = "hand_l_inactive"
			hud_used.r_hand_hud_object.icon_state = "hand_r_active"


/mob/living/carbon/true_demon/unEquip(obj/item/I, force)
	if(..(I,force))
		update_inv_hands()
		return 1
	return 0

/mob/living/carbon/true_demon/stripPanelUnequip(obj/item/what, mob/who, where)
	..(what, who, where, 1)

/mob/living/carbon/true_demon/stripPanelEquip(obj/item/what, mob/who, where)
	..(what, who, where, 1)