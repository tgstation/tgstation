/// Test lings don't die when decapitated.
/datum/unit_test/ling_decap

/datum/unit_test/ling_decap/Run()
	var/mob/living/carbon/human/ling = allocate(/mob/living/carbon/human/consistent)
	ling.mind_initialize()
	ling.mind.add_antag_datum(/datum/antagonist/changeling)

	var/obj/item/bodypart/head/noggin = ling.get_bodypart(BODY_ZONE_HEAD)
	noggin.dismember()
	TEST_ASSERT_NULL(ling.get_bodypart(BODY_ZONE_HEAD), "Changeling failed to be decapitated.")
	var/obj/item/organ/brain/brain = locate(/obj/item/organ/brain) in noggin
	TEST_ASSERT_NULL(brain.brainmob.mind, "Changeling's mind was moved to their brain after decapitation, but it should have remained in their body.")

	var/obj/item/organ/brain/oldbrain = locate(/obj/item/organ/brain) in noggin
	noggin.drop_organs()
	TEST_ASSERT_NULL(locate(/obj/item/organ/brain) in noggin, "Changeling's head failed to drop its brain.")
	TEST_ASSERT_NULL(oldbrain.brainmob.mind, "Changeling's mind was moved to their brain after decapitation and organ dropping, but it should have remained in their body.")

	TEST_ASSERT_EQUAL(ling.stat, CONSCIOUS, "Changeling was not conscious after losing their head.")

	// Cleanup
	qdel(noggin)
	for(var/obj/item/organ/leftover in ling.loc)
		qdel(leftover)

/// Tests people get decapitated properly.
/datum/unit_test/normal_decap

/datum/unit_test/normal_decap/Run()
	var/mob/living/carbon/human/normal_guy = allocate(/mob/living/carbon/human/consistent)
	normal_guy.mind_initialize()
	var/my_guys_mind = normal_guy.mind

	var/obj/item/bodypart/head/noggin = normal_guy.get_bodypart(BODY_ZONE_HEAD)
	noggin.dismember()
	var/obj/item/organ/brain/brain = locate(/obj/item/organ/brain) in noggin
	TEST_ASSERT_EQUAL(brain.brainmob.mind, my_guys_mind, "Dummy's mind was not moved to their brain after decapitation.")

	var/obj/item/organ/brain/oldbrain = locate(/obj/item/organ/brain) in noggin
	noggin.drop_organs()
	TEST_ASSERT_EQUAL(oldbrain.brainmob.mind, my_guys_mind, "Dummy's mind was not moved to their brain after being removed from their head.")

	// Cleanup
	qdel(noggin)
	for(var/obj/item/organ/leftover in normal_guy.loc)
		qdel(leftover)
