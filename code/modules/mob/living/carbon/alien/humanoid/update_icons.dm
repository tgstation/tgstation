//Xeno Overlays Indexes//////////
#define X_L_HAND_LAYER			1
#define X_R_HAND_LAYER			2
#define X_FIRE_LAYER			3
#define X_TOTAL_LAYERS			3
/////////////////////////////////

/mob/living/carbon/alien/humanoid
	var/list/overlays_standing[X_TOTAL_LAYERS]

/mob/living/carbon/alien/humanoid/update_icons()
	update_hud()		//TODO: remove the need for this to be here
	overlays.Cut()
	for(var/image/I in overlays_standing)
		overlays += I


	if(stat == DEAD)
		//If we mostly took damage from fire
		if(fireloss > 125)
			icon_state = "alien[caste]_husked"
			pixel_y = 0
		else
			icon_state = "alien[caste]_dead"
			pixel_y = 0
	else if(stat == UNCONSCIOUS || weakened)
		icon_state = "alien[caste]_unconscious"
		pixel_y = 0
	else if(lying || resting)
		icon_state = "alien[caste]_sleep"
	else if(m_intent == "run")
		icon_state = "alien[caste]_running"
	else
		icon_state = "alien[caste]_s"

	if(leap_on_click)
		icon_state = "alien[caste]_pounce"

	if(leaping)
		icon = 'icons/mob/alienleap.dmi'
		icon_state = "alien[caste]_leap"
		pixel_x = -32
		pixel_y = -32
	else
		icon = initial(icon)
		pixel_x = initial(pixel_x)
		pixel_y = initial(pixel_y)



/mob/living/carbon/alien/humanoid/regenerate_icons()
	..()
	if (notransform)	return

	update_inv_r_hand(0)
	update_inv_l_hand(0)
	update_hud()
//	update_icons() //Handled in update_transform(), leaving this here as a reminder
	update_fire()
	update_transform()

/mob/living/carbon/alien/humanoid/update_transform() //The old method of updating lying/standing was update_icons(). Aliens still expect that.
	if(lying > 0)
		lying = 90 //Anything else looks retarded
	update_icons()
	..()


/mob/living/carbon/alien/humanoid/update_hud()
	if(client)
		client.screen |= contents


/mob/living/carbon/alien/humanoid/update_inv_r_hand(update_icons = 1)
	if(r_hand)
		var/t_state = r_hand.item_state
		if(!t_state)
			t_state = r_hand.icon_state
		r_hand.screen_loc = ui_rhand
		overlays_standing[X_R_HAND_LAYER]	= image("icon" = 'icons/mob/items_righthand.dmi', "icon_state" = t_state)
	else
		overlays_standing[X_R_HAND_LAYER]	= null
	if(update_icons)
		update_icons()

/mob/living/carbon/alien/humanoid/update_inv_l_hand(update_icons = 1)
	if(l_hand)
		var/t_state = l_hand.item_state
		if(!t_state)
			t_state = l_hand.icon_state
		l_hand.screen_loc = ui_lhand
		overlays_standing[X_L_HAND_LAYER]	= image("icon" = 'icons/mob/items_lefthand.dmi', "icon_state" = t_state)
	else
		overlays_standing[X_L_HAND_LAYER]	= null
	if(update_icons)
		update_icons()

/mob/living/carbon/alien/humanoid/update_fire()
	overlays -= overlays_standing[X_FIRE_LAYER]
	if(on_fire)
		overlays_standing[X_FIRE_LAYER] = image("icon"='icons/mob/OnFire.dmi', "icon_state"="Standing", "layer"= -X_FIRE_LAYER)
		overlays += overlays_standing[X_FIRE_LAYER]
		return
	else
		overlays_standing[X_FIRE_LAYER] = null

//Xeno Overlays Indexes//////////
#undef X_L_HAND_LAYER
#undef X_R_HAND_LAYER
#undef X_FIRE_LAYER
#undef X_TOTAL_LAYERS
