/// Puts a consistent assistant into an emagged recycler, and verifies that all intended behavior of an emagged recycler occurs (chewing up all the clothing, applying a level of melee damage, etc.)
/datum/unit_test/human_through_recycler

/datum/unit_test/human_through_recycler/Run()
	var/mob/living/carbon/human/assistant = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left) // we should be in the bottom_left by default, but let's be sooper dooper sure :)
	var/obj/machinery/recycler/chewer = allocate(/obj/machinery/recycler/deathtrap, get_step(run_loc_floor_bottom_left, EAST)) //already existing subtype that has emagged set to TRUE, so it shall CHEW. Put it directly right to the assistant to mimick a player entering the recycler.
	assistant.equipOutfit(/datum/outfit/job/assistant/consistent) // consistent assistant juuuust in case
	var/turf/open/stage = get_turf(chewer)
	assistant.forceMove(stage) // put the assistant in the recycler, to ensure that the recycler still registers incoming input.

	// okay, let's first test the basics of how an emagged recycler should operate
	TEST_ASSERT_NULL(QDELETED(assistant), "Assistant was deleted by the emagged recycler!") // The assistant should not be deleted by the recycler.
	if(assistant.stat < UNCONSCIOUS)
		TEST_FAIL("Assistant was not made unconscious by the emagged recycler!") // crush_living() on the recycler should have made the assistant unconscious or worse.
	// crush_living() on the recycler should have applied the crush_damage to the assistant.
	var/damage_incurred = assistant.getBruteLoss()
	TEST_ASSERT_EQUAL(damage_incurred, chewer.crush_damage, "Assistant did not take the expected amount of brute damage ([chewer.crush_damage]) from the emagged recycler! Took ([damage_incurred]) instead.")
	TEST_ASSERT(chewer.bloody, "The emagged recycler did not become bloody after crushing the assistant!")

	// Now, let's test to see if all of their clothing got properly deleted.
	TEST_ASSERT_EQUAL(length(assistant.contents), 0, "Assistant still has items in its contents after being put through an emagged recycler!")
	// Consistent Assistants will always have the following: ID, PDA, backpack, a uniform, a headset, and a pair of shoes. If any of these are still present, then the recycler did not properly delete the assistant's clothing.
	// However, let's check for EVERYTHING just in case, because we don't want to miss anything.
	// This is just what we expect to be deleted.
	TEST_ASSERT_NULL(assistant.w_uniform, "Assistant still has a jumpsuit (undersuit) on after being put through an emagged recycler!")
	TEST_ASSERT_NULL(assistant.wear_id, "Assistant still has an ID on after being put through an emagged recycler!")
	TEST_ASSERT_NULL(assistant.shoes, "Assistant still has shoes on after being put through an emagged recycler!")
	TEST_ASSERT_NULL(assistant.belt, "Assistant still has an item in their belt slot after being put through an emagged recycler!")
	TEST_ASSERT_NULL(assistant.back, "Assistant still has an item in their back slot (backpack) after being put through an emagged recycler!")
	TEST_ASSERT_NULL(assistant.ears, "Assistant still has a headset on after being put through an emagged recycler!")

	// This category is stuff that shouldn't exist in the first place, but let's test it anyways in case we decide consistent assistants should have more clothing in the future.
	// Short point short, if any of the following error and none of these are present in the datum for this outfit, what the fuck?
	TEST_ASSERT_NULL(assistant.wear_suit, "Assistant still has an oversuit on after being put through an emagged recycler!")
	TEST_ASSERT_NULL(assistant.gloves, "Assistant still has gloves on after being put through an emagged recycler!")
	TEST_ASSERT_NULL(assistant.head, "Assistant still has a head covering item on after being put through an emagged recycler!")
	TEST_ASSERT_NULL(assistant.wear_mask, "Assistant still has a mask on after being put through an emagged recycler!")
	TEST_ASSERT_NULL(assistant.l_store, "Assistant still has an item in their left pocket after being put through an emagged recycler!")
	TEST_ASSERT_NULL(assistant.r_store, "Assistant still has an item in their right pocket after being put through an emagged recycler!")
	TEST_ASSERT_NULL(assistant.s_store, "Assistant still has an item in their suit storage slot after being put through an emagged recycler!")
	TEST_ASSERT_NULL(assistant.glasses, "Assistant still has glasses on after being put through an emagged recycler!")


