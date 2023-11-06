/// Tests to make sure tail wagging behaves as expected
/datum/unit_test/tail_wag

/datum/unit_test/tail_wag/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/organ/external/tail/cat/dummy_tail = allocate(/obj/item/organ/external/tail/cat)
	dummy_tail.Insert(dummy, special = TRUE, drop_if_replaced = FALSE)

	// SANITY TEST

	// start wagging
	SEND_SIGNAL(dummy, COMSIG_ORGAN_WAG_TAIL, TRUE)
	if(!(dummy_tail.wag_flags & WAG_WAGGING))
		TEST_FAIL("Tail did not start wagging when it should have!")

	// stop wagging
	SEND_SIGNAL(dummy, COMSIG_ORGAN_WAG_TAIL, FALSE)
	if(dummy_tail.wag_flags & WAG_WAGGING)
		TEST_FAIL("Tail did not stop wagging when it should have!")

	// TESTING WAG_ABLE FLAG

	// flip the wag flag to unwaggable
	dummy_tail.wag_flags &= ~WAG_ABLE

	// try to wag it again
	SEND_SIGNAL(dummy, COMSIG_ORGAN_WAG_TAIL, TRUE)
	if(dummy_tail.wag_flags & WAG_WAGGING)
		TEST_FAIL("Tail should not have the ability to wag, yet it did!")

	// flip the wag flag to waggable again
	dummy_tail.wag_flags |= WAG_ABLE

	// start wagging again
	SEND_SIGNAL(dummy, COMSIG_ORGAN_WAG_TAIL, TRUE)
	if(!(dummy_tail.wag_flags & WAG_WAGGING))
		TEST_FAIL("Tail did not start wagging when it should have!")

	// TESTING TAIL REMOVAL

	// remove the tail
	dummy_tail.Remove(dummy, special = TRUE)

	// check if tail is still wagging after being removed
	if(dummy_tail.wag_flags & WAG_WAGGING)
		TEST_FAIL("Tail was still wagging after being removed!")

	// try to wag the removed tail
	SEND_SIGNAL(dummy, COMSIG_ORGAN_WAG_TAIL, TRUE)
	if(dummy_tail.wag_flags & WAG_WAGGING)
		TEST_FAIL("A disembodied tail was able to start wagging!")

	// TESTING MOB DEATH

	// put it back and start wagging again
	dummy_tail.Insert(dummy, special = TRUE, drop_if_replaced = FALSE)
	SEND_SIGNAL(dummy, COMSIG_ORGAN_WAG_TAIL, TRUE)
	if(!(dummy_tail.wag_flags & WAG_WAGGING))
		TEST_FAIL("Tail did not start wagging when it should have!")

	// kill the mob, see if it stops wagging
	dummy.adjustBruteLoss(9001)
	if(dummy_tail.wag_flags & WAG_WAGGING)
		TEST_FAIL("A mob's tail was still wagging after being killed!")

	// check if we are still able to wag the tail after death
	SEND_SIGNAL(dummy, COMSIG_ORGAN_WAG_TAIL, TRUE)
	if(dummy_tail.wag_flags & WAG_WAGGING)
		TEST_FAIL("A dead mob was able to wag their tail!")
