/mob/living/carbon/alien/humanoid/death(gibbed)
	if(stat == DEAD)
		return

	stat = DEAD

	if(!gibbed)
		playsound(loc, 'sound/voice/hiss6.ogg', 80, 1, 1)
		visible_message("<span class='name'>[src]</span> lets out a waning guttural screech, green blood bubbling from its maw...")
		update_canmove()
		update_icons()
		status_flags |=CANPUSH

	return ..(gibbed)

//When the alien queen dies, all others must pay the price for letting her die.
/mob/living/carbon/alien/humanoid/royal/queen/death(gibbed)
	if(stat == DEAD)
		return

	for(var/mob/living/carbon/C in living_mob_list)
		if(C == src) //Make sure not to proc it on ourselves.
			continue
		var/obj/item/organ/internal/alien/hivenode/node = C.getorgan(/obj/item/organ/internal/alien/hivenode)
		if(istype(node)) // just in case someone would ever add a diffirent node to hivenode slot
			node.queen_death()

	return ..(gibbed)