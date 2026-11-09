/// Tests that neurine reagent properly creates and cleans up temporary traumas
/datum/unit_test/neurine_trauma_cleanup

/datum/unit_test/neurine_trauma_cleanup/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)
	dummy.mind_initialize()

	// Create neurine reagent
	var/datum/reagent/inverse/neurine/neurine_reagent = new()

	// Ensure the dummy has a brain
	var/obj/item/organ/brain/brain = dummy.get_organ_slot(ORGAN_SLOT_BRAIN)
	TEST_ASSERT(brain, "Test dummy should have a brain")

	// Get initial trauma count
	var/initial_trauma_count = length(brain.traumas)

	// Trigger neurine to add a trauma (simulate on_mob_life)
	// We need to ensure it creates a trauma by setting high purity
	neurine_reagent.creation_purity = 10 // This ensures SPT_PROB(creation_purity*10) will be 100%
	neurine_reagent.on_mob_life(dummy, 1, 1)

	// Check that a trauma was added
	var/post_add_trauma_count = length(brain.traumas)
	TEST_ASSERT(post_add_trauma_count == initial_trauma_count + 1, "Neurine should have added exactly one trauma")
	TEST_ASSERT(neurine_reagent.temp_trauma, "Neurine should have stored a reference to the trauma it created")

	// Verify the trauma is actually there and has the right resilience
	var/datum/brain_trauma/added_trauma = neurine_reagent.temp_trauma
	TEST_ASSERT(added_trauma in brain.traumas, "The trauma stored in temp_trauma should be in the brain's trauma list")
	TEST_ASSERT(added_trauma.resilience == TRAUMA_RESILIENCE_MAGIC, "Neurine-created trauma should have TRAUMA_RESILIENCE_MAGIC")

	// Now simulate the reagent being deleted (on_mob_delete)
	neurine_reagent.on_mob_delete(dummy)

	// Check that the trauma was properly removed
	var/post_delete_trauma_count = length(brain.traumas)
	TEST_ASSERT(post_delete_trauma_count == initial_trauma_count, "Neurine trauma should have been removed when reagent was deleted")
	TEST_ASSERT(!neurine_reagent.temp_trauma, "Neurine should have cleared its temp_trauma reference")
	TEST_ASSERT(!(added_trauma in brain.traumas), "The specific trauma should no longer be in the brain's trauma list")

	// Test special case: imaginary friend should NOT be removed
	var/datum/brain_trauma/special/imaginary_friend/friend_trauma = new()
	brain.add_trauma_to_traumas(friend_trauma)
	friend_trauma.owner = dummy
	friend_trauma.resilience = TRAUMA_RESILIENCE_MAGIC
	neurine_reagent.temp_trauma = friend_trauma

	var/pre_friend_test_count = length(brain.traumas)
	neurine_reagent.on_mob_delete(dummy)

	// Imaginary friend should still be there
	TEST_ASSERT(length(brain.traumas) == pre_friend_test_count, "Imaginary friend trauma should not be removed by neurine cleanup")
	TEST_ASSERT(friend_trauma in brain.traumas, "Imaginary friend should still be in trauma list")

	// Clean up for next test
	qdel(friend_trauma)
	qdel(neurine_reagent)
