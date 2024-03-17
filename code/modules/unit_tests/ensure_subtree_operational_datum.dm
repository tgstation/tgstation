/// The subtree that requires the operational datum.
#define REQUIRED_SUBTREE "required_subtree"
/// The list of typepaths of applicable operational datums that would satisfy the requirement.
#define REQUIRED_OPERATIONAL_DATUMS "required_operational_datums"

/// Unit Test that ensure that if we add a specific planning subtree to a basic mob's planning tree, that we also have the operational datum needed for it (component/element).
/// This can be extended to other "mandatory" operational datums for certain subtrees to work.
/datum/unit_test/ensure_subtree_operational_datum
	/// Associated list of mobs that we need to test this on. Key is the typepath of the mob, value is a list of the planning subtree and the operational datums that are required for it.
	var/list/testable_mobs = list()

/datum/unit_test/ensure_subtree_operational_datum/Run()
	gather_testable_mobs()
	test_applicable_mobs()

/// First, look for all mobs that have a planning subtree that requires an element, then add it to the list for stuff to test afterwards. Done like this to not have one mumbo proc that's hard to read.
/datum/unit_test/ensure_subtree_operational_datum/proc/gather_testable_mobs()
	for(var/mob/living/basic/checkable_mob as anything in subtypesof(/mob/living/basic))
		var/datum/ai_controller/testable_controller = initial(checkable_mob.ai_controller)
		if(isnull(testable_controller))
			continue

		// we can't do inital() memes on lists so it's allocation time
		testable_controller = allocate(testable_controller)
		var/list/ai_planning_subtrees = testable_controller.planning_subtrees // list of instantiated datums. easy money
		if(!length(ai_planning_subtrees))
			continue

		for(var/datum/ai_planning_subtree/testable_subtree as anything in ai_planning_subtrees)
			var/list/necessary_datums = testable_subtree.operational_datums
			if(isnull(necessary_datums))
				continue

			testable_mobs[checkable_mob] = list(
				REQUIRED_OPERATIONAL_DATUMS = necessary_datums,
				REQUIRED_SUBTREE = testable_subtree.type,
			)

/// Then, test the mobs that we've found
/datum/unit_test/ensure_subtree_operational_datum/proc/test_applicable_mobs()
	for(var/mob/living/basic/checkable_mob as anything in testable_mobs)
		var/list/checkable_mob_data = testable_mobs[checkable_mob]
		checkable_mob = allocate(checkable_mob)

		var/datum/ai_planning_subtree/test_subtree = checkable_mob_data[REQUIRED_SUBTREE]
		var/list/trait_sources = GET_TRAIT_SOURCES(checkable_mob, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM)
		if(!length(trait_sources)) // yes yes we could use `COUNT_TRAIT_SOURCES` but why invoke the same macro twice
			TEST_FAIL("The mob [checkable_mob] ([checkable_mob.type]) does not have ANY instances of TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM, but has a planning subtree ([test_subtree]) that requires it!")
			continue

		var/has_element = FALSE
		var/list/testable_operational_datums = checkable_mob_data[REQUIRED_OPERATIONAL_DATUMS]
		for(var/iterable in trait_sources)
			if(iterable in testable_operational_datums)
				has_element = TRUE
				break

		if(!has_element)
			var/list/message_list = list("The mob [checkable_mob] ([checkable_mob.type]) has a planning subtree ([test_subtree]) that requires a component/element, but does not have any!")
			message_list += "Needs one of the following to satisfy the requirement: ([testable_operational_datums.Join(", ")])"
			TEST_FAIL(message_list.Join(" "))

#undef REQUIRED_SUBTREE
#undef REQUIRED_OPERATIONAL_DATUMS
