/// Tests the "organ set bonus" Elements and Status Effects, which are for the DNA Infuser.
/// Ensures the developers properly change IDs to be unique.
/datum/unit_test/organ_set_bonus_id

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

/datum/unit_test/organ_set_bonus_sanity/proc/check_status_type(mob/living/carbon/human/lab_rat, datum/status_effect/status_type)
	var/datum/status_effect/organ_set_bonus/added_status
	for(var/datum/status_effect/present_effect as anything in lab_rat.status_effects)
		if(istype(present_effect, status_type))
			return present_effect

/// Tests the "organ set bonus" Elements and Status Effects, which are for the DNA Infuser.
/// Ensures that each Element and Status Effect gets properly added/removed from mobs.
/datum/unit_test/organ_set_bonus_sanity

/datum/unit_test/organ_set_bonus_sanity/Run()
	// Fetch the globally instantiated DNA Infuser entries.
	for(var/datum/infuser_entry/infuser_entry as anything in GLOB.infuser_entries)
		var/output_organs = infuser_entry.output_organs
		// Human which will reiceve organs.
		var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human/consistent)
		var/list/obj/item/organ/inserted_organs = list()
		for(var/obj/item/organ/organ as anything in output_organs)
			organ = new organ()
			var/implant_ok = organ.Insert(lab_rat, special = TRUE, drop_if_replaced = FALSE)
			if(!implant_ok)
				TEST_FAIL("The organ \"[organ.type]\" for \"[infuser_entry.type]\" was not inserted in the mob when expected.")
				continue
			inserted_organs += organ

		var/total_inserted = length(inserted_organs)

		// Search for added Status Effect.
		var/datum/status_effect/organ_set_bonus/added_status = check_status_type(lab_rat, /datum/status_effect/organ_set_bonus)

		// Threshold description implies an organ set bonus.
		// Without it, we'll assume there isn't a Status Effect to look for.
		var/has_threshold = (infuser_entry.threshold_desc != DNA_INFUSION_NO_THRESHOLD)
		var/total_organs_needed = added_status ? added_status.organs_needed : 0
		var/total_organs = length(infuser_entry.output_organs)

		// Found a Status Effect but no threshold description.
		if(!has_threshold && added_status)
			TEST_FAIL("The threshold_desc variable for \"[infuser_entry.type]\" was an empty string when a description was expected.")

		// Since threshold_desc is filled-in, we expect the organ set bonus.
		if(has_threshold)
			if(!added_status)
				TEST_FAIL("The \"/datum/status_effect/organ_set_bonus\" for \"[infuser_entry.type]\" was not added to the mob when expected.")
			else if(!total_organs_needed)
				TEST_FAIL("The \"needed_organs\" variable for \"[added_status.type]\" was 0 or null, when a positive number was expected.")
			else if(total_organs_needed > total_organs)
				TEST_FAIL("The \"output_organs\" list for \"[infuser_entry.type]\" had a length of \"[length(infuser_entry.output_organs)]\" when a minimum of at least [total_organs_needed] organs was specified in \"[added_status.type]\".")
			else if(!added_status.bonus_active)
				TEST_FAIL("The \"[added_status.type]\" bonus was not activated after inserting [total_inserted] of the [total_organs_needed] required organs in the mob, when it was expected.")

		// Nothing to do.
		if(!total_inserted)
			continue

		// Bonus of the Fly mutation swaps out all the organs, making it rather permanent.
		// As a result, the inserted_organs list is un-usable by this point.
		if(istype(infuser_entry, /datum/infuser_entry/fly))
			continue

		// Remove all the organs which were just added.
		var/total_removed = 0
		for(var/obj/item/organ/test_organ as anything in inserted_organs)
			test_organ.Remove(lab_rat, special = TRUE)
			total_removed += 1

		added_status = check_status_type(lab_rat, /datum/status_effect/organ_set_bonus)

		// Search for added Status Effect.
		if(added_status && added_status.bonus_active)
			TEST_FAIL("The \"[added_status.type]\" bonus was not deactivated after removing [total_removed] of the [total_organs_needed] required organs from the mob, when it was expected.")
