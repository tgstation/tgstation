/**
  * Attempts to implant this skillchip into the target carbon's brain.
  *
  * Returns whether the skillchip was inserted or not. Can optionally give message notification.
  * Arguments:
  * * skillchip - The skillchip you want to insert.
  * * silent - Whether or not to display the implanting message.
  */
/mob/living/carbon/proc/implant_skillchip(obj/item/skillchip/skillchip, silent = FALSE)
	// Check the chip can actually be implanted.
	if(!can_implant_skillchip(skillchip))
		return FALSE

	// Grab the brain. It should exist as can_be_implanted() checks for it.
	var/obj/item/organ/brain/brain = getorganslot(ORGAN_SLOT_BRAIN)

	// Implant and call on_apply proc if successful.
	if(brain.implant_skillchip(skillchip))
		skillchip.on_apply(src, silent)
		return TRUE

	return FALSE

/**
  * Attempts to remove this skillchip from the target carbon's brain.
  *
  * Returns FALSE when the skillchip couldn't be removed for some reason,
  * including the target or brain not existing or the skillchip not being in the brain.
  * Arguments:
  * * target - The living carbon whose brain you want to remove the chip from.
  * * silent - Whether or not to display the removal message.
  */
/mob/living/carbon/proc/remove_skillchip(obj/item/skillchip/skillchip, silent = FALSE)
	// Check the target's brain, making sure the target exists and has a brain.
	var/obj/item/organ/brain/brain = getorganslot(ORGAN_SLOT_BRAIN)
	if(QDELETED(brain))
		return FALSE

	// Remove and call on_removal proc if successful.
	if(brain.remove_skillchip(skillchip))
		skillchip.on_removal(src, silent)
		return TRUE

	return FALSE

/**
  * Checks whether this mob can have a given skillchip implanted into them.
  *
  * Checks whether the brain exists, how many skillchip slots are left and if the
  * skillchip is already implanted and can't have duplicates.
  * Arguments:
  * * skillchip - The skillchip to test for implantability.
  */
/mob/living/carbon/proc/can_implant_skillchip(obj/item/skillchip/skillchip)
	// Not a skillchip or skillchip doesn't exist.
	if(!skillchip || !istype(skillchip))
		return FALSE

	//No brain
	var/obj/item/organ/brain/brain = getorganslot(ORGAN_SLOT_BRAIN)
	if(QDELETED(brain))
		return FALSE

	//No skill slots left
	if(used_skillchip_slots + skillchip.slot_cost > max_skillchip_slots)
		return FALSE

	//Only one multiple copies of a type if SKILLCHIP_ALLOWS_MULTIPLE flag is set
	if(!(skillchip.skillchip_flags & SKILLCHIP_ALLOWS_MULTIPLE) && (locate(type) in brain.skillchips))
		return FALSE
	return TRUE

/// Returns readable reason why implanting cannot succeed
/**
  * Returns readable reason why implanting cannot succeed.
  *
  * Checks whether the brain exists, how many skillchip slots are left and if the
  * skillchip is already implanted and can't have duplicates.
  * --todo switch to flag retval in can_be_implanted to cut down copypaste
  * Arguments:
  * * skillchip - The skillchip to test for implantability.
  */
/mob/living/carbon/proc/can_implant_skillchip_message(obj/item/skillchip/skillchip)
	// Not a skillchip or skillchip doesn't exist.
	if(!skillchip || !istype(skillchip))
		return "No valid skillchip detected."

	//No brain
	var/obj/item/organ/brain/brain = getorganslot(ORGAN_SLOT_BRAIN)
	if(QDELETED(brain))
		return "No brain detected."

	//No skill slots left
	if(used_skillchip_slots + skillchip.slot_cost > max_skillchip_slots)
		return "Complexity limit exceeded."

	//Only one multiple copies of a type if SKILLCHIP_ALLOWS_MULTIPLE flag is set
	if(!(skillchip.skillchip_flags & SKILLCHIP_ALLOWS_MULTIPLE) && (locate(type) in brain.skillchips))
		return "Duplicate chip detected."

	return "Chip ready for implantation."
