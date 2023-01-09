/// Verifies that every tutorial has properly set variables
/datum/unit_test/tutorial_sanity

/datum/unit_test/tutorial_sanity/Run()
	var/regex/regex_valid_date = regex(@"\d{4}-\d{2}-\d{2}")
	var/list/keys = list()

	for (var/datum/tutorial/tutorial_type as anything in SStutorials.tutorial_managers)
		var/datum/tutorial_manager/tutorial_manager = SStutorials.tutorial_managers[tutorial_type]

		var/grandfather_date = initial(tutorial_type.grandfather_date)
		if (!isnull(grandfather_date))
			TEST_ASSERT(regex_valid_date.Find(grandfather_date), "[tutorial_type] has an invalid grandfather_date ([grandfather_date])")

		var/key = tutorial_manager.get_key()
		TEST_ASSERT(!(key in keys), "[key] shows up twice")
		TEST_ASSERT(length(key) < 64, "[key] is more than 64 characters, it won't fit in the SQL table.")

	TEST_ASSERT_EQUAL(SStutorials.tutorial_managers.len, length(subtypesof(/datum/tutorial)), "Expected tutorial_managers to have one of every tutorial")
