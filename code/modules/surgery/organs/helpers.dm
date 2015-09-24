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
		if(zone == "head")
			returnorg = getorganszone("eyes") + getorganszone("mouth")
			// We don't have mouth organs now, but who knows?
		if(zone == "chest")
			returnorg = getorganszone("groin")


	for(var/obj/item/organ/internal/O in internal_organs)
		if(zone == O.zone)
			returnorg += O
	return returnorg

mob/living/carbon/getorganslot(slot)
	for(var/obj/item/organ/internal/O in internal_organs)
		if(slot == O.slot)
			return O

mob/proc/getlimb()
	return

mob/living/carbon/human/getlimb(typepath)
	return (locate(typepath) in organs)

proc/isorgan(atom/A)
	return istype(A, /obj/item/organ/internal)