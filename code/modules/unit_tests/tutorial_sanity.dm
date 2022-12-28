/// Verifies that every tutorial has properly set variables
/datum/unit_test/tutorial_sanity

/datum/unit_test/tutorial_sanity/Run()
	var/regex/regex_valid_date = regex(@"\d{4}-\d{2}-\d{2}")

	for (var/datum/tutorial/tutorial_type as anything in subtypesof(/datum/tutorial))
		var/grandfather_date = initial(tutorial_type.grandfather_date)
		if (!isnull(grandfather_date))
			TEST_ASSERT(regex_valid_date.Find(grandfather_date), "[tutorial_type] has an invalid grandfather_date ([grandfather_date])")
