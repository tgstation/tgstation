
/mob/living/carbon/alien/larva/regenerate_icons()
	cut_overlays()
	update_icons()

/mob/living/carbon/alien/larva/update_icons()
	var/state = 0
	if(amount_grown > 80)
		state = 2
	else if(amount_grown > 50)
		state = 1

	if(stat == DEAD)
		icon_state = "larva[state]_dead"
	else if(handcuffed || legcuffed) //This should be an overlay. Who made this an icon_state?
		icon_state = "larva[state]_cuff"
	else if(HAS_TRAIT(src, TRAIT_INCAPACITATED))
		icon_state = "larva[state]_stun"
	else if(body_position == LYING_DOWN)
		icon_state = "larva[state]_sleep"
	else
		icon_state = "larva[state]"

/mob/living/carbon/alien/larva/perform_update_transform() //All this is handled in update_icons()
	. = ..()
	update_icons()

/mob/living/carbon/alien/larva/update_worn_handcuffs()
	update_icons() //larva icon_state changes if cuffed/uncuffed.


/mob/living/carbon/alien/larva/lying_angle_on_lying_down(new_lying_angle)
	return // Larvas don't rotate on lying down, they have their own custom icons.
