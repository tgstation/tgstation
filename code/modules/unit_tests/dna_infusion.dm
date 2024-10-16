///Check that input types that aren't living mobs have the TRAIT_VALID_DNA_INFUSION trait
/datum/unit_test/valid_dna_infusion

/datum/unit_test/valid_dna_infusion/Run()
	for(var/datum/infuser_entry/infuser_entry as anything in flatten_list(GLOB.infuser_entries))
		for(var/input_type as anything in infuser_entry.input_obj_or_mob)
			if(ispath(input_type, /mob/living))
				continue
			var/atom/movable/movable = allocate(input_type)
			if(!HAS_TRAIT(movable, TRAIT_VALID_DNA_INFUSION))
				//TEST_FAIL() doesn't early return the unit test so we can keep checking.
				TEST_FAIL("[input_type] is in the 'input_obj_or_mob' list for [infuser_entry.type] but doesn't have TRAIT_VALID_DNA_INFUSION.")

/// Checks that all "organ_set_bonus" status effects have unique "id" vars.
/// Required to ensure that the status effects are treated as "unique".
/datum/unit_test/organ_set_bonus_id

/datum/unit_test/organ_set_bonus_id/Run()
	var/list/bonus_effects = typesof(/datum/status_effect/organ_set_bonus)
	var/list/existing_ids = list()
	for(var/datum/status_effect/organ_set_bonus/bonus_effect as anything in bonus_effects)
		var/effect_id = initial(bonus_effect.id)
		TEST_ASSERT(!(effect_id in existing_ids), "The ID of [bonus_effect] was duplicated in another status effect.")
		existing_ids += effect_id

/// Checks that all implantable DNA Infuser organs are set up correctly and without error.
/// Tests the "organ set bonus" Elements and Status Effects, which are for the DNA Infuser.
/// This test ensures that the "organ_set_bonus" status effects activate and deactivate when expected.
/datum/unit_test/organ_set_bonus_sanity

/datum/unit_test/organ_set_bonus_sanity/Run()
	/// List of infuser_entry typepaths which contain species-changing organs.
	/// Species change swaps out all the organs, making test_organ un-usable after insertion.
	var/list/species_changing_entries = typecacheof(list(
		/datum/infuser_entry/fly,
	))
	// Fetch the globally instantiated DNA Infuser entries.
	for(var/datum/infuser_entry/infuser_entry as anything in flatten_list(GLOB.infuser_entries))
		var/output_organs = infuser_entry.output_organs
		var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human/consistent)
		var/list/obj/item/organ/inserted_organs = list()

		// Attempt to insert entire list of mutant organs for the given infusion_entry.
		for(var/obj/item/organ/organ as anything in output_organs)
			organ = new organ()
			organ.Insert(lab_rat, special = TRUE, movement_flags = DELETE_IF_REPLACED)
			inserted_organs += organ

		// Search for added Status Effect.
		var/datum/status_effect/organ_set_bonus/added_status
		if(!infuser_entry.unreachable_effect)
			added_status = locate(/datum/status_effect/organ_set_bonus) in lab_rat.status_effects

		// If threshold_desc is filled-in, it implies the organ_set_bonus Status Effect should be activated.
		// Without it, we'll assume there isn't a Status Effect to look for.
		var/has_threshold = (infuser_entry.threshold_desc != DNA_INFUSION_NO_THRESHOLD)
		// How many organs the Status Effect requires to be inserted before it will activate.
		var/total_organs_needed = added_status?.organs_needed || 0
		// How many organs are available from the infuser entry.
		var/total_organs = length(infuser_entry.output_organs)
		// Quantity of successfully inserted organs.
		var/total_inserted = length(inserted_organs)

		// If Status Effect exists, ensure it has a matching threshold description and vice versa.
		// Otherwise, ensure both are falsy.
		TEST_ASSERT((added_status && has_threshold) || (!added_status && !has_threshold), "The threshold_desc variable for `[infuser_entry.type]` was an empty string when a description was expected.")

		if(has_threshold)
			TEST_ASSERT(added_status, "The `/datum/status_effect/organ_set_bonus` for `[infuser_entry.type]` was not added to the mob when expected.")
			TEST_ASSERT(total_organs_needed, "The `needed_organs` variable for `[added_status.type]` should be a positive number.")
			TEST_ASSERT(total_organs_needed <= total_organs, "The `output_organs` list for `[infuser_entry.type]` had a length of `[length(infuser_entry.output_organs)]` when a minimum of at least [total_organs_needed] organs was specified in `[added_status.type]`.")
			TEST_ASSERT(added_status.bonus_active, "The `[added_status.type]` bonus was not activated after inserting [total_inserted] of the [total_organs_needed] required organs in the mob, when it was expected.")

		// Nothing to do.
		if(total_inserted == 0)
			continue

		// Bonus of the Fly mutation swaps out all the organs, making it rather permanent.
		// As a result, the inserted_organs list is un-usable by this point.
		if(species_changing_entries[infuser_entry.type])
			continue

		// Remove all the organs which were just added.
		for(var/obj/item/organ/test_organ as anything in inserted_organs)
			test_organ.Remove(lab_rat, special = TRUE)

		var/datum/status_effect/organ_set_bonus/removed_status = (locate(/datum/status_effect/organ_set_bonus) in lab_rat.status_effects)

		// Search for added Status Effect.
		TEST_ASSERT(!removed_status || !added_status.bonus_active, "The `[added_status.type]` bonus was not deactivated after removing [total_inserted] of the [total_organs_needed] required organs from the mob, when it was expected.")
