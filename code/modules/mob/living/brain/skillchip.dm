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
  * DANGEROUS - This proc assumes you've done the appropriate checks to make sure the skillchip should be implanted.
  * Where possible, call the mob/living/carbon version of this proc which does relevant checks.
  * Arguments:
  * * skillchip - The skillchip you'd like to implant.
  */
/obj/item/organ/brain/proc/implant_skillchip(obj/item/skillchip/skillchip)
	LAZYADD(skillchips, skillchip)

	return TRUE

/**
  * Checks whether the skillchip's flags are incompatible with this brain's skillchips.
  *
  * Returns the flags that failed checks.
  * Arguments:
  * * skillchip - The skillchip you'd like to compare the flags of.
  */
/obj/item/organ/brain/proc/check_skillchip_flags(obj/item/skillchip/skillchip)
	var/incompatibility_flags = 0

	// If this is a job skillchip, check if any other skillchips are present.
	for(var/obj/item/skillchip/S in skillchips)
		incompatibility_flags |= skillchip.check_incompatibility(S)

	return incompatibility_flags

/**
  * Creates a list of type paths of skillchips in the brain.
  *
  * Returns a simple list of typepaths.
  */
/obj/item/organ/brain/proc/get_skillchip_type_list()
	var/list/skillchip_types = list()
	// Remove and call on_removal proc if successful.
	for(var/obj/item/skillchip/S in skillchips)
		skillchip_types += S.type

	return skillchip_types

/**
  * Destroys all skillchips in the brain, calling on_removal if the brain has an owner.
  */
/obj/item/organ/brain/proc/destroy_all_skillchips(silent = TRUE)
	if(!QDELETED(owner))
		for(var/obj/item/skillchip/skill_chip in skillchips)
			skill_chip.on_removal(owner, silent)
	QDEL_LIST(skillchips)
