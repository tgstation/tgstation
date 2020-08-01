/obj/item/skillchip/chameleon
	name = "Chameleon skillchip"
	desc = "A highly advanced Syndicate skillchip that does nothing on its own. It is loaded with the data of every skillchip."
	skill_name = "Imitate Skillchip"
	skill_description = "Reacts to the user's thoughts, selecting a skill from a wide database of choices."
	skill_icon = "microchip"
	slot_cost = 0
	removable = FALSE
	skillchip_flags = SKILLCHIP_CHAMELEON_INCOMPATIBLE
	/// Action for the skillchip selection.
	var/datum/action/item_action/chameleon/change/skillchip/chameleon_action

/obj/item/skillchip/chameleon/Initialize()
	. = ..()

	// This chameleon_action uses snowflake code. Do not set the chameleon_blacklist as that is ignored.
	// Instead, set the SKILLCHIP_CHAMELEON_INCOMPATIBLE flag on skillchips that should not be copyable.
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/skillchip
	chameleon_action.chameleon_name = "Skillchip"
	chameleon_action.initialize_disguises()

/obj/item/skillchip/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	. = ..()

/obj/item/skillchip/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/skillchip/chameleon/on_apply(mob/living/carbon/user, silent = TRUE)
	. = ..()
	chameleon_action.Grant(user);
	user.max_skillchip_slots++
	user.used_skillchip_slots++

/obj/item/skillchip/chameleon/on_removal(mob/living/carbon/user, silent = TRUE)
	chameleon_action.Remove(user)
	user.max_skillchip_slots--
	user.used_skillchip_slots--
	. = ..()

/obj/item/skillchip/chameleon/has_skillchip_incompatibility(obj/item/skillchip/skillchip)
	// If we've selected a skillchip to mimic, we'll want to intercept this proc and forward it to the mimic chip.
	if(chameleon_action.skillchip_mimic)
		return chameleon_action.skillchip_mimic.has_skillchip_incompatibility(skillchip)

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
		return chameleon_action.skillchip_mimic.get_chip_data()

	return ..()
