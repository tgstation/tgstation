#define HAS_SCREEN_OVERLAY(mob, type) (locate(type) in flatten_list(mob.screens))
#define HAS_CLIENT_COLOR(mob, type) (locate(type) in mob.client_colours)

/**
 * Unit test to check that blindness adds the correct status effects, overlays, and client colors
 *
 * Also checks that blindness is added and removed correctly when it should and shouldn't be
 */
/datum/unit_test/blindness

/datum/unit_test/blindness/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/clothing/glasses/blindfold/blindfold = new(dummy.loc)
	TEST_ASSERT(!dummy.is_blind(), "Dummy was blind on initialize, and shouldn't be.")

	// Become blind
	dummy.become_blind("unit_test")
	check_if_blind(dummy)
	// Cure their blindness immediately
	dummy.cure_blind("unit_test")
	check_if_not_blind(dummy)

	// Become blindfolded, this one should blind us
	dummy.equip_to_slot_if_possible(blindfold, ITEM_SLOT_EYES)
	check_if_blind(dummy, status_message = "after being blindfolded")
	// Become quirk blinded and mutation blindness, these shouldn't do anything since we're already blind
	// Have to do a transfer here so we don't get a blindfold
	var/datum/quirk/item_quirk/blindness/quirk = allocate(/datum/quirk/item_quirk/blindness)
	quirk.add_to_holder(dummy, quirk_transfer = TRUE)
	dummy.dna.add_mutation(/datum/mutation/human/blind)

	// Remove the blindfold. We should remain blinded
	QDEL_NULL(blindfold)
	check_if_blind(dummy, status_message = "after removing their blindfold BUT still being blinded")
	// Remove the quirk. We should remain blinded again
	dummy.remove_quirk(/datum/quirk/item_quirk/blindness)
	check_if_blind(dummy, status_message = "after removing their quirk BUT still being blinded")
	// Remove the mutation, this should unblind us
	dummy.dna.remove_mutation(/datum/mutation/human/blind)
	check_if_not_blind(dummy, status_message = "after removing their blind mutation and having no sources of blindness left")

	// Temp blindness
	dummy.set_temp_blindness(10 SECONDS)
	check_if_blind(dummy, status_message = "after being temporarily blinded")
	// Now aheal, remove the temp blindness
	dummy.fully_heal(ALL)
	TEST_ASSERT(!dummy.has_status_effect(/datum/status_effect/temporary_blindness), "Dummy still had the temp blindness effect after being fullhealed.")
	// Check that it worked out
	check_if_not_blind(dummy, status_message = "after being ahealed while temporarily blinded")

/datum/unit_test/blindness/proc/check_if_blind(mob/living/carbon/human/dummy, status_message = "despite being made blind")
	// Check for the status effect, duh
	TEST_ASSERT(dummy.is_blind(), "Dummy, [status_message], did not have the blind status effect.")
	// Being more technical, we need to check for client color and screen overlays
	TEST_ASSERT(HAS_CLIENT_COLOR(dummy, /datum/client_colour/monochrome), "Dummy, [status_message], did not have the monochrome client color.")
	TEST_ASSERT(HAS_SCREEN_OVERLAY(dummy, /atom/movable/screen/fullscreen/blind), "Dummy, [status_message], did not have a blind screen overlay in their list of screens.")

/datum/unit_test/blindness/proc/check_if_not_blind(mob/living/carbon/human/dummy, status_message = "after being cured of blindness")
	// Check for no status effect
	TEST_ASSERT(!dummy.is_blind(), "Dummy, [status_message], still had the blindness status effect.")
	// Check that the client color and screen overlay are gone
	TEST_ASSERT(!HAS_CLIENT_COLOR(dummy, /datum/client_colour/monochrome), "Dummy, [status_message], still had the monochrome client color.")
	TEST_ASSERT(!HAS_SCREEN_OVERLAY(dummy, /atom/movable/screen/fullscreen/blind), "Dummy, [status_message], still had the blind sceen overlay.")

/**
 * Unit test to check that the nearsighted quirk is added and disabled correctly
 */
/datum/unit_test/nearsighted_quirk

