/mob/living/carbon/alien/larva/death(gibbed)
	if(stat == DEAD)
		return
	stat = DEAD
	icon_state = "larva_dead"

	if(!gibbed)
		visible_message("<span class='name'>[src]</span> lets out a waning high-pitched cry.")

	return ..(gibbed)
