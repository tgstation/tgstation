/**
  * Attempts to remove target skillchip from the brain.
  *
  * Returns whether the skillchip was removed or not.
  * If you're removing the skillchip from a mob, use the remove_skillchip proc in mob/living/carbon instead.
  * Arguments:
  * * skillchip - The skillchip you'd like to remove.
  */
/obj/item/organ/brain/proc/remove_skillchip(obj/item/skillchip/skillchip)
	// Check this skillchip is in the brain.
	if(!(skillchip in skillchips))
		return FALSE

	LAZYREMOVE(skillchips, skillchip)
	return TRUE

/**
  * Attempts to implant target skillchip into the brain.
  *
  * Returns whether the skillchip was implanted or not.
  * If you're implanting the skillchip into a mob, use the implant_skillchip proc in mob/living/carbon instead.
  * Arguments:
  * * skillchip - The skillchip you'd like to implant.
  */
/obj/item/organ/brain/proc/implant_skillchip(obj/item/skillchip/skillchip)
	// Check the brain exists.
	forceMove(skillchip, src)
	LAZYADD(skillchips, skillchip)

	return TRUE
