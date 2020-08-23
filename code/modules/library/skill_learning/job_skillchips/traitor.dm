/obj/item/skillchip/chameleon
	name = "Chameleon skillchip"
	desc = "A highly advanced Syndicate skillchip that does nothing on its own. It is loaded with the data of every skillchip."
	skill_name = "Imitate Skillchip"
	skill_description = "Reacts to the user's thoughts, selecting a skill from a wide database of choices."
	activate_message = "<span class='notice'>You feel at one with the skillchip.</span>"
	deactivate_message = "<span class='notice'>The infinite mysteries of the skillchip escape your mind.</span>"
	skill_icon = "microchip"
	// Chip does nothing on its own, so it has 0 complexity.
	complexity = 0
	// Chamelelon chips cannot mimic chips with a greater slot cost. Increasing this will potentially increase
	// the pool of mimic'd chips. Decreasing it will decrease the pool of mimic'd chips. See initialize_disguises()
	// in the chameleon_action#'s type for the logic block.
	slot_use = 2
	removable = FALSE
	skillchip_flags = SKILLCHIP_CHAMELEON_INCOMPATIBLE
	/// Action for the skillchip selection.
	var/datum/action/item_action/chameleon/change/skillchip/chameleon_action

/obj/item/skillchip/chameleon/Initialize(mapload, is_removable = FALSE)
	. = ..()

	// This chameleon_action uses snowflake code. Do not set the chameleon_blacklist as that is ignored.
	// Instead, set the SKILLCHIP_CHAMELEON_INCOMPATIBLE flag on skillchips that should not be copyable.
	// Set abstract_parent_type on skillchips that are abstract (see /obj/item/skillchip definition)
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/skillchip
	chameleon_action.chameleon_name = "Skillchip"
	chameleon_action.initialize_disguises()

/obj/item/skillchip/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/// We don't want this to grant the item_action automatically.
/obj/item/skillchip/chameleon/item_action_slot_check(slot, mob/user)
	return FALSE

/obj/item/skillchip/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/skillchip/chameleon/on_implant(obj/item/organ/brain/owner_brain)
	// If there's already a mimic'd skillchip available, run its implant code alongside this.
	if(chameleon_action.skillchip_mimic)
		chameleon_action.skillchip_mimic.on_implant(owner_brain)

	return ..()

/// DANGEROUS - Doesn't check that the mimic'd chip can be activated. Assumes this check has been done already.
/obj/item/skillchip/chameleon/on_activate(mob/living/carbon/user, silent=TRUE)
	. = ..()

	// If there's already a mimic'd skillchip available, activate it. Generally only happens with changelings. Rare interaction.
	if(chameleon_action.skillchip_mimic && chameleon_action.skillchip_mimic.is_active())
		chameleon_action.skillchip_mimic.on_activate(user, silent)

	chameleon_action.Grant(user);

/obj/item/skillchip/chameleon/on_removal(silent = FALSE)
	. = ..()

	// Also call the on_removal of the mimic'd skillchip.
	if(chameleon_action.skillchip_mimic)
		chameleon_action.skillchip_mimic.on_removal(silent)

/obj/item/skillchip/chameleon/on_deactivate(mob/living/carbon/user, silent = FALSE)
	chameleon_action.clear_mimic_chip()
	chameleon_action.Remove(user)

	return ..()

/obj/item/skillchip/chameleon/has_skillchip_incompatibility(obj/item/skillchip/skillchip)
	// If we've selected a skillchip to mimic, we'll want to intercept this proc and forward it to the mimic chip.
	if(chameleon_action.skillchip_mimic)
		return chameleon_action.skillchip_mimic.has_skillchip_incompatibility(skillchip)

	return ..()

/obj/item/skillchip/chameleon/has_activate_incompatibility(obj/item/organ/brain/brain)
	// If we've selected a skillchip to mimic, we'll want to intercept this proc and forward it to the mimic chip.
	if(chameleon_action.skillchip_mimic)
		return chameleon_action.skillchip_mimic.has_activate_incompatibility(brain)

	return ..()

