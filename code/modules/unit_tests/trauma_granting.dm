/// Tests that brain traumas can be granted and removed properly.
/datum/unit_test/trauma_granting

/datum/unit_test/trauma_granting/Run()

	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)
	// It's not stricly necessary a mob must have a mind, but some traumas do extra stuff if you have mind.
	dummy.mind_initialize()

	// Following includes some traumas that would require special handling to test.
	var/list/trauma_blacklist = list()
	// Requires a phase be set in New
	trauma_blacklist += typesof(/datum/brain_trauma/hypnosis)
	// Requires another player, sleeps in gain()
	trauma_blacklist += typesof(/datum/brain_trauma/severe/split_personality)
	// Requires another player, sleeps in gain()
	trauma_blacklist += typesof(/datum/brain_trauma/special/imaginary_friend)
	// Requires a obsession target
	trauma_blacklist += typesof(/datum/brain_trauma/special/obsessed)

	for(var/datum/brain_trauma/trauma as anything in typesof(/datum/brain_trauma) - trauma_blacklist)
		if(trauma == initial(trauma.abstract_type))
			continue

		test_trauma(dummy, trauma)

/datum/unit_test/trauma_granting/proc/test_trauma(mob/living/carbon/human/dummy, trauma)
	dummy.gain_trauma(trauma)
	TEST_ASSERT(dummy.has_trauma_type(trauma), "Brain trauma [trauma] failed to grant to dummy")
	dummy.cure_trauma_type(trauma, TRAUMA_RESILIENCE_ABSOLUTE)
	TEST_ASSERT(!dummy.has_trauma_type(trauma), "Brain trauma [trauma] failed to cure from dummy")