/datum/unit_test/nearsighted_quirk/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/clothing/glasses/regular/glasses = allocate(/obj/item/clothing/glasses/regular)

	// Become quirk nearsighted
	// Have to do a transfer here so we don't get glasses
	var/datum/quirk/item_quirk/nearsighted/quirk = allocate(/datum/quirk/item_quirk/nearsighted)
	quirk.add_to_holder(dummy, quirk_transfer = TRUE)
	TEST_ASSERT(dummy.is_nearsighted(), "Dummy is not nearsighted after gaining the nearsighted quirk.")
	TEST_ASSERT(HAS_SCREEN_OVERLAY(dummy, /atom/movable/screen/fullscreen/impaired), "Dummy didn't gain the nearsighted overlay after becoming nearsighted.")
	TEST_ASSERT(dummy.is_nearsighted_currently(), "Dummy is not currently nearsighted, after gaining the nearsighted quirk.")
	// Become naturally nearsighted
	dummy.become_nearsighted("unit_test")

	// Equip the prescription glasses, they should disable nearsighted
	dummy.equip_to_slot_if_possible(glasses, ITEM_SLOT_EYES)
	TEST_ASSERT(dummy.is_nearsighted(), "Dummy was no longer nearsighted after putting on glasses. They should still be nearsighted, but it should be disabled.")
	TEST_ASSERT(!HAS_SCREEN_OVERLAY(dummy, /atom/movable/screen/fullscreen/impaired), "Dummy still had the nearsighted overlay, even though they were wearing glasses.")
	TEST_ASSERT(!dummy.is_nearsighted_currently(), "Dummy was nearsighted currently even though they were wearing glasses.")

	// Remove the glasses
	QDEL_NULL(glasses)
	TEST_ASSERT(HAS_SCREEN_OVERLAY(dummy, /atom/movable/screen/fullscreen/impaired), "Dummy still had the nearsighted overlay, even though they were wearing glasses.")
	TEST_ASSERT(dummy.is_nearsighted_currently(), "Dummy is not currently nearsighted, after removing their glasses.")

	// And remove nearsightedness wholesale
	dummy.remove_quirk(/datum/quirk/item_quirk/nearsighted)
	dummy.cure_nearsighted("unit_test")
	TEST_ASSERT(!dummy.is_nearsighted(), "Dummy is still nearsighted after being cured of it.")
	TEST_ASSERT(!HAS_SCREEN_OVERLAY(dummy, /atom/movable/screen/fullscreen/impaired), "Dummy still had the nearsighted overlay after being cured of it.")

/**
 * Unit test to ensure eyes are properly blinded and nearsighted by eye damage
 */
/datum/unit_test/eye_damage

/datum/unit_test/eye_damage/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/organ/eyes/eyes = dummy.get_organ_slot(ORGAN_SLOT_EYES)
	TEST_ASSERT_NOTNULL(eyes, "Eye damage unit test spawned a dummy without eyes!")

	// Test blindness due to eye damage
	// Cause critical eye damage
	var/critical_damage = eyes.maxHealth
	eyes.set_organ_damage(critical_damage) // ~50 damage
	TEST_ASSERT(dummy.is_blind(), "After sustaining critical eye damage ([critical_damage]), the dummy was not blind.")
	// Heal eye damage
	eyes.set_organ_damage(0)
	TEST_ASSERT(!dummy.is_blind(), "After healing from critical eye damage, the dummy was not unblinded.")

	// Test nearsightedness due to eye damage
	var/datum/status_effect/grouped/nearsighted/nearsightedness
	// Cause minor eye damage
	var/minor_damage = eyes.maxHealth * 0.5
	eyes.apply_organ_damage(minor_damage) //~25 ddamage
	TEST_ASSERT(dummy.is_nearsighted(), "After sustaining minor eye damage ([minor_damage]), the dummy was not nearsighted.")
	// Check that the severity is correct
	nearsightedness = dummy.is_nearsighted()
	TEST_ASSERT_EQUAL(nearsightedness.get_severity(), 2, "After taking minor eye damage, the dummy's nearsightedness was the incorrect severity.")
	nearsightedness = null
	// Heal eye damage
	eyes.set_organ_damage(0)
	TEST_ASSERT(!dummy.is_nearsighted(), "After curing eye damage, the dummy was still nearsighted.")

	// Cause major eye damage
	var/major_damage = eyes.maxHealth * 0.7
	eyes.apply_organ_damage(major_damage) //~35 damage
	TEST_ASSERT(dummy.is_nearsighted(), "After sustaining major eye damage ([major_damage]), the dummy was not nearsighted.")
	// Check that the severity is correct
	nearsightedness = dummy.is_nearsighted()
	TEST_ASSERT_EQUAL(nearsightedness.get_severity(), 3, "After taking major eye damage, the dummy's nearsightedness was the incorrect severity.")
	nearsightedness = null
	// Heal eye damage
	eyes.set_organ_damage(0)
	TEST_ASSERT(!dummy.is_nearsighted(), "After curing eye damage, the dummy was still nearsighted.")

