/mob/proc/getorgan(typepath)
	return

/mob/proc/getorganszone(zone)
	return

/mob/proc/getorganslot(slot)
	return

/mob/living/carbon/getorgan(typepath)
	return (locate(typepath) in internal_organs)

/mob/living/carbon/getorganszone(zone, subzones = 0)
	var/list/returnorg = list()
	if(subzones)
		// Include subzones - groin for chest, eyes and mouth for head
		if(zone == BODY_ZONE_HEAD)
			returnorg = getorganszone(BODY_ZONE_PRECISE_EYES) + getorganszone(BODY_ZONE_PRECISE_MOUTH)
		if(zone == BODY_ZONE_CHEST)
			returnorg = getorganszone(BODY_ZONE_PRECISE_GROIN)

	for(var/X in internal_organs)
		var/obj/item/organ/O = X
		if(zone == O.zone)
			returnorg += O
	return returnorg

/mob/living/carbon/getorganslot(slot)
	return internal_organs_slot[slot]
