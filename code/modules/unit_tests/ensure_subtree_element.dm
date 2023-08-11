/// Unit Test that ensure that if we add a specific planning subtree to a basic mob's planning tree, that we also have the element.
/// This can be extended to other "mandatory" elements for certain subtrees to work.
/datum/unit_test/ensure_retaliation
	/// Associated list of mobs that we need to test this on. Key is the typepath of the mob, value is the element that we need to check for.
	var/list/testable_mobs = list()

/datum/unit_test/ensure_retaliation/Run()
	gather_testable_mobs()

/// First, look for all mobs that
/datum/unit_test/ensure_retaliation/proc/gather_testable_mobs()

	for(var/mob/living/basic/test_mob as anything in subtypesof(/mob/living/basic))
		if(isnull(initial(test_mob.ai_controller)))
			continue
		// we can't do inital() memes on lists so it's allocation time
		//test_mob = allocate(test_mob)
		var/datum/ai_controller/testable_controller = allocate(test_mob.ai_controller)
		var/list/ai_planning_subtress = testable_controller.planning_subtrees
		if(!length(ai_planning_subtress))
			continue

		for(var/datum/ai_planning_subtree/subtree as anything in ai_planning_subtress) // we do as anything here
			TEST_ASSERT(istype(subtree), "The planning subtree on [test_mob] is not a valid type! Got [subtree]") // so we can run this check here because you never know sometimes
			var/datum/element/necessary_element = initial(subtree.necessary_element)
			if(isnull(necessary_element))
				continue

			testable_mobs[test_mob] = necessary_element

