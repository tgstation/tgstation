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
		stack_trace("Attempted to remove skillchip [skillchip] that wasn't in [src] skillchip list.")
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
  * Creates a list of type paths of skillchips in the brain.
  *
  * Returns a simple list of typepaths.
  */
/obj/item/organ/brain/proc/get_skillchip_type_list()
	var/list/skillchip_types = list()
	// Remove and call on_removal proc if successful.
	for(var/chip in skillchips)
		var/obj/item/skillchip/skillchip = chip

		if(!istype(skillchip))
			stack_trace("[src] contains an item of type [skillchip.type] and this is not a skillchip.")
			continue
		skillchip_types += skillchip.type

	return skillchip_types

/**
  * Destroys all skillchips in the brain, calling on_removal if the brain has an owner.
  * Arguments:
  * * silent - Whether to give the user a chat notification with the removal flavour text.
  */
/obj/item/organ/brain/proc/destroy_all_skillchips(silent = TRUE)
	if(!QDELETED(owner))
		for(var/chip in skillchips)
			var/obj/item/skillchip/skillchip = chip
			skillchip.on_removal(owner, silent)
	QDEL_LIST(skillchips)
