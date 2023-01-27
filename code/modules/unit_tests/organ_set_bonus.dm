/// Tests the "organ set bonus" Elements and Status Effects, which are for the DNA Infuser.
/// Ensures the developers properly change IDs to be unique.
/datum/unit_test/organ_set_bonus_id/Run()
	var/list/bonus_effects = typesof(/datum/status_effect/organ_set_bonus)
	var/list/existing_ids = list()
	for(var/datum/status_effect/organ_set_bonus/bonus_effect as anything in bonus_effects)
		var/effect_id = initial(bonus_effect.id)
		var/existing_status = (effect_id in existing_ids)
		if(existing_status)
			TEST_FAIL("The ID of [bonus_effect] was duplicated in another status effect.")
		else
			existing_ids += effect_id

/// Tests the "organ set bonus" Elements and Status Effects, which are for the DNA Infuser.
/// Ensures that each Element and Status Effect gets properly added/removed from mobs.
/datum/unit_test/organ_set_bonus_sanity/Run()
	// Fetch the globally instantiated DNA Infuser entries.
	for(var/datum/infuser_entry/infuser_entry as anything in GLOB.infuser_entries)
		var/output_organs = infuser_entry.output_organs
		// Human which will reiceve organs.
		var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human/consistent)
		for(var/obj/item/organ/organ as anything in output_organs)
			organ = new organ()
			var/implant_ok = organ.Insert(lab_rat, special = TRUE, drop_if_replaced = FALSE)
			if(!implant_ok)
				TEST_FAIL("The organ \"[organ.type]\" for \"[infuser_entry.type]\" was not inserted in the mob when expected.")
		// Threshold implies there is an organ set bonus.
		if(infuser_entry.threshold_desc == DNA_INFUSION_NO_THRESHOLD)
			continue
		// Search for added Status Effect.
		var/datum/status_effect/organ_set_bonus/added_status
		for(var/datum/status_effect/present_effect as anything in lab_rat.status_effects)
			if(istype(present_effect, /datum/status_effect/organ_set_bonus))
				added_status = present_effect
				break
		if(!added_status)
			TEST_FAIL("The /datum/status_effect/organ_set_bonus for \"[infuser_entry.type]\" was not added to the mob when expected.")
		else if(!added_status.bonus_active)
			TEST_FAIL("The /datum/status_effect/organ_set_bonus for \"[infuser_entry.type]\" was not activated when expected.")
