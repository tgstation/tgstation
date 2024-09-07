/datum/job/chaplain/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	var/mob/living/carbon/human/spawned_chaplain = spawned
	
	// no mind? get out of here, this shouldn't be happening
	if(!spawned_chaplain.mind)
		return
		
	// if the mob is not a high priest, add to successors list
	if(spawned_chaplain.mind.holy_role != HOLY_ROLE_HIGHPRIEST)
		if(isnull(GLOB.holy_successors)) 
			GLOB.holy_successors = list()
		GLOB.holy_successors |= WEAKREF(spawned_chaplain)
		return

	// if the mob joins as a high priest (and there has been a previous high priest before them), make sure they get their own nullrod.
	if(isnull(GLOB.current_highpriest))
		spawned_chaplain.put_in_hands(new /obj/item/nullrod(spawned_chaplain))

	// keep a record of the current high priest
	GLOB.current_highpriest = WEAKREF(spawned_chaplain)
