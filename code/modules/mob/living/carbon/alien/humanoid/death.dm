/mob/living/carbon/alien/humanoid/death(gibbed)
	if(stat == DEAD)
		return

	. = ..()

	update_icons()
	status_flags |= CANPUSH

//When the alien queen dies, all others must pay the price for letting her die.
/mob/living/carbon/alien/humanoid/royal/queen/death(gibbed)
	if(stat == DEAD)
		return

	for(var/mob/living/carbon/C in GLOB.alive_mob_list)
		if(C == src) //Make sure not to proc it on ourselves.
			continue
		var/obj/item/organ/alien/hivenode/node = C.getorgan(/obj/item/organ/alien/hivenode)
		if(istype(node)) // just in case someone would ever add a diffirent node to hivenode slot
			node.queen_death()

	. = ..()

	SSshuttle.clearHostileEnvironment(src)
	if(!mind)
		return
	var/datum/antagonist/xeno/xeno_datum = mind.has_antag_datum(/datum/antagonist/xeno)
	if(xeno_datum)
		xeno_datum.xeno_team.queen_deaths++
