/**
 * Attempts to remove target skillchip from the brain.
 *
 * Returns whether the skillchip was removed or not.
 * If you're removing the skillchip from a mob, use the remove_skillchip proc in mob/living/carbon instead.
 * Arguments:
 * * skillchip - The skillchip you'd like to remove.
 */
/obj/item/organ/internal/brain/proc/remove_skillchip(obj/item/skillchip/skillchip, silent = FALSE)
	// Check this skillchip is in the brain.
	if(!(skillchip in skillchips))
		stack_trace("Attempted to remove skillchip [skillchip] that wasn't in [src] skillchip list.")
		return FALSE

	LAZYREMOVE(skillchips, skillchip)
	skillchip.on_removal(silent)
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
 * * force - Whether or not to force the skillchip to be implanted, ignoring any checks.
 */
/obj/item/organ/internal/brain/proc/implant_skillchip(obj/item/skillchip/skillchip, force = FALSE)
	// If we're not forcing the implant, so let's do some checks.
	if(!force)
		// Slot capacity check!
		var/max_slots = get_max_skillchip_slots()
		var/used_slots = get_used_skillchip_slots()

		if(used_slots + skillchip.slot_use > max_slots)
			return "Not enough free slots. You have [max_slots - used_slots] free and need [skillchip.slot_use]."

	LAZYADD(skillchips, skillchip)
	skillchip.on_implant(src)
	skillchip.forceMove(src)
	return

/**
 * Creates a list of assoc lists containing skillchip types and key metadata.
 *
 * Returns a complete list of new skillchip types with their metadata cloned from the brain's existing skillchip stock.
 * Rumour has it that Changelings just LOVE this proc.
 * Arguments:
 * * not_removable - Special override, whether or not to force cloned chips to be non-removable, i.e. to delete on removal.
 */
/obj/item/organ/internal/brain/proc/clone_skillchip_list(not_removable = FALSE)
	var/list/skillchip_metadata = list()
	// Remove and call on_removal proc if successful.
	for(var/chip in skillchips)
		var/obj/item/skillchip/skillchip = chip

		if(!istype(skillchip))
			stack_trace("[src] contains an item of type [skillchip.type] and this is not a skillchip.")
			continue

		// Grab chip metadata
		var/list/chip_metadata = skillchip.get_metadata()

		// If we're forcing non-removable status, set it after copying metadata.
		if(not_removable)
			chip_metadata["removable"] = FALSE

		skillchip_metadata += list(chip_metadata)

	return skillchip_metadata

/**
 * Destroys all skillchips in the brain, calling on_removal if the brain has an owner.
 * Arguments:
 * * silent - Whether to give the user a chat notification with the removal flavour text.
 */
/obj/item/organ/internal/brain/proc/destroy_all_skillchips(silent = TRUE)
	if(!QDELETED(owner))
		for(var/chip in skillchips)
			var/obj/item/skillchip/skillchip = chip
			skillchip.on_removal(silent)
	QDEL_LIST(skillchips)

/**
 * Returns the total maximum skillchip complexity supported by this brain.
 */
/obj/item/organ/internal/brain/proc/get_max_skillchip_complexity()
	if(!QDELETED(owner))
		return max_skillchip_complexity + owner.skillchip_complexity_modifier

	return max_skillchip_complexity

/**
 * Returns the total current skillchip complexity used in this brain.
 */
/obj/item/organ/internal/brain/proc/get_used_skillchip_complexity()
	var/complexity_tally = 0

	for(var/chip in skillchips)
		var/obj/item/skillchip/skillchip = chip

		if(!skillchip.is_active())
			continue

		complexity_tally += skillchip.get_complexity()

	return complexity_tally

/**
 * Returns the total maximum skillchip slot capacity supported by this brain.
 */
/obj/item/organ/internal/brain/proc/get_max_skillchip_slots()
	return max_skillchip_slots

/**
 * Returns the total current skillchip slot capacity used in this brain.
 */
/obj/item/organ/internal/brain/proc/get_used_skillchip_slots()
	var/slot_tally = 0

	for(var/chip in skillchips)
		var/obj/item/skillchip/skillchip = chip

		slot_tally += skillchip.slot_use

	return slot_tally

/**
 * Deactivates all chips currently in the brain.
 */
/obj/item/organ/internal/brain/proc/activate_skillchip_failsafe(silent = TRUE)
	if(QDELETED(owner))
		return

	var/chip_tally = 0

	for(var/chip in skillchips)
		var/obj/item/skillchip/skillchip = chip

		// If the chip isn't activated, skip.
		if(!skillchip.active)
			continue

		// Try force-deactivate it.
		skillchip.try_deactivate_skillchip(silent, TRUE)

		// If it's now no longer active, up the tally.
		if(!skillchip.active)
			chip_tally++

	if(chip_tally && !silent)
		to_chat(owner, span_warning("Unusual brain biology detected during regeneration. Failsafe procedure engaged. [chip_tally] skillchips have been deactivated."))

/// Disables or re-enables any extra skillchips after skillchip limit changes.
/obj/item/organ/internal/brain/proc/update_skillchips()
	var/limit = get_max_skillchip_complexity()
	var/dt = limit - get_used_skillchip_complexity()

	// We can return early if there's no negative difference to worry about.
	// Don't try to automatically activate skillchips. The user can do this themselves in the skill station.
	if(dt >= 0)
		return

	// Let's start hacking away at skillchips to lower the complexity.
	for(var/chip in skillchips)
		var/obj/item/skillchip/skillchip = chip
		// If the skillchip is active and try_deactive doesn't return any failure message, we can assume the
		// chip has now been deactivated.
		if(skillchip.is_active() && !skillchip.try_deactivate_skillchip(FALSE, TRUE))
			dt += skillchip.get_complexity()
			if(dt >= 0)
				return
