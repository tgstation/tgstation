/**
 * Attempts to implant this skillchip into the target carbon's brain.
 *
 * Returns whether the skillchip was inserted or not. Can optionally give chat message notification to the mob.
 * Arguments:
 * * skillchip - The skillchip you want to insert.
 * * silent - Whether or not to display the implanting message.
 * * force - Whether to force the implant to happen, including forcing activating if activate = TRUE. Ignores incompatibility checks. Used by changelings.
 */
/mob/living/carbon/proc/implant_skillchip(obj/item/skillchip/skillchip, force = FALSE)
	// Grab the brain.
	var/obj/item/organ/internal/brain/brain = getorganslot(ORGAN_SLOT_BRAIN)

	// Check for the brain. No brain = no implant.
	if(QDELETED(brain))
		return "Brain not found."

	if(force)
		return brain.implant_skillchip(skillchip, force)

	// Check the chip can actually be implanted.
	var/mob_incompat_msg = skillchip.has_mob_incompatibility(src)
	if(mob_incompat_msg)
		return mob_incompat_msg

	// Implant in the brain.
	return brain.implant_skillchip(skillchip, force)

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
	var/obj/item/organ/internal/brain/brain = getorganslot(ORGAN_SLOT_BRAIN)
	if(QDELETED(brain))
		return FALSE

	// Remove and call on_removal proc
	if(!brain.remove_skillchip(skillchip, silent))
		stack_trace("Failed to remove skillchip [skillchip] from [src].")
		return FALSE

	return TRUE

/**
 * Creates a list of new skillchips cloned from old skillchips in the mob's brain.
 *
 * Returns a complete list of new skillchips cloned from the mob's brain's existing skillchip stock.
 * Rumour has it that Changelings just LOVE this proc.
 * Arguments:
 * * cloned_chip_holder - The new holder for the cloned chips. Please don't be null.
 * * not_removable - Special override, whether or not to force cloned chips to be non-removable, i.e. to delete on removal.
 */
/mob/living/carbon/proc/clone_skillchip_list(not_removable = FALSE)
	// Check the target's brain, making sure the target exists and has a brain.
	var/obj/item/organ/internal/brain/brain = getorganslot(ORGAN_SLOT_BRAIN)
	if(QDELETED(brain))
		return list()

	return brain.clone_skillchip_list(not_removable)

/**
 * Destroys all skillchips in the brain, handling appropriate cleanup and event calls.
 */
/mob/living/carbon/proc/destroy_all_skillchips(silent = FALSE)
	// Check the target's brain, making sure the target exists and has a brain.
	var/obj/item/organ/internal/brain/brain = getorganslot(ORGAN_SLOT_BRAIN)

	if(QDELETED(brain))
		return FALSE

	brain.destroy_all_skillchips(silent)

	return TRUE
