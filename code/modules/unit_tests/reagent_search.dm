/// Test that the reagent returned by get_chem_id(name) is the one actually being searched for
/datum/unit_test/reagent_search

/datum/unit_test/reagent_search/Run()

	for (var/datum/reagent/reagent as anything in subtypesof(/datum/reagent))
		var/name = initial(reagent.name)
		if (!name)
			continue

		var/datum/reagent/found_reagent = get_chem_id(name)
		var/found_name = initial(found_reagent.name)

		if (!found_name)
			TEST_FAIL("Searching for [reagent] ([name]) returned [found_reagent] (no name) instead")


		if (found_reagent != reagent)
			TEST_FAIL("Searching for [reagent] ([name]) returned [found_reagent] ([found_name]) instead")
