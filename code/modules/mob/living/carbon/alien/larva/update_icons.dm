
/mob/living/carbon/alien/larva/regenerate_icons()
	overlays = list()
	update_icons()

/mob/living/carbon/alien/larva/update_icons()
	var/state = 0
	if(amount_grown > 150)
		state = 2
	else if(amount_grown > 50)
		state = 1

	if(stat == DEAD)
		icon_state = "larva[state]_dead"
	else if (handcuffed || legcuffed)
		icon_state = "larva[state]_cuff"
	else if (stunned)
		icon_state = "larva[state]_stun"
	else if(lying || resting)
		icon_state = "larva[state]_sleep"
	else
		icon_state = "larva[state]"