#define CORRECTABLE_SOURCE "\[CORRECTABLE SOURCE\]"
#define ABSOLUTE_SOURCE "\[ABSOLUTE SOURCE\]"
/datum/unit_test/nearsighted_effect
/*!
 * This tests [/datum/status_effect/grouped/nearsighted]
 * * Application (correctable/absolute)
 * * Removal (absolute/correctable)
 */
/datum/unit_test/nearsighted_effect/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)
	var/datum/status_effect/grouped/nearsighted/myopia

	/* APPLICATION */
	// Let's test regular nearsightedness first
	dummy.assign_nearsightedness(CORRECTABLE_SOURCE, 2, TRUE)
	validate_correctable_severity(dummy, "after being given [CORRECTABLE_SOURCE]", 2, list(
		CORRECTABLE_SOURCE = 2,
	))

	myopia = dummy.is_nearsighted()
	TEST_ASSERT_EQUAL(myopia.get_severity(), 2, "Final severity amount was incorrect when checked with only correctable nearsightedness.")

	// We'll test if the glasses work as expected...
	validate_glasses_behaviour(dummy, "after being given [CORRECTABLE_SOURCE]", 0, 2)

	// Let's apply an absolute source, we'll test two things at once
	dummy.assign_nearsightedness(ABSOLUTE_SOURCE, 1, FALSE)
	validate_absolute_severity(dummy, "after being given [ABSOLUTE_SOURCE]", 1, list(
		ABSOLUTE_SOURCE = 1,
	))

	myopia = dummy.is_nearsighted()
	TEST_ASSERT_EQUAL(myopia.get_severity(), 2, "Final severity amount wasn't equal to [CORRECTABLE_SOURCE] when a smaller absolute source was present.")

	// Do the glasses still work after adding an absolute source?
	validate_glasses_behaviour(dummy, "after being given [ABSOLUTE_SOURCE]", 1, 2)

	/* REMOVAL */
	//There are two different ways a source can be removed, let's test both of them
	dummy.cure_nearsighted(ABSOLUTE_SOURCE)
	validate_absolute_severity(dummy, "after removing [ABSOLUTE_SOURCE]", 0, list())

	myopia = dummy.is_nearsighted()
	TEST_ASSERT_NOTNULL(myopia, "Dummy lost nearsightedness after removing [CORRECTABLE_SOURCE] even though there were still sources left.")

	//After this, the effect should be removed.
	dummy.assign_nearsightedness(CORRECTABLE_SOURCE, 0, TRUE)
	TEST_ASSERT(!dummy.is_nearsighted(), "Dummy was still nearsighted after all sources were removed.")

/datum/unit_test/nearsighted_effect/proc/validate_source_contents(checking, status, list/current_sources, list/expected_sources)
	TEST_ASSERT_EQUAL(length(current_sources), length(expected_sources), "[checking] had a different amount of contents than expected [status].")
	//We'll copy the list to make sure we got all the sources
	var/list/hopefully_empty_result = expected_sources.Copy()
	for(var/expected_source in expected_sources)
		var/expected_severity = expected_sources[expected_source]
		TEST_ASSERT_NOTNULL(current_sources[expected_source], "[expected_source] wasn't in [checking] [status].")
		TEST_ASSERT_EQUAL(current_sources[expected_source], expected_severity, "The severity for [expected_source] in [checking] [status] wasn't as expected.")
		hopefully_empty_result -= expected_source
	TEST_ASSERT(!length(hopefully_empty_result), "[checking] has all the sources we wanted [status], but there were unexpected extra sources.")

