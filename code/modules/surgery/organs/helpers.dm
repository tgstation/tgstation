mob/proc/getorgan(typepath)
	return

mob/proc/getorganszone(zone)
	return

mob/proc/getorganslot(slot)
	return


mob/living/carbon/getorgan(typepath)
	return (locate(typepath) in internal_organs)

mob/living/carbon/getorganszone(zone, var/subzones = 0)
	var/list/returnorg = list()
	if(subzones)
		// Include subzones - groin for chest, eyes and mouth for head
		if(zone == "head")
			returnorg = getorganszone("eyes") + getorganszone("mouth")
		if(zone == "chest")
			returnorg = getorganszone("groin")

	for(var/obj/item/organ/internal/O in internal_organs)
		if(zone == O.zone)
			returnorg += O
	return returnorg

mob/living/carbon/getorganslot(slot)
	return internal_organs_slot[slot]

mob/proc/getlimb()
	return

mob/living/carbon/human/getlimb(typepath)
	return (locate(typepath) in organs)

proc/isorgan(atom/A)
	return istype(A, /obj/item/organ/internal)