mob/proc/getorgan()
	return

mob/proc/getorgansloc()
	return

mob/living/carbon/getorgan(typepath)
	return (locate(typepath) in internal_organs)

mob/living/carbon/getorgansloc(zone)
	var/list/returnorg = list()
	for(var/obj/item/organ/internal/O in internal_organs)
		if(zone == O.zone)
			returnorg += O

	return returnorg

mob/proc/getlimb()
	return

mob/living/carbon/human/getlimb(typepath)
	return (locate(typepath) in organs)