//Monkey Overlays Indexes////////
#define M_MASK_LAYER			1
#define M_BACK_LAYER			2
#define M_HANDCUFF_LAYER		3
#define M_L_HAND_LAYER			4
#define M_R_HAND_LAYER			5
#define M_TOTAL_LAYERS			5
/////////////////////////////////

/mob/living/carbon/monkey
	var/list/overlays_lying[M_TOTAL_LAYERS]
	var/list/overlays_standing[M_TOTAL_LAYERS]

/mob/living/carbon/monkey/regenerate_icons()
	..()
	update_inv_wear_mask(0)
	update_inv_back(0)
	update_inv_r_hand(0)
	update_inv_l_hand(0)
	update_inv_handcuffed(0)
	update_icons()
	//Hud Stuff
	update_hud()
	return

/mob/living/carbon/monkey/update_icons()
	update_hud()
	lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again
	overlays = null
	if(lying)
		icon_state = "monkey0"
		for(var/image/I in overlays_lying)
			overlays += I
	else
		icon_state = "monkey1"
		for(var/image/I in overlays_standing)
			overlays += I


////////
/mob/living/carbon/monkey/update_inv_wear_mask(var/update_icons=1)
	if( wear_mask && istype(wear_mask, /obj/item/clothing/mask) )
		overlays_lying[M_MASK_LAYER]	= image("icon" = 'monkey.dmi', "icon_state" = "[wear_mask.icon_state]2")
		overlays_standing[M_MASK_LAYER]	= image("icon" = 'monkey.dmi', "icon_state" = "[wear_mask.icon_state]")
		wear_mask.screen_loc = ui_monkey_mask
	else
		overlays_lying[M_MASK_LAYER]	= null
		overlays_standing[M_MASK_LAYER]	= null
	if(update_icons)		update_icons()


/mob/living/carbon/monkey/update_inv_r_hand(var/update_icons=1)
	if(r_hand)
		var/t_state = r_hand.item_state
		if(!t_state)	t_state = r_hand.icon_state
		overlays_standing[M_R_HAND_LAYER]	= image("icon" = 'items_righthand.dmi', "icon_state" = t_state)
		r_hand.screen_loc = ui_rhand
	else
		overlays_standing[M_R_HAND_LAYER]	= null
	if(update_icons)		update_icons()


/mob/living/carbon/monkey/update_inv_l_hand(var/update_icons=1)
	if(l_hand)
		var/t_state = l_hand.item_state
		if(!t_state)	 t_state = l_hand.icon_state
		overlays_standing[M_L_HAND_LAYER]	= image("icon" = 'items_lefthand.dmi', "icon_state" = t_state)
		l_hand.screen_loc = ui_lhand
	else
		overlays_standing[M_L_HAND_LAYER]	= null
	if(update_icons)		update_icons()


/mob/living/carbon/monkey/update_inv_back(var/update_icons=1)
	if(back)
		overlays_lying[M_BACK_LAYER]	= image("icon" = 'back.dmi', "icon_state" = "[back.icon_state]2")
		overlays_standing[M_BACK_LAYER]	= image("icon" = 'back.dmi', "icon_state" = "[back.icon_state]")
		back.screen_loc = ui_monkey_back
	else
		overlays_lying[M_BACK_LAYER]	= null
		overlays_standing[M_BACK_LAYER]	= null
	if(update_icons)		update_icons()


/mob/living/carbon/monkey/update_inv_handcuffed(var/update_icons=1)
	if(handcuffed)
		pulling = null
		overlays_lying[M_HANDCUFF_LAYER]	= image("icon" = 'monkey.dmi', "icon_state" = "handcuff2")
		overlays_standing[M_HANDCUFF_LAYER]	= image("icon" = 'monkey.dmi', "icon_state" = "handcuff1")
	else
		overlays_lying[M_HANDCUFF_LAYER]	= null
		overlays_standing[M_HANDCUFF_LAYER]	= null
	if(update_icons)		update_icons()


/mob/living/carbon/monkey/update_hud()
	if (client)
		client.screen |= contents

//Monkey Overlays Indexes////////
#undef M_MASK_LAYER
#undef M_BACK_LAYER
#undef M_HANDCUFF_LAYER
#undef M_L_HAND_LAYER
#undef M_R_HAND_LAYER
#undef M_TOTAL_LAYERS

