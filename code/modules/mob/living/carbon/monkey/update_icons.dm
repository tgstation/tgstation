//Monkey Overlays Indexes////////
#define M_FIRE_LAYER			7
#define M_MASK_LAYER			6
#define M_HEAD_LAYER			5
#define M_BACK_LAYER			4
#define M_HANDCUFF_LAYER		3
#define M_L_HAND_LAYER			2
#define M_R_HAND_LAYER			1
#define M_TOTAL_LAYERS			7
/////////////////////////////////

/mob/living/carbon/monkey
	var/list/overlays_standing[M_TOTAL_LAYERS]

/mob/living/carbon/monkey/regenerate_icons()
	..()
	update_inv_wear_mask(0)
	update_inv_head(0)
	update_inv_back(0)
	update_inv_r_hand(0)
	update_inv_l_hand(0)
	update_inv_handcuffed(0)
	update_fire()
	update_icons()
	update_transform()
	//Hud Stuff
	update_hud()
	return

/mob/living/carbon/monkey/update_icons()
	update_hud()
	overlays.Cut()
	icon_state = "monkey1"
	for(var/image/I in overlays_standing)
		overlays += I

////////
/mob/living/carbon/monkey/update_inv_wear_mask(var/update_icons=1)
	if(wear_mask && istype(wear_mask, /obj/item/clothing/mask) )
		wear_mask.screen_loc = ui_monkey_mask
		if(client && hud_used)
			client.screen += wear_mask
		overlays -= overlays_standing[M_MASK_LAYER]
		var/image/standing	= image("icon" = 'icons/mob/mask.dmi', "icon_state" = "[wear_mask.icon_state]", "layer" = -M_MASK_LAYER)
		if(!istype(wear_mask, /obj/item/clothing/mask/cigarette) && wear_mask.blood_DNA )
			standing.overlays	+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "maskblood")
		overlays_standing[M_MASK_LAYER]	= standing
		overlays += overlays_standing[M_MASK_LAYER]
	else
		overlays -= overlays_standing[M_MASK_LAYER]
		overlays_standing[M_MASK_LAYER]	= null
	if(update_icons)		update_icons()


/mob/living/carbon/monkey/update_inv_head(var/update_icons=1)
	if(head)
		head.screen_loc = ui_monkey_head
		if(client && hud_used)
			client.screen += head
		overlays -= overlays_standing[M_HEAD_LAYER]
		var/image/standing	= image("icon" = 'icons/mob/head.dmi', "icon_state" = "[head.icon_state]", "layer" = -M_HEAD_LAYER)
		overlays_standing[M_HEAD_LAYER]	= standing
		overlays += overlays_standing[M_HEAD_LAYER]
	else
		overlays -= overlays_standing[M_HEAD_LAYER]
		overlays_standing[M_HEAD_LAYER]	= null
	if(update_icons)		update_icons()


/mob/living/carbon/monkey/update_inv_r_hand(var/update_icons=1)
	if (handcuffed)
		drop_r_hand()
		return
	if(r_hand)
		r_hand.screen_loc = ui_rhand
		if(client && hud_used)
			client.screen += r_hand
		var/t_state = r_hand.item_state
		if(!t_state)	t_state = r_hand.icon_state
		overlays -= overlays_standing[M_R_HAND_LAYER]
		var/image/standing = image("icon" = r_hand.righthand_file, "icon_state" = t_state, "layer" = -M_R_HAND_LAYER)
		standing.pixel_y = 2
		overlays_standing[M_R_HAND_LAYER]	= standing
		overlays += overlays_standing[M_R_HAND_LAYER]
	else
		overlays -= overlays_standing[M_R_HAND_LAYER]
		overlays_standing[M_R_HAND_LAYER]	= null
	if(update_icons)		update_icons()


/mob/living/carbon/monkey/update_inv_l_hand(var/update_icons=1)
	if (handcuffed)
		drop_l_hand()
		return
	if(l_hand)
		l_hand.screen_loc = ui_lhand
		if(client && hud_used)
			client.screen += l_hand
		var/t_state = l_hand.item_state
		if(!t_state)	 t_state = l_hand.icon_state
		overlays -= overlays_standing[M_L_HAND_LAYER]
		var/image/standing = image("icon" = l_hand.lefthand_file, "icon_state" = t_state, "layer" = -M_L_HAND_LAYER)
		standing.pixel_y = 2
		overlays_standing[M_L_HAND_LAYER]	= standing
		overlays += overlays_standing[M_L_HAND_LAYER]
	else
		overlays -= overlays_standing[M_L_HAND_LAYER]
		overlays_standing[M_L_HAND_LAYER]	= null
	if(update_icons)		update_icons()


/mob/living/carbon/monkey/update_inv_back(var/update_icons=1)
	if(back)
		back.screen_loc = ui_monkey_back
		if(client && hud_used)
			client.screen += back
		overlays -= overlays_standing[M_BACK_LAYER]
		overlays_standing[M_BACK_LAYER]	= image("icon" = 'icons/mob/back.dmi', "icon_state" = "[back.icon_state]", "layer" = -M_BACK_LAYER)
		overlays += overlays_standing[M_BACK_LAYER]
	else
		overlays -= overlays_standing[M_BACK_LAYER]
		overlays_standing[M_BACK_LAYER]	= null
	if(update_icons)		update_icons()


/mob/living/carbon/monkey/update_inv_handcuffed(var/update_icons=1)
	if(handcuffed)
		drop_r_hand()
		drop_l_hand()
		stop_pulling()
		if(hud_used)	//hud handcuff icons
			var/obj/screen/inventory/R = hud_used.adding[4]
			var/obj/screen/inventory/L = hud_used.adding[5]
			R.overlays += image("icon" = 'icons/mob/screen_gen.dmi', "icon_state" = "markus")
			L.overlays += image("icon" = 'icons/mob/screen_gen.dmi', "icon_state" = "gabrielle")
		overlays -= overlays_standing[M_HANDCUFF_LAYER]
		overlays_standing[M_HANDCUFF_LAYER]	= image("icon" = 'icons/mob/monkey.dmi', "icon_state" = "handcuff1", "layer" = -M_HANDCUFF_LAYER)
		overlays += overlays_standing[M_HANDCUFF_LAYER]
	else
		if(hud_used)
			var/obj/screen/inventory/R = hud_used.adding[4]
			var/obj/screen/inventory/L = hud_used.adding[5]
			R.overlays = null
			L.overlays = null
		overlays -= overlays_standing[M_HANDCUFF_LAYER]
		overlays_standing[M_HANDCUFF_LAYER]	= null
	if(update_icons)		update_icons()


/mob/living/carbon/monkey/update_hud()
	if(client)
		client.screen |= contents

/mob/living/carbon/monkey/update_fire()
	overlays -= overlays_standing[M_FIRE_LAYER]
	if(on_fire)
		overlays_standing[M_FIRE_LAYER] = image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing", "layer"= -M_FIRE_LAYER)
		overlays += overlays_standing[M_FIRE_LAYER]
		return
	else
		overlays_standing[M_FIRE_LAYER] = null


//Monkey Overlays Indexes////////
#undef M_FIRE_LAYER
#undef M_MASK_LAYER
#undef M_BACK_LAYER
#undef M_HANDCUFF_LAYER
#undef M_L_HAND_LAYER
#undef M_R_HAND_LAYER
#undef M_TOTAL_LAYERS