/obj/item/skillchip/chameleon/has_mob_incompatibility(mob/living/carbon/target)
	// If we've selected a skillchip to mimic, we'll want to intercept this proc and forward it to the mimic chip.
	if(chameleon_action.skillchip_mimic)
		return chameleon_action.skillchip_mimic.has_mob_incompatibility(target)

	return ..()

/obj/item/skillchip/chameleon/has_brain_incompatibility(obj/item/organ/brain/brain)
	// If we've selected a skillchip to mimic, we'll want to intercept this proc and forward it to the mimic chip.
	if(chameleon_action.skillchip_mimic)
		return chameleon_action.skillchip_mimic.has_brain_incompatibility(brain)

	return ..()

/obj/item/skillchip/chameleon/get_chip_data()
	// If we've selected a skillchip to mimic, we'll want to intercept this proc and forward it to the mimic chip.
	if(chameleon_action.skillchip_mimic)
		var/list/mimic_data = chameleon_action.skillchip_mimic.get_chip_data()
		// Overwrite the ref with this chip's, as we'll want any operations to be performed through this chip and
		// not through the mimic chip.
		mimic_data["ref"] = REF(src)
		return mimic_data

	return ..()

/obj/item/skillchip/chameleon/try_activate_skillchip(silent = FALSE, force = FALSE)
	// If we've selected a skillchip to mimic, we'll want to intercept this proc and forward it to the mimic chip.
	if(chameleon_action.skillchip_mimic)
		return chameleon_action.skillchip_mimic.try_activate_skillchip(silent, force)

	return ..()

/obj/item/skillchip/chameleon/try_deactivate_skillchip(silent = FALSE, force = FALSE)
	// If we've selected a skillchip to mimic, we'll want to intercept this proc and forward it to the mimic chip.
	if(chameleon_action.skillchip_mimic)
		return chameleon_action.skillchip_mimic.try_deactivate_skillchip(silent, force)

	return ..()
/obj/item/skillchip/chameleon/is_on_cooldown()
	// If we've selected a skillchip to mimic, we'll want to intercept this proc and forward it to the mimic chip.
	if(chameleon_action.skillchip_mimic)
		return chameleon_action.skillchip_mimic.is_on_cooldown()

	return ..()

/obj/item/skillchip/chameleon/is_active()
	// If we've selected a skillchip to mimic, we'll want to intercept this proc and forward it to the mimic chip.
	if(chameleon_action.skillchip_mimic)
		return chameleon_action.skillchip_mimic.is_active()

	return ..()

/obj/item/skillchip/chameleon/get_complexity()
	// If we've selected a skillchip to mimic, we'll want to intercept this proc and forward it to the mimic chip.
	if(chameleon_action.skillchip_mimic)
		return chameleon_action.skillchip_mimic.get_complexity()

	return ..()

/obj/item/skillchip/chameleon/get_metadata()
	var/list/metadata = ..()

	// If we have a skillchip to mimic, create a new set of metadata for that chip.
	if(chameleon_action.skillchip_mimic)
		metadata["mimic_chip"] = chameleon_action.skillchip_mimic.get_metadata()

	return metadata

/obj/item/skillchip/chameleon/set_metadata(list/metadata)
	// Set base metadata first.
	. = ..()

	// Get rid of the old mimic chip regardless, we're setting metadata here. If the metadata doesn't
	// contain new mimic chip info, then assume we want to delete it.
	chameleon_action.clear_mimic_chip()

	// If this is metadata for another chamelelon chip variant, it may have a mimic_chip set.
	var/list/mimic_chip = metadata["mimic_chip"]

	// Call the mimic chip's proc to set the relevant metadata. Mimic chip activation should be handled
	// through this chip's activation procs being called externally.
	if(mimic_chip)
		var/type = mimic_chip["type"]
		chameleon_action.skillchip_mimic = new type(src)
		chameleon_action.skillchip_mimic.set_metadata(mimic_chip)
