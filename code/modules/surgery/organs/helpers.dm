proc/getbrain(mob/living/carbon/M)
	if(istype(M))
		var/obj/item/organ/brain/B = locate() in M.internal_organs
		return B

proc/getappendix(mob/living/carbon/M)
	if(istype(M))
		var/obj/item/organ/appendix/A = locate() in M.internal_organs
		return A