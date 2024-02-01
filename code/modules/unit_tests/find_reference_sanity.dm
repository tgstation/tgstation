///Used to test the completeness of the reference finder proc.
/datum/unit_test/find_reference_sanity

/atom/movable/ref_holder
	var/static/atom/movable/ref_test/static_test
	var/atom/movable/ref_test/test
	var/list/test_list = list()
	var/list/test_assoc_list = list()

/atom/movable/ref_holder/Destroy()
	test = null
	static_test = null
	test_list.Cut()
	test_assoc_list.Cut()
	return ..()

/atom/movable/ref_test
	// Gotta make sure we do a full check
	references_to_clear = INFINITY
	var/atom/movable/ref_test/self_ref

/atom/movable/ref_test/Destroy(force)
	self_ref = null
	return ..()

/datum/unit_test/find_reference_sanity/Run()
	var/atom/movable/ref_test/victim = allocate(/atom/movable/ref_test)
	var/atom/movable/ref_holder/testbed = allocate(/atom/movable/ref_holder)
	SSgarbage.should_save_refs = TRUE

	//Sanity check
	var/refcount = refcount(victim)
	TEST_ASSERT_EQUAL(refcount, 3, "Should be: test references: 0 + baseline references: 3 (victim var,loc,allocated list)")
	victim.DoSearchVar(testbed, "Sanity Check") //We increment search time to get around an optimization

	TEST_ASSERT(!LAZYLEN(victim.found_refs), "The ref-tracking tool found a ref where none existed")
	SSgarbage.should_save_refs = FALSE

/datum/unit_test/find_reference_baseline/Run()
	var/atom/movable/ref_test/victim = allocate(/atom/movable/ref_test)
	var/atom/movable/ref_holder/testbed = allocate(/atom/movable/ref_holder)
	SSgarbage.should_save_refs = TRUE

	//Set up for the first round of tests
	testbed.test = victim
	testbed.test_list += victim
	testbed.test_assoc_list["baseline"] = victim

	var/refcount = refcount(victim)
	TEST_ASSERT_EQUAL(refcount, 6, "Should be: test references: 3 + baseline references: 3 (victim var,loc,allocated list)")
	victim.DoSearchVar(testbed, "First Run")

	TEST_ASSERT(LAZYACCESS(victim.found_refs, "test"), "The ref-tracking tool failed to find a regular value")
	TEST_ASSERT(LAZYACCESS(victim.found_refs, testbed.test_list), "The ref-tracking tool failed to find a list entry")
	TEST_ASSERT(LAZYACCESS(victim.found_refs, testbed.test_assoc_list), "The ref-tracking tool failed to find an assoc list value")
	SSgarbage.should_save_refs = FALSE

/datum/unit_test/find_reference_exotic/Run()
	var/atom/movable/ref_test/victim = allocate(/atom/movable/ref_test)
	var/atom/movable/ref_holder/testbed = allocate(/atom/movable/ref_holder)
	SSgarbage.should_save_refs = TRUE

	//Second round, bit harder this time
	testbed.overlays += victim
	testbed.vis_contents += victim
	testbed.test_assoc_list[victim] = TRUE

	var/refcount = refcount(victim)
	TEST_ASSERT_EQUAL(refcount, 6, "Should be: test references: 3 + baseline references: 3 (victim var,loc,allocated list)")
	victim.DoSearchVar(testbed, "Second Run")

	//This is another sanity check
	TEST_ASSERT(!LAZYACCESS(victim.found_refs, testbed.overlays), "The ref-tracking tool found an overlays entry? That shouldn't be possible")
	TEST_ASSERT(LAZYACCESS(victim.found_refs, testbed.vis_contents), "The ref-tracking tool failed to find a vis_contents entry")
	TEST_ASSERT(LAZYACCESS(victim.found_refs, testbed.test_assoc_list), "The ref-tracking tool failed to find an assoc list key")
	SSgarbage.should_save_refs = FALSE

