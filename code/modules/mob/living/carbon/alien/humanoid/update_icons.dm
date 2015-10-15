
/mob/living/carbon/alien/humanoid/update_icons()
	update_hud()		//TODO: remove the need for this to be here
	overlays.Cut()
	for(var/image/I in overlays_standing)
		overlays += I

	if(stat == DEAD)
		//If we mostly took damage from fire
		if(fireloss > 125)
			icon_state = "alien[caste]_husked"
		else
			icon_state = "alien[caste]_dead"

	else if((stat == UNCONSCIOUS && !sleeping) || weakened)
		icon_state = "alien[caste]_unconscious"
	else if(leap_on_click)
		icon_state = "alien[caste]_pounce"

	else if(lying || resting || sleeping)
		icon_state = "alien[caste]_sleep"
	else if(m_intent != WALK)
		icon_state = "alien[caste]_running"
	else if(mob_size == MOB_SIZE_LARGE)
		icon_state = "alien[caste]"
	else
		icon_state = "alien[caste]_s"

	if(leaping)
		if(alt_icon == initial(alt_icon))
			var/old_icon = icon
			icon = alt_icon
			alt_icon = old_icon
		icon_state = "alien[caste]_leap"
		pixel_x = -32
		pixel_y = -32
	else
		if(alt_icon != initial(alt_icon))
			var/old_icon = icon
			icon = alt_icon
			alt_icon = old_icon
		pixel_x = get_standard_pixel_x_offset(lying)
		pixel_y = get_standard_pixel_y_offset(lying)

/mob/living/carbon/alien/humanoid/regenerate_icons()
	if(!..())
		update_hud()
	//	update_icons() //Handled in update_transform(), leaving this here as a reminder
		update_transform()

/mob/living/carbon/alien/humanoid/update_transform() //The old method of updating lying/standing was update_icons(). Aliens still expect that.
	if(lying > 0)
		lying = 90 //Anything else looks retarded
	..()
	update_icons()

//Royals have bigger sprites, so inhand things must be handled differently.
/mob/living/carbon/alien/humanoid/royal/update_inv_r_hand()
	..()
	remove_overlay(R_HAND_LAYER)
	if(r_hand)
		var/itm_state = r_hand.item_state
		if(!itm_state)
			itm_state = r_hand.icon_state

		var/image/I = image("icon" = alt_inhands_file , "icon_state"="[itm_state][caste]_r", "layer"=-R_HAND_LAYER)
		overlays_standing[R_HAND_LAYER] = I

		apply_overlay(R_HAND_LAYER)

/mob/living/carbon/alien/humanoid/royal/update_inv_l_hand()
	..()
	remove_overlay(L_HAND_LAYER)
	if(l_hand)
		var/itm_state = l_hand.item_state
		if(!itm_state)
			itm_state = l_hand.icon_state

		var/image/I = image("icon" = alt_inhands_file , "icon_state"="[itm_state][caste]_l", "layer"=-L_HAND_LAYER)
		overlays_standing[L_HAND_LAYER] = I

		apply_overlay(L_HAND_LAYER)