/datum/unit_test/nearsighted_effect/proc/validate_correctable_severity(mob/living/carbon/human/dummy, status, expected_final_severity, list/expected_sources)
	//! This proc expects the dummy to be nearsighted
	var/datum/status_effect/grouped/nearsighted/myopia = dummy.is_nearsighted()
	TEST_ASSERT_NOTNULL(myopia, "Dummy was not nearsighted when given correctable nearsightedness [status].")

	validate_source_contents("correctable sources", status, myopia.correctable_sources, expected_sources)
	TEST_ASSERT_EQUAL(myopia.correctable_severity, expected_final_severity, "The determined correctable severity [status] was wrong.")

/datum/unit_test/nearsighted_effect/proc/validate_absolute_severity(mob/living/carbon/human/dummy, status, expected_final_severity, list/expected_sources)
	//! This proc expects the dummy to be nearsighted
	var/datum/status_effect/grouped/nearsighted/myopia = dummy.is_nearsighted()
	TEST_ASSERT_NOTNULL(myopia, "Dummy was not nearsighted when given absolute nearsightedness [status].")

	validate_source_contents("absolute sources", status, myopia.absolute_sources, expected_sources)
	TEST_ASSERT_EQUAL(myopia.absolute_severity, expected_final_severity, "The determined absolute severity [status] was wrong.")

/// Makes sure that having vision corrected affects the dummy and preserves vision
/datum/unit_test/nearsighted_effect/proc/validate_glasses_behaviour(mob/living/carbon/human/dummy, status, expected_severity_with, expected_severity_without)
	//! This proc expects the dummy to be nearsighted
	var/obj/item/clothing/glasses/regular/prescriptions = allocate(/obj/item/clothing/glasses/regular)
	dummy.equip_to_slot_if_possible(prescriptions, ITEM_SLOT_EYES)
	var/datum/status_effect/grouped/nearsighted/myopia = dummy.is_nearsighted()

	TEST_ASSERT_NOTNULL(myopia, "Dummy no longer had the nearsighted status after putting on glasses. They should still be nearsighted.")
	TEST_ASSERT(!dummy.is_nearsighted_currently(), "Dummy was nearsighted currently [status] even though they were wearing glasses.")
	TEST_ASSERT_EQUAL(myopia.get_severity(), expected_severity_with, "get_severity() returned an impossible severity amount when putting on glasses [status].")

	// Check their overlay, they might need to lose it
	if(expected_severity_with == 0)
		TEST_ASSERT(!HAS_SCREEN_OVERLAY(dummy, /atom/movable/screen/fullscreen/impaired), "Dummy still had the nearsighted overlay when putting glasses on [status].")
	else
		TEST_ASSERT(HAS_SCREEN_OVERLAY(dummy, /atom/movable/screen/fullscreen/impaired), "Dummy lost the nearsighted overlay when putting glasses on [status].")

	// Now take them off
	QDEL_NULL(prescriptions)
	TEST_ASSERT(dummy.is_nearsighted_currently(), "Dummy didn't become nearsighted currently [status] even though they weren't wearing glasses.")
	TEST_ASSERT_EQUAL(myopia.get_severity(), expected_severity_without, "get_severity() returned an impossible severity amount when taking off glasses [status].")

	// Check their overlay again, they may or may not should still have it
	if(expected_severity_without != 0)
		TEST_ASSERT(HAS_SCREEN_OVERLAY(dummy, /atom/movable/screen/fullscreen/impaired), "Dummy had the nearsighted overlay when putting glasses on [status].")
	else //If the bottom condition is hit, what are we even doing man
		TEST_ASSERT(!HAS_SCREEN_OVERLAY(dummy, /atom/movable/screen/fullscreen/impaired),
		"Dummy had the nearsighted overlay when putting glasses on [status].")


#undef CORRECTABLE_SOURCE
#undef ABSOLUTE_SOURCE

#undef HAS_SCREEN_OVERLAY
#undef HAS_CLIENT_COLOR
