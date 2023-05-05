/// Test that stop, drop, and roll lowers fire stacks
/datum/unit_test/stop_drop_and_roll/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)

	TEST_ASSERT_EQUAL(human.fire_stacks, 0, "Human does not have 0 fire stacks pre-ignition")

	human.adjust_fire_stacks(5)
	human.ignite_mob()

	TEST_ASSERT_EQUAL(human.fire_stacks, 5, "Human does not have 5 fire stacks pre-resist")

	// Stop, drop, and roll has a sleep call. This would delay the test, and is not necessary.
	call_async(human, /mob/living/verb/resist)

	//since resist() is a verb that possibly queues its actual execution for the next tick, we need to make the subsystem that handles the delayed execution process
	//the callback. either that or sleep ourselves and see if it ran.
	SSverb_manager.run_verb_queue()

	TEST_ASSERT(human.fire_stacks < 5, "Human did not lower fire stacks after resisting")

/// Test that you can resist out of a container
/datum/unit_test/container_resist/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	var/obj/structure/locker/locker = allocate(/obj/structure/locker, get_turf(human))

	locker.open(human)
	TEST_ASSERT(!(human in locker.contents), "Human was in the contents of an open locker")

	locker.close(human)
	TEST_ASSERT(human in locker.contents, "Human was not in the contents of the closed locker")

	human.resist()

	//since resist() is a verb that possibly queues itself for the next tick, we need to make the subsystem that handles the delayed execution process
	//the callback. either that or sleep ourselves and see if it ran.
	SSverb_manager.run_verb_queue()

	TEST_ASSERT(!(human in locker.contents), "Human resisted out of a standard locker, but was still in it")
