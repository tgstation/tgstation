/mob/living/carbon/alien/adult/death(gibbed)
	if(stat == DEAD)
		return

	. = ..()

	update_icons()
	status_flags |= CANPUSH

//When the alien queen dies, all others must pay the price for letting her die.
/mob/living/carbon/alien/adult/royal/queen/death(gibbed)
	if(stat == DEAD)
		return

	for(var/mob/living/carbon/C in GLOB.alive_mob_list)
		if(C == src) //Make sure not to proc it on ourselves.
			continue
		var/obj/item/organ/alien/hivenode/node = C.get_organ_by_type(/obj/item/organ/alien/hivenode)
		if(istype(node)) // just in case someone would ever add a diffirent node to hivenode slot
			node.queen_death()

	return ..()
