/// Unit Test that ensure that if we add a specific planning subtree to a basic mob's planning tree, that we also have the element.
/// This can be extended to other "mandatory" elements for certain subtrees to work.
/datum/unit_test/ensure_subtree_element
	/// Associated list of mobs that we need to test this on. Key is the typepath of the mob, value is a list of the element and the subtree that requires it.
	var/list/testable_mobs = list()

/datum/unit_test/ensure_subtree_element/Run()
	gather_testable_mobs()
	test_applicable_mobs()

/// First, look for all mobs that have a planning subtree that requires an element, then add it to the list for stuff to test afterwards. Done like this to not have one mumbo proc that's hard to read.
/datum/unit_test/ensure_subtree_element/proc/gather_testable_mobs()
	for(var/mob/living/basic/checkable_mob as anything in subtypesof(/mob/living/basic))
		var/datum/ai_controller/testable_controller = initial(checkable_mob.ai_controller)
		if(isnull(testable_controller))
			continue
		// we can't do inital() memes on lists so it's allocation time
		testable_controller = allocate(testable_controller)
		var/list/ai_planning_subtress = testable_controller.planning_subtrees
		if(!length(ai_planning_subtress))
			continue

		for(var/datum/ai_planning_subtree/subtree as anything in ai_planning_subtress) // we do as anything here
			TEST_ASSERT(istype(subtree), "The planning subtree on [checkable_mob] is not a valid type! Got [subtree]") // so we can run this check here because you never know sometimes
			var/datum/element/necessary_element = initial(subtree.necessary_element)
			if(isnull(necessary_element))
				continue

			testable_mobs[checkable_mob] = list(
				subtree,
				necessary_element,
			)

/// Then, test the mobs that we've found
/datum/unit_test/ensure_subtree_element/proc/test_applicable_mobs()
	for(var/mob/living/basic/checkable_mob as anything in testable_mobs)
		var/list/checkable_mob_data = testable_mobs[checkable_mob]
		checkable_mob = allocate(checkable_mob)

		var/datum/ai_planning_subtree/test_subtree = checkable_mob_data[1]
		var/list/trait_sources = GET_TRAIT_SOURCES(checkable_mob, TRAIT_SUBTREE_REQUIRED_ELEMENT)
		if(!length(trait_sources)) // yes yes we could use `COUNT_TRAIT_SOURCES` but why invoke the same macro twice
			TEST_FAIL("The mob [checkable_mob] ([checkable_mob.type]) does not have ANY instances of TRAIT_SUBTREE_REQUIRED_ELEMENT, but has a planning subtree ([test_subtree]) that requires it!")
			continue

		var/has_element = FALSE
		var/datum/element/testable_element = checkable_mob_data[2]
		for(var/iterable in trait_sources)
			if(iterable == testable_element)
				has_element = TRUE
				break

		TEST_ASSERT(has_element, "The mob [checkable_mob] ([checkable_mob.type]) has a planning subtree ([test_subtree]) that requires the element [testable_element], but does not have it!")

