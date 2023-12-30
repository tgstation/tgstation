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

	// keep a record of the current high priest
	GLOB.current_highpriest = WEAKREF(spawned_chaplain)

/datum/religion_sect/on_select()
	. = ..()

	// if the same religious sect gets selected, carry the favor over
	if(istype(src, GLOB.prev_sect_type))
		set_favor(GLOB.prev_favor)
