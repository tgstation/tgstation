/**
  * Attempts to implant this skillchip into the target carbon's brain.
  *
  * Returns whether the skillchip was inserted or not. Can optionally give message notification.
  * Arguments:
  * * skillchip - The skillchip you want to insert.
  * * silent - Whether or not to display the implanting message.
  * * force - Whether to force the implant to happen. Skips checking if the chip can actually be implanted. Used by changelings.
  */
/mob/living/carbon/proc/implant_skillchip(obj/item/skillchip/skillchip, silent = FALSE, force = FALSE)
	// Check the chip can actually be implanted.
	if(!can_implant_skillchip(skillchip) && !force)
		return FALSE

	// Grab the brain. It should exist as can_be_implanted() checks for it.
	var/obj/item/organ/brain/brain = getorganslot(ORGAN_SLOT_BRAIN)

	// Implant and call on_apply proc if successful.
	if(brain.implant_skillchip(skillchip))
		skillchip.on_apply(src, silent)
		skillchip.forceMove(brain)
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

	// Skillchip is not in implantable state.
	if(!skillchip.can_implant())
		return FALSE

	//No brain
	var/obj/item/organ/brain/brain = getorganslot(ORGAN_SLOT_BRAIN)
	if(QDELETED(brain))
		return FALSE

	//No skill slots left
	if(used_skillchip_slots + skillchip.slot_cost > max_skillchip_slots)
		return FALSE

	if(brain.check_skillchip_flags(skillchip))
		return FALSE

	// Check if this skillchip requires the mob to be mindshielded.
	if(!HAS_TRAIT(src, TRAIT_MINDSHIELD) && (skillchip.skillchip_flags & SKILLCHIP_REQUIRE_MINDSHIELD))
		return FALSE

	return TRUE

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
		return "No valid chip detected."

	// Skillchip is not in implantable state.
	if(!skillchip.can_implant())
		return "Chip is not implantable."

	//No brain
	var/obj/item/organ/brain/brain = getorganslot(ORGAN_SLOT_BRAIN)
	if(QDELETED(brain))
		return "No brain detected."

	//No skill slots left
	if(used_skillchip_slots + skillchip.slot_cost > max_skillchip_slots)
		return "Complexity limit exceeded."

	// Incompatibiliy with other already implanted skillchips.
	var/incompatible_flags = brain.check_skillchip_flags(skillchip)
	if(incompatible_flags)
		if(incompatible_flags & SKILLCHIP_ALLOWS_MULTIPLE)
			return "Duplicate chip detected."
		if(incompatible_flags & SKILLCHIP_JOB_TYPE)
			return "Existing job chip detected."
		return "Chip is incompatible with existing chips."

	// Check if this skillchip requires the mob to be mindshielded.
	if(!HAS_TRAIT(src, TRAIT_MINDSHIELD) && (skillchip.skillchip_flags & SKILLCHIP_REQUIRE_MINDSHIELD))
		return "Chip requires mindshield."

	//Only one multiple copies of a type if SKILLCHIP_ALLOWS_MULTIPLE flag is set
	if(!(skillchip.skillchip_flags & SKILLCHIP_ALLOWS_MULTIPLE) && (locate(type) in brain.skillchips))
		return "Duplicate chip detected."

	return "Chip ready for implantation."

/**
  * Creates a list of type paths of skillchips in the mob's brain.
  *
  * Returns a simple list of typepaths.
  */
/mob/living/carbon/proc/get_skillchip_type_list()
	// Check the target's brain, making sure the target exists and has a brain.
	var/obj/item/organ/brain/brain = getorganslot(ORGAN_SLOT_BRAIN)
	if(QDELETED(brain))
		return list()

	return brain.get_skillchip_type_list()

/**
  * Destroys all skillchips in the brain, calling on_removal if the brain has an owner.
  */
/mob/living/carbon/proc/destroy_all_skillchips()
	var/obj/item/organ/brain/brain = getorganslot(ORGAN_SLOT_BRAIN)
	if(!QDELETED(brain))
		brain.destroy_all_skillchips()
