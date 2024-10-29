/mob/living/carbon/death(gibbed)
	if(stat == DEAD)
		return

	losebreath = 0
	breathing_loop.stop() //This would've happened eventually but it's nice to make it stop immediatelly in this case
	if(!gibbed)
		add_memory_in_range(src, 7, /datum/memory/witnessed_death, protagonist = src)
	reagents.end_metabolization(src)

	. = ..()

	if(!gibbed && !QDELING(src)) //double check they didn't start getting deleted in ..()
		attach_rot()

	for(var/T in get_traumas())
		var/datum/brain_trauma/BT = T
		BT.on_death()

/mob/living/carbon/gib(drop_bitflags=NONE)
	add_memory_in_range(src, 7, /datum/memory/witness_gib, protagonist = src)
	if(drop_bitflags & DROP_ITEMS)
		for(var/obj/item/W in src)
			if(dropItemToGround(W))
				if(prob(50))
					step(W, pick(GLOB.alldirs))
	var/atom/Tsec = drop_location()
	for(var/mob/M in src)
		M.forceMove(Tsec)
		visible_message(span_danger("[M] bursts out of [src]!"))
	return ..()

/mob/living/carbon/spill_organs(drop_bitflags=NONE)
	var/atom/Tsec = drop_location()

	for(var/obj/item/organ/organ as anything in organs)
		if((drop_bitflags & DROP_BRAIN) && istype(organ, /obj/item/organ/internal/brain))
			if((drop_bitflags & DROP_BODYPARTS) && (check_zone(organ.zone) != BODY_ZONE_CHEST)) // chests can't drop
				continue // the head will drop, so the brain should stay inside

			organ.Remove(src)
			organ.forceMove(Tsec)
			organ.throw_at(get_edge_target_turf(src, pick(GLOB.alldirs)), rand(1,3), 5)
			continue

		if((drop_bitflags & DROP_ORGANS) && !istype(organ, /obj/item/organ/internal/brain))
			if((drop_bitflags & DROP_BODYPARTS) && (check_zone(organ.zone) != BODY_ZONE_CHEST))
				continue // only chest & groin organs will be ejected

			organ.Remove(src)
			organ.forceMove(Tsec)
			organ.throw_at(get_edge_target_turf(src, pick(GLOB.alldirs)), rand(1,3), 5)
			continue

		qdel(organ)

/mob/living/carbon/spread_bodyparts(drop_bitflags=NONE)
	for(var/obj/item/bodypart/part as anything in bodyparts)
		if(!(drop_bitflags & DROP_BRAIN) && part.body_zone == BODY_ZONE_HEAD)
			continue
		else if(part.body_zone == BODY_ZONE_CHEST)
			continue
		part.drop_limb()
		part.throw_at(get_edge_target_turf(src, pick(GLOB.alldirs)), rand(1,3), 5)

/mob/living/carbon/set_suicide(suicide_state) //you thought that box trick was pretty clever, didn't you? well now hardmode is on, boyo.
	. = ..()
	var/obj/item/organ/internal/brain/userbrain = get_organ_slot(ORGAN_SLOT_BRAIN)
	if(userbrain)
		userbrain.suicided = suicide_state

/mob/living/carbon/can_suicide()
	if(!..())
		return FALSE
	if(!(mobility_flags & MOBILITY_USE)) //just while I finish up the new 'fun' suiciding verb. This is to prevent metagaming via suicide
		to_chat(src, span_warning("You can't commit suicide whilst immobile! (You can type Ghost instead however)."))
		return FALSE
	return TRUE
