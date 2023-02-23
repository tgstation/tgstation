/// Check organ insertion and removal, for all organ subtypes usable in-game.
/// Ensures algorithmic correctness of the "Insert()" and "Remove()" procs.
/// This test is especially useful because developers frequently  override those.
/datum/unit_test/organ_sanity

/datum/unit_test/organ_sanity/proc/test_organ_inserted_ok(mob/living/carbon/human/lab_rat, obj/item/organ/test_organ)
	return ((test_organ.owner == lab_rat) && (test_organ in lab_rat.internal_organs) && test_organ.slot ? (lab_rat.getorganslot(test_organ.slot) == test_organ) : TRUE)

/datum/unit_test/organ_sanity/proc/test_organ_removed_ok(mob/living/carbon/human/lab_rat, obj/item/organ/test_organ)
	return ((test_organ.owner == null) && !(test_organ in lab_rat.internal_organs) && test_organ.slot ? (lab_rat.getorganslot(test_organ.slot) != test_organ) : TRUE)

/datum/unit_test/organ_sanity/Run()
	// List of organ typepaths which are not test-able, such as certain class prototypes.
	var/list/test_organ_blacklist = list(
		/obj/item/organ/internal,
		/obj/item/organ/external,
		/obj/item/organ/external/wings,
		/obj/item/organ/internal/cyberimp,
		/obj/item/organ/internal/cyberimp/brain,
		/obj/item/organ/internal/cyberimp/mouth,
		/obj/item/organ/internal/cyberimp/arm,
		/obj/item/organ/internal/cyberimp/chest,
		/obj/item/organ/internal/cyberimp/eyes,
		/obj/item/organ/internal/alien,
	)
	for(var/obj/item/organ/organ_type as anything in subtypesof(/obj/item/organ))
		// Skip prototypes.
		if(organ_type in test_organ_blacklist)
			continue

		// Appropriate mob (Human) which will receive organ.
		var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human/consistent)
		var/obj/item/organ/test_organ = new organ_type()

		// Inappropriate mob (Dog) which will hopefully reject organ.
		var/mob/living/basic/pet/dog/lab_dog = allocate(/mob/living/basic/pet/dog/corgi)
		var/obj/item/organ/reject_organ = new organ_type()

		// Insert organ and store status code in var.
		var/inserted_ok = test_organ.Insert(lab_rat, special = TRUE, drop_if_replaced = FALSE)
		// Ensure organ was rejected by the Corgi.
		var/rejected_ok = !reject_organ.Insert(lab_dog, special = TRUE, drop_if_replaced = FALSE)
		// For the Human, expects status code 1
		TEST_ASSERT(inserted_ok, "The organ ``[test_organ.type]`` was not inserted in the mob when expected, Insert() returned falsy when TRUE was expected.")
		// For the Dog, expects status code 0 or falsy value.
		TEST_ASSERT(rejected_ok, "The ``[test_organ.type]`` was inserted into a basic mob (Corgi) when it wasn't expected.")

		if(!inserted_ok)
			continue

		// Inserting Nightmare brain causes the Human's species to change.
		// Species change swaps out all the organs, making test_organ un-usable by this point.
		if(test_organ.type == /obj/item/organ/internal/brain/shadow/nightmare)
			continue

		// Some vars on Human and Organ are expected to be assigned after Insert().
		var/vars_assigned_ok = test_organ_inserted_ok(lab_rat, test_organ)
		TEST_ASSERT(vars_assigned_ok, "The organ ``[test_organ.type]`` was not properly inserted in the mob, some variables were not assigned when expected.")

		if(!vars_assigned_ok)
			continue

		// Now yank it back out.
		test_organ.Remove(lab_rat, special = TRUE)

		// Some vars on Human and Organ are expected to be deleted after Remove().
		TEST_ASSERT(test_organ_removed_ok(lab_rat, test_organ), "The organ ``[test_organ.type]`` was not properly removed from the mob, some variables were not reset when expected.")

/// Checks that all "organ_set_bonus" status effects have unique "id" vars.
/// Required to ensure that the status effects are treated as "unique".
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

/// Checks that all implantable DNA Infuser organs are set up correctly and without error.
/// Tests the "organ set bonus" Elements and Status Effects, which are for the DNA Infuser.
/// This test ensures that the "organ_set_bonus" status effects activate and deactivate when expected.
/datum/unit_test/organ_set_bonus_sanity

/datum/unit_test/organ_set_bonus_sanity/Run()
	// Fetch the globally instantiated DNA Infuser entries.
	for(var/datum/infuser_entry/infuser_entry as anything in GLOB.infuser_entries)
		var/output_organs = infuser_entry.output_organs
		// Human which will reiceve organs.
		var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human/consistent)
		var/list/obj/item/organ/inserted_organs = list()
		// Attempt to insert entire list of mutant organs for the given infusion_entry.
		for(var/obj/item/organ/organ as anything in output_organs)
			organ = new organ()
			var/inserted_ok = organ.Insert(lab_rat, special = TRUE, drop_if_replaced = FALSE)
			TEST_ASSERT(inserted_ok, "The organ ``[organ.type]`` for ``[infuser_entry.type]`` was not inserted in the mob when expected, Insert() returned falsy when TRUE was expected.")
			if(inserted_ok)
				inserted_organs += organ

		// Search for added Status Effect.
		var/datum/status_effect/organ_set_bonus/added_status = locate(/datum/status_effect/organ_set_bonus) in lab_rat.status_effects

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
		TEST_ASSERT((added_status && has_threshold) || (!added_status && !has_threshold), "The threshold_desc variable for ``[infuser_entry.type]`` was an empty string when a description was expected.")

		if(has_threshold)
			TEST_ASSERT(added_status, "The ``/datum/status_effect/organ_set_bonus`` for ``[infuser_entry.type]`` was not added to the mob when expected.")
			TEST_ASSERT(total_organs_needed, "The ``needed_organs`` variable for ``[added_status.type]`` was 0 or falsy, when a positive number was expected.")
			TEST_ASSERT(total_organs_needed <= total_organs, "The ``output_organs`` list for ``[infuser_entry.type]`` had a length of ``[length(infuser_entry.output_organs)]`` when a minimum of at least [total_organs_needed] organs was specified in ``[added_status.type]``.")
			if(added_status)
				TEST_ASSERT(added_status.bonus_active, "The ``[added_status.type]`` bonus was not activated after inserting [total_inserted] of the [total_organs_needed] required organs in the mob, when it was expected.")

		// Nothing to do.
		if(total_inserted == 0)
			continue

		// Bonus of the Fly mutation swaps out all the organs, making it rather permanent.
		// As a result, the inserted_organs list is un-usable by this point.
		if(istype(infuser_entry, /datum/infuser_entry/fly))
			continue

		// Remove all the organs which were just added.
		for(var/obj/item/organ/test_organ as anything in inserted_organs)
			test_organ.Remove(lab_rat, special = TRUE)

		var/removed_status = locate(/datum/status_effect/organ_set_bonus) in lab_rat.status_effects

		// Search for added Status Effect.
		TEST_ASSERT(!removed_status || !added_status.bonus_active, "The ``[added_status.type]`` bonus was not deactivated after removing [total_inserted] of the [total_organs_needed] required organs from the mob, when it was expected.")
