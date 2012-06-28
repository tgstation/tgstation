//Xeno Overlays Indexes//////////
#define X_HEAD_LAYER			1
#define X_SUIT_LAYER			2
#define X_L_HAND_LAYER			3
#define X_R_HAND_LAYER			4
#define X_TOTAL_LAYERS			4
/////////////////////////////////

/mob/living/carbon/alien/humanoid
	var/list/overlays_lying[X_TOTAL_LAYERS]
	var/list/overlays_standing[X_TOTAL_LAYERS]

/mob/living/carbon/alien/humanoid/update_icons()
	lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again
	update_hud()		//TODO: remove the need for this to be here
	overlays = null
	if(lying)
		if(resting)					icon_state = "alien[caste]_sleep"
		else						icon_state = "alien[caste]_l"
		for(var/image/I in overlays_lying)
			overlays += I
	else
		if(m_intent == "run")		icon_state = "alien[caste]_running"
		else						icon_state = "alien[caste]_s"
		for(var/image/I in overlays_standing)
			overlays += I

/mob/living/carbon/alien/humanoid/regenerate_icons()
	..()
	if (monkeyizing)	return

	update_inv_head(0)
	update_inv_wear_suit(0)
	update_inv_r_hand(0)
	update_inv_l_hand(0)
	update_inv_pockets(0)
	update_hud()
	update_icons()


/mob/living/carbon/alien/humanoid/update_hud()
	//TODO
	if (client)
//		if(other)	client.screen |= hud_used.other		//Not used
//		else		client.screen -= hud_used.other		//Not used
		client.screen |= contents



/mob/living/carbon/alien/humanoid/update_inv_wear_suit(var/update_icons=1)
	if(wear_suit)
		var/t_state = wear_suit.item_state
		if(!t_state)	t_state = wear_suit.icon_state
		var/image/lying		= image("icon" = 'mob.dmi', "icon_state" = "[t_state]2")
		var/image/standing	= image("icon" = 'mob.dmi', "icon_state" = "[t_state]")

		if(wear_suit.blood_DNA)
			var/t_suit = "suit"
			if( istype(wear_suit, /obj/item/clothing/suit/armor) )
				t_suit = "armor"
			lying.overlays		+= image("icon" = 'blood.dmi', "icon_state" = "[t_suit]blood2")
			standing.overlays	+= image("icon" = 'blood.dmi', "icon_state" = "[t_suit]blood")

		//TODO
		wear_suit.screen_loc = ui_alien_oclothing
		if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
			if (handcuffed)
				handcuffed.loc = loc
				handcuffed.layer = initial(handcuffed.layer)
				handcuffed = null
			if ((l_hand || r_hand))
				drop_item()
				hand = !hand
				drop_item()
				hand = !hand

		overlays_lying[X_SUIT_LAYER]	= lying
		overlays_standing[X_SUIT_LAYER]	= standing
	else
		overlays_lying[X_SUIT_LAYER]	= null
		overlays_standing[X_SUIT_LAYER]	= null
	if(update_icons)	update_icons()


/mob/living/carbon/alien/humanoid/update_inv_head(var/update_icons=1)
	if (head)
		var/t_state = head.item_state
		if(!t_state)	t_state = head.icon_state
		var/image/lying		= image("icon" = 'mob.dmi', "icon_state" = "[t_state]2")
		var/image/standing	= image("icon" = 'mob.dmi', "icon_state" = "[t_state]")
		if(head.blood_DNA)
			lying.overlays		+= image("icon" = 'blood.dmi', "icon_state" = "helmetblood2")
			standing.overlays	+= image("icon" = 'blood.dmi', "icon_state" = "helmetblood")
		head.screen_loc = ui_alien_head
		overlays_lying[X_HEAD_LAYER]	= lying
		overlays_standing[X_HEAD_LAYER]	= standing
	else
		overlays_lying[X_HEAD_LAYER]	= null
		overlays_standing[X_HEAD_LAYER]	= null
	if(update_icons)	update_icons()


/mob/living/carbon/alien/humanoid/update_inv_pockets(var/update_icons=1)
	if(l_store)		l_store.screen_loc = ui_storage1
	if(r_store)		r_store.screen_loc = ui_storage2
	if(update_icons)	update_icons()


/mob/living/carbon/alien/humanoid/update_inv_r_hand(var/update_icons=1)
	if(r_hand)
		var/t_state = r_hand.item_state
		if(!t_state)	t_state = r_hand.icon_state
		r_hand.screen_loc = ui_rhand
		overlays_standing[X_R_HAND_LAYER]	= image("icon" = 'items_righthand.dmi', "icon_state" = t_state)
	else
		overlays_standing[X_R_HAND_LAYER]	= null
	if(update_icons)	update_icons()

/mob/living/carbon/alien/humanoid/update_inv_l_hand(var/update_icons=1)
	if(l_hand)
		var/t_state = l_hand.item_state
		if(!t_state)	t_state = l_hand.icon_state
		l_hand.screen_loc = ui_lhand
		overlays_standing[X_L_HAND_LAYER]	= image("icon" = 'items_lefthand.dmi', "icon_state" = t_state)
	else
		overlays_standing[X_L_HAND_LAYER]	= null
	if(update_icons)	update_icons()


//Xeno Overlays Indexes//////////
#undef X_HEAD_LAYER
#undef X_SUIT_LAYER
#undef X_L_HAND_LAYER
#undef X_R_HAND_LAYER
#undef X_TOTAL_LAYERS
