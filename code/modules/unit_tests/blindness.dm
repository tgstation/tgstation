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
	TEST_ASSERT(HAS_CLIENT_COLOR(dummy, /datum/client_colour/monochrome/blind), "Dummy, [status_message], did not have the monochrome client color.")
	TEST_ASSERT(HAS_SCREEN_OVERLAY(dummy, /atom/movable/screen/fullscreen/blind), "Dummy, [status_message], did not have a blind screen overlay in their list of screens.")

/datum/unit_test/blindness/proc/check_if_not_blind(mob/living/carbon/human/dummy, status_message = "after being cured of blindness")
	// Check for no status effect
	TEST_ASSERT(!dummy.is_blind(), "Dummy, [status_message], still had the blindness status effect.")
	// Check that the client color and screen overlay are gone
	TEST_ASSERT(!HAS_CLIENT_COLOR(dummy, /datum/client_colour/monochrome/blind), "Dummy, [status_message], still had the monochrome client color.")
	TEST_ASSERT(!HAS_SCREEN_OVERLAY(dummy, /atom/movable/screen/fullscreen/blind), "Dummy, [status_message], still had the blind sceen overlay.")

/**
 * Unit test to check that nearsighted is added and disabled correctly
 */
/datum/unit_test/nearsightedness

/datum/unit_test/nearsightedness/Run()
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
	var/obj/item/organ/internal/eyes/eyes = dummy.getorganslot(ORGAN_SLOT_EYES)
	TEST_ASSERT_NOTNULL(eyes, "Eye damage unit test spawned a dummy without eyes!")

	// Test blindness due to eye damage
	// Cause critical eye damage
	var/critical_damage = eyes.maxHealth
	eyes.setOrganDamage(critical_damage) // ~50 damage
	TEST_ASSERT(dummy.is_blind(), "After sustaining critical eye damage ([critical_damage]), the dummy was not blind.")
	// Heal eye damage
	eyes.setOrganDamage(0)
	TEST_ASSERT(!dummy.is_blind(), "After healing from critical eye damage, the dummy was not unblinded.")

	// Test nearsightedness due to eye damage
	var/datum/status_effect/grouped/nearsighted/nearsightedness
	// Cause minor eye damage
	var/minor_damage = eyes.maxHealth * 0.5
	eyes.applyOrganDamage(minor_damage) //~25 ddamage
	TEST_ASSERT(dummy.is_nearsighted(), "After sustaining minor eye damage ([minor_damage]), the dummy was not nearsighted.")
	// Check that the severity is correct
	nearsightedness = dummy.is_nearsighted()
	TEST_ASSERT_EQUAL(nearsightedness.overlay_severity, 1, "After taking minor eye damage, the dummy's nearsightedness was the incorrect severity.")
	nearsightedness = null
	// Heal eye damage
	eyes.setOrganDamage(0)
	TEST_ASSERT(!dummy.is_nearsighted(), "After curing eye damage, the dummy was still nearsighted.")

	// Cause major eye damage
	var/major_damage = eyes.maxHealth * 0.7
	eyes.applyOrganDamage(major_damage) //~35 damage
	TEST_ASSERT(dummy.is_nearsighted(), "After sustaining major eye damage ([major_damage]), the dummy was not nearsighted.")
	// Check that the severity is correct
	nearsightedness = dummy.is_nearsighted()
	TEST_ASSERT_EQUAL(nearsightedness.overlay_severity, 2, "After taking major eye damage, the dummy's nearsightedness was the incorrect severity.")
	nearsightedness = null
	// Heal eye damage
	eyes.setOrganDamage(0)
	TEST_ASSERT(!dummy.is_nearsighted(), "After curing eye damage, the dummy was still nearsighted.")

#undef HAS_SCREEN_OVERLAY
#undef HAS_CLIENT_COLOR
