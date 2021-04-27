///Used to test the completeness of the reference finder proc.
/datum/unit_test/find_reference_sanity

/atom/movable/ref_holder
	var/atom/movable/ref_test/test
	var/list/test_list = list()
	var/list/test_assoc_list = list()

/atom/movable/ref_test
	var/atom/movable/ref_test/self_ref

/datum/unit_test/find_reference_sanity/Run()
	var/atom/movable/ref_test/victim = allocate(/atom/movable/ref_test)
	var/atom/movable/ref_holder/testbed = allocate(/atom/movable/ref_holder)

	//Sanity check
	victim.DoSearchVar(testbed, "Sanity Check", search_time = 1) //We increment search time to get around an optimization
	TEST_ASSERT(!victim.found_refs.len, "The ref-tracking tool found a ref where none existed")
	victim.found_refs.Cut()

	//Set up for the first round of tests
	testbed.test = victim
	testbed.test_list += victim
	testbed.test_assoc_list["baseline"] = victim

	victim.DoSearchVar(testbed, "First Run", search_time = 2)

	TEST_ASSERT(victim.found_refs["test"], "The ref-tracking tool failed to find a regular value")
	TEST_ASSERT(victim.found_refs[testbed.test_list], "The ref-tracking tool failed to find a list entry")
	TEST_ASSERT(victim.found_refs[testbed.test_assoc_list], "The ref-tracking tool failed to find an assoc list value")
	victim.found_refs.Cut()
	testbed.test = null
	testbed.test_list.Cut()
	testbed.test_assoc_list.Cut()

	//Second round, bit harder this time
	testbed.overlays += victim
	testbed.vis_contents += victim
	testbed.test_assoc_list[victim] = TRUE

	victim.DoSearchVar(testbed, "Second Run", search_time = 3)

	//This is another sanity check
	TEST_ASSERT(!victim.found_refs[testbed.overlays], "The ref-tracking tool found an overlays entry? That shouldn't be possible")
	TEST_ASSERT(victim.found_refs[testbed.vis_contents], "The ref-tracking tool failed to find a vis_contents entry")
	TEST_ASSERT(victim.found_refs[testbed.test_assoc_list], "The ref-tracking tool failed to find an assoc list key")
	victim.found_refs.Cut()
	testbed.overlays.Cut()
	testbed.vis_contents.Cut()
	testbed.test_assoc_list.Cut()

	//Let's get a bit esoteric
	victim.self_ref = victim
	var/list/to_find = list(victim)
	testbed.test_list += list(to_find)
	var/list/to_find_assoc = list(victim)
	testbed.test_assoc_list["Nesting"] = to_find_assoc

	victim.DoSearchVar(victim, "Third Run Self", search_time = 4)
	victim.DoSearchVar(testbed, "Third Run Testbed", search_time = 4)
	TEST_ASSERT(victim.found_refs["self_ref"], "The ref-tracking tool failed to find a self reference")
	TEST_ASSERT(victim.found_refs[to_find], "The ref-tracking tool failed to find a nested list entry")
	TEST_ASSERT(victim.found_refs[to_find_assoc], "The ref-tracking tool failed to find a nested assoc list entry")
	victim.found_refs.Cut()
	victim.self_ref = null
	to_find.Cut()
	testbed.test_list.Cut()
	to_find_assoc.Cut()
	testbed.test_assoc_list.Cut()
