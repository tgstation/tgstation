
/mob/living/carbon/monkey/regenerate_icons()
	if(!..())
		update_inv_wear_mask()
		update_inv_head()
		update_inv_back()
		update_icons()
		update_transform()
		//Hud Stuff
		update_hud()

/mob/living/carbon/monkey/update_icons()
	update_hud()
	overlays.Cut()
	icon_state = "monkey1"
	for(var/image/I in overlays_standing)
		overlays += I

////////
/mob/living/carbon/monkey/update_inv_wear_mask()
	var/obj/item/clothing/mask/M = ..()
	if(M)
		M.screen_loc = ui_monkey_mask
		if(client && hud_used)
			client.screen += M
	apply_overlay(FACEMASK_LAYER)


/mob/living/carbon/monkey/update_inv_head()
	var/obj/item/H = ..()
	if(H)
		H.screen_loc = ui_monkey_head
		if(client && hud_used)
			client.screen += H
	apply_overlay(HEAD_LAYER)

/mob/living/carbon/monkey/update_inv_back()
	var/obj/item/B = ..()
	if(B)
		B.screen_loc = ui_monkey_back
		if(client && hud_used)
			client.screen += B
	apply_overlay(BACK_LAYER)

/mob/living/carbon/monkey/update_fire()
	..("Monkey_burning")

/mob/living/carbon/monkey/update_inv_handcuffed()
	if(..())
		overlays_standing[HANDCUFF_LAYER] = image("icon"='icons/mob/mob.dmi', "icon_state"="handcuff1", "layer"=-HANDCUFF_LAYER)
		apply_overlay(HANDCUFF_LAYER)

/mob/living/carbon/monkey/update_inv_legcuffed()
	remove_overlay(LEGCUFF_LAYER)
	if(legcuffed)
		var/image/standing = image("icon"='icons/mob/mob.dmi', "icon_state"="legcuff1", "layer"=-LEGCUFF_LAYER)
		standing.pixel_y = 8
		overlays_standing[LEGCUFF_LAYER] = standing
	apply_overlay(LEGCUFF_LAYER)