/**
 * Organ Unit Tests
 *
 * Test 1. organ_sanity:
 * Checks all implantable organs.
 * Ensures algorithmic correctness of the "Insert()" and "Remove()" procs.
 * This test is especially useful because developers frequently  override those.
 *
 * Test 2. organ_set_bonus_id:
 * Checks that all "organ_set_bonus" status effects have unique "id" vars.
 * Required to ensure that the status effects are treated as "unique".
 *
 * Test 3. organ_set_bonus_sanity
 * Checks that all implantable DNA Infuser organs are set up correctly and without error.
 * Ensures that the "organ_set_bonus" status effects activate and deactivate.
 *
 * "Life's about having a good time and having candy, not putting roaches in your hair!"
 * - Dr. Steve Brule
 */
/// Ensures the organ inserted properly by validating specific variables.
#define TEST_ORGAN_INSERTED_OK(lab_rat, test_organ) ((test_organ.owner == lab_rat) && (test_organ in lab_rat.internal_organs) && test_organ.slot ? (lab_rat.getorganslot(test_organ.slot) == test_organ) : TRUE)
/// Ensures the organ removed properly by validating specific variables.
#define TEST_ORGAN_REMOVED_OK(lab_rat, test_organ) ((test_organ.owner == null) && !(test_organ in lab_rat.internal_organs) && test_organ.slot ? (lab_rat.getorganslot(test_organ.slot) != test_organ) : TRUE)
/// List of organ typepaths which are not test-able, such as certain class prototypes.
#define TEST_ORGAN_BLACKLIST list(\
	/obj/item/organ/internal,\
	/obj/item/organ/external,\
	/obj/item/organ/external/wings,\
	/obj/item/organ/internal/cyberimp,\
	/obj/item/organ/internal/cyberimp/brain,\
	/obj/item/organ/internal/cyberimp/mouth,\
	/obj/item/organ/internal/cyberimp/arm,\
	/obj/item/organ/internal/cyberimp/chest,\
	/obj/item/organ/internal/cyberimp/eyes,\
	/obj/item/organ/internal/alien,\
)

//-- Sanity: ALL ORGANS --//
/// Check organ insertion and removal, for all organ subtypes usable in-game.
/datum/unit_test/organ_sanity/Run()
	for(var/obj/item/organ/organ_type as anything in subtypesof(/obj/item/organ))
		// Skip prototypes.
		if(organ_type in TEST_ORGAN_BLACKLIST)
			continue

		// Appropriate mob (Human) which will receive organ.
		var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human/consistent)
		var/obj/item/organ/test_organ = new organ_type()

		// Inappropriate mob (Dog) which will hopefully reject organ.
		var/mob/living/basic/pet/dog/lab_dog = allocate(/mob/living/basic/pet/dog/corgi)
		var/obj/item/organ/reject_organ = new organ_type()

		// Insert organ and store status code in var.
		var/inserted_ok = test_organ.Insert(lab_rat, special = TRUE, drop_if_replaced = FALSE)
		// Ensure organ was rejected.
		var/rejected_ok = !reject_organ.Insert(lab_dog, special = TRUE, drop_if_replaced = FALSE)

		// For the Human, expects status code 1
		if(!inserted_ok)
			TEST_FAIL("The organ \"[test_organ.type]\" was not inserted in the mob when expected, Insert() returned FALSE when TRUE was expected.")
			continue

		// For the Dog, expects status code 0 or falsy value.
		if(!rejected_ok)
			TEST_FAIL("The \"[test_organ.type]\" was inserted into a basic mob (Corgi) when it wasn't expected.")

		// Inserting Nightmare brain causes the Human's species to change.
		// Species change swaps out all the organs, making test_organ un-usable by this point.
		if(test_organ.type == /obj/item/organ/internal/brain/shadow/nightmare)
			continue

		// Check vars on Human and organ, they are expected to be present after Insert().
		if(!TEST_ORGAN_INSERTED_OK(lab_rat, test_organ))
			TEST_FAIL("The organ \"[test_organ.type]\" was not properly inserted in the mob, some variables were not assigned when expected.")
			continue

		// Now yank it back out.
		test_organ.Remove(lab_rat, special = TRUE)

		// Check vars on Human and organ, they are expected to be deleted after Remove().
		if(!TEST_ORGAN_REMOVED_OK(lab_rat, test_organ))
			TEST_FAIL("The organ \"[test_organ.type]\" was not properly removed from the mob, some variables were not reset when expected.")

