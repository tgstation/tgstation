/// Test lings don't die when decapitated.
/datum/unit_test/ling_decap

/datum/unit_test/ling_decap/Run()
	var/mob/living/carbon/human/ling = allocate(/mob/living/carbon/human/consistent)
	ling.mind_initialize()
	ling.mind.add_antag_datum(/datum/antagonist/changeling)

	var/obj/item/bodypart/head/noggin = ling.get_bodypart(BODY_ZONE_HEAD)
	noggin.dismember()
	TEST_ASSERT_NULL(ling.get_bodypart(BODY_ZONE_HEAD), "Changeling failed to be decapitated.")
	TEST_ASSERT_NULL(noggin.brainmob.mind, "Changeling's mind was moved to their head after decapitation, but it should have remained in their body.")

	var/obj/item/organ/internal/brain/oldbrain = noggin.brain
	noggin.drop_organs()
	TEST_ASSERT_NULL(noggin.brain, "Changeling's head failed to drop its brain.")
	TEST_ASSERT_NULL(oldbrain.brainmob.mind, "Changeling's mind was moved to their brain after decapitation and organ dropping, but it should have remained in their body.")

	TEST_ASSERT_EQUAL(ling.stat, CONSCIOUS, "Changeling was not conscious after losing their head.")

	// Cleanup
	qdel(noggin)
	for(var/obj/item/organ/leftover in ling.loc)
		qdel(leftover)
