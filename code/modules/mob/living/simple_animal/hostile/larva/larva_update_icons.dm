
/mob/living/simple_animal/hostile/alien_larva/regenerate_icons()
	cut_overlays()
	update_icons()

/mob/living/simple_animal/hostile/alien_larva/update_icons()
	var/state = 0
	if(amount_grown > 80)
		state = 2
	else if(amount_grown > 50)
		state = 1

	if(stat == DEAD)
		icon_state = "larva[state]_dead"
	if(HAS_TRAIT(src, TRAIT_INCAPACITATED))
		icon_state = "larva[state]_stun"
	else if(body_position == LYING_DOWN)
		icon_state = "larva[state]_sleep"
	else
		icon_state = "larva[state]"

/mob/living/simple_animal/hostile/alien_larva/perform_update_transform() //All this is handled in update_icons()
	. = ..()
	update_icons()