#undef TEST_ORGAN_INSERTED_OK
#undef TEST_ORGAN_REMOVED_OK
#undef TEST_ORGAN_BLACKLIST

//-- Sanity: DNA INFUSER ORGANS / ORGAN SET BONUS --//
/// Ensures the developers properly change IDs to be unique.
/datum/unit_test/organ_sanity/organ_set_bonus_id/Run()
	var/list/bonus_effects = typesof(/datum/status_effect/organ_set_bonus)
	var/list/existing_ids = list()
	for(var/datum/status_effect/organ_set_bonus/bonus_effect as anything in bonus_effects)
		var/effect_id = initial(bonus_effect.id)
		var/existing_status = (effect_id in existing_ids)
		if(existing_status)
			TEST_FAIL("The ID of [bonus_effect] was duplicated in another status effect.")
		else
			existing_ids += effect_id

/// Utility proc which searches a mob for a Status Effect using a given typepath.
/datum/unit_test/organ_sanity/organ_set_bonus_sanity/proc/check_status_type(mob/living/carbon/human/lab_rat, datum/status_effect/status_type)
	for(var/datum/status_effect/present_effect as anything in lab_rat.status_effects)
		if(istype(present_effect, status_type))
			return present_effect

/// Tests the "organ set bonus" Elements and Status Effects, which are for the DNA Infuser.
/// Ensures that each Element and Status Effect gets properly added/removed from mobs.
/datum/unit_test/organ_sanity/organ_set_bonus_sanity/Run()
	// Fetch the globally instantiated DNA Infuser entries.
	for(var/datum/infuser_entry/infuser_entry as anything in GLOB.infuser_entries)
		var/output_organs = infuser_entry.output_organs
		// Human which will reiceve organs.
		var/mob/living/carbon/human/lab_rat = allocate(/mob/living/carbon/human/consistent)
		var/list/obj/item/organ/inserted_organs = list()
		// Attempt to insert entire list of mutant organs for the given infusion_entry.
		for(var/obj/item/organ/organ as anything in output_organs)
			organ = new organ()
			var/implant_ok = organ.Insert(lab_rat, special = TRUE, drop_if_replaced = FALSE)
			if(!implant_ok)
				TEST_FAIL("The organ \"[organ.type]\" for \"[infuser_entry.type]\" was not inserted in the mob when expected.")
				continue
			inserted_organs += organ

		// Search for added Status Effect.
		var/datum/status_effect/organ_set_bonus/added_status = check_status_type(lab_rat, /datum/status_effect/organ_set_bonus)

		// Threshold description implies an organ set bonus.
		// Without it, we'll assume there isn't a Status Effect to look for.
		var/has_threshold = (infuser_entry.threshold_desc != DNA_INFUSION_NO_THRESHOLD)
		// How many organs the Status Effect requires to be inserted before it will activate.
		var/total_organs_needed = added_status ? added_status.organs_needed : 0
		// How many organs are available from the infuser entry.
		var/total_organs = length(infuser_entry.output_organs)
		// Quantity of successfully inserted organs.
		var/total_inserted = length(inserted_organs)

		// Found a Status Effect but no threshold description.
		if(!has_threshold && added_status)
			TEST_FAIL("The threshold_desc variable for \"[infuser_entry.type]\" was an empty string when a description was expected.")

		// Since threshold_desc is filled-in, we expect the organ set bonus.
		// Each of these fails in-order, so your test output doesn't get spammed with messages.
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
