/// Test that stop, drop, and roll lowers fire stacks
/datum/unit_test/stop_drop_and_roll/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)

	TEST_ASSERT_EQUAL(human.fire_stacks, 0, "Human does not have 0 fire stacks pre-ignition")

	human.adjust_fire_stacks(5)
	human.ignite_mob()

	TEST_ASSERT_EQUAL(human.fire_stacks, 5, "Human does not have 5 fire stacks pre-resist")

	// Stop, drop, and roll has a sleep call. This would delay the test, and is not necessary.
	call_async(human, /mob/living/verb/resist)

	TEST_ASSERT(human.fire_stacks < 5, "Human did not lower fire stacks after resisting")

/// Test that you can resist out of a container
/datum/unit_test/container_resist/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	var/obj/structure/closet/closet = allocate(/obj/structure/closet, get_turf(human))

	closet.open(human)
	TEST_ASSERT(!(human in closet.contents), "Human was in the contents of an open closet")

	closet.close(human)
	TEST_ASSERT(human in closet.contents, "Human was not in the contents of the closed closet")

	human.resist()
	TEST_ASSERT(!(human in closet.contents), "Human resisted out of a standard closet, but was still in it")
