
/mob/living/carbon/monkey/regenerate_icons()
	if(!..())
		update_inv_wear_mask()
		update_inv_head()
		update_inv_back()
		update_icons()
		update_transform()

/mob/living/carbon/monkey/update_icons()
	cut_overlays()
	icon_state = "monkey1"
	for(var/image/I in overlays_standing)
		add_overlay(I)

////////

/mob/living/carbon/monkey/update_fire()
	..("Monkey_burning")

/mob/living/carbon/monkey/update_inv_handcuffed()
	remove_overlay(HANDCUFF_LAYER)
	if(handcuffed)
		overlays_standing[HANDCUFF_LAYER] = image("icon"='icons/mob/mob.dmi', "icon_state"="handcuff1", "layer"=-HANDCUFF_LAYER)
		apply_overlay(HANDCUFF_LAYER)

/mob/living/carbon/monkey/update_inv_legcuffed()
	remove_overlay(LEGCUFF_LAYER)
	if(legcuffed)
		var/image/standing = image("icon"='icons/mob/mob.dmi', "icon_state"="legcuff1", "layer"=-LEGCUFF_LAYER)
		standing.pixel_y = 8
		overlays_standing[LEGCUFF_LAYER] = standing
	apply_overlay(LEGCUFF_LAYER)


//monkey HUD updates for items in our inventory

//update whether our head item appears on our hud.
/mob/living/carbon/monkey/update_hud_head(obj/item/I)
	if(client && hud_used && hud_used.hud_shown)
		I.screen_loc = ui_monkey_head
		client.screen += I

//update whether our mask item appears on our hud.
/mob/living/carbon/monkey/update_hud_wear_mask(obj/item/I)
	if(client && hud_used && hud_used.hud_shown)
		I.screen_loc = ui_monkey_mask
		client.screen += I

//update whether our back item appears on our hud.
/mob/living/carbon/monkey/update_hud_back(obj/item/I)
	if(client && hud_used && hud_used.hud_shown)
		I.screen_loc = ui_monkey_back
		client.screen += I