/datum/unit_test/find_reference_esoteric/Run()
	var/atom/movable/ref_test/victim = allocate(/atom/movable/ref_test)
	var/atom/movable/ref_holder/testbed = allocate(/atom/movable/ref_holder)
	SSgarbage.should_save_refs = TRUE

	//Let's get a bit esoteric
	victim.self_ref = victim
	var/list/to_find = list(victim)
	testbed.test_list += list(to_find)
	var/list/to_find_assoc = list(victim)
	testbed.test_assoc_list["Nesting"] = to_find_assoc

	var/refcount = refcount(victim)
	TEST_ASSERT_EQUAL(refcount, 6, "Should be: test references: 3 + baseline references: 3 (victim var,loc,allocated list)")
	victim.DoSearchVar(victim, "Third Run Self")
	victim.DoSearchVar(testbed, "Third Run Testbed")

	TEST_ASSERT(LAZYACCESS(victim.found_refs, "self_ref"), "The ref-tracking tool failed to find a self reference")
	TEST_ASSERT(LAZYACCESS(victim.found_refs, to_find), "The ref-tracking tool failed to find a nested list entry")
	TEST_ASSERT(LAZYACCESS(victim.found_refs, to_find_assoc), "The ref-tracking tool failed to find a nested assoc list entry")
	SSgarbage.should_save_refs = FALSE

/datum/unit_test/find_reference_null_key_entry/Run()
	var/atom/movable/ref_test/victim = allocate(/atom/movable/ref_test)
	var/atom/movable/ref_holder/testbed = allocate(/atom/movable/ref_holder)
	SSgarbage.should_save_refs = TRUE

	//Calm before the storm
	testbed.test_assoc_list = list(null = victim)
	var/refcount = refcount(victim)
	TEST_ASSERT_EQUAL(refcount, 4, "Should be: test references: 1 + baseline references: 3 (victim var,loc,allocated list)")
	victim.DoSearchVar(testbed, "Fourth Run")

	TEST_ASSERT(LAZYACCESS(victim.found_refs, testbed.test_assoc_list), "The ref-tracking tool failed to find a null key'd assoc list entry")

/datum/unit_test/find_reference_assoc_investigation/Run()
	var/atom/movable/ref_test/victim = allocate(/atom/movable/ref_test)
	var/atom/movable/ref_holder/testbed = allocate(/atom/movable/ref_holder)
	SSgarbage.should_save_refs = TRUE

	//Let's do some more complex assoc list investigation
	var/list/to_find_in_key = list(victim)
	testbed.test_assoc_list[to_find_in_key] = list("memes")
	var/list/to_find_null_assoc_nested = list(victim)
	testbed.test_assoc_list[null] = to_find_null_assoc_nested

	var/refcount = refcount(victim)
	TEST_ASSERT_EQUAL(refcount, 5, "Should be: test references: 2 + baseline references: 3 (victim var,loc,allocated list)")
	victim.DoSearchVar(testbed, "Fifth Run")

	TEST_ASSERT(LAZYACCESS(victim.found_refs, to_find_in_key), "The ref-tracking tool failed to find a nested assoc list key")
	TEST_ASSERT(LAZYACCESS(victim.found_refs, to_find_null_assoc_nested), "The ref-tracking tool failed to find a null key'd nested assoc list entry")
	SSgarbage.should_save_refs = FALSE

/datum/unit_test/find_reference_static_investigation/Run()
	var/atom/movable/ref_test/victim = allocate(/atom/movable/ref_test)
	var/atom/movable/ref_holder/testbed = allocate(/atom/movable/ref_holder)
	pass(testbed)
	SSgarbage.should_save_refs = TRUE

	//Lets check static vars now, since those can be a real headache
	testbed.static_test = victim

	//Yes we do actually need to do this. The searcher refuses to read weird lists
	//And global.vars is a really weird list
	var/global_vars = list()
	for(var/key in global.vars)
		global_vars[key] = global.vars[key]

	var/refcount = refcount(victim)
	TEST_ASSERT_EQUAL(refcount, 5, "Should be: test references: 2 + baseline references: 3 (victim var,loc,allocated list)")
	victim.DoSearchVar(global_vars, "Sixth Run")

	TEST_ASSERT(LAZYACCESS(victim.found_refs, global_vars), "The ref-tracking tool failed to find a natively global variable")
	SSgarbage.should_save_refs = FALSE
