/// Test that all reagent names are different in order to prevent #65231
/datum/unit_test/reagent_names

/datum/unit_test/reagent_names/Run()
	var/used_names = list()

	for (var/datum/reagent/reagent as anything in subtypesof(/datum/reagent))
		var/name = initial(reagent.name)
		if (!name)
			continue

		if (name in used_names)
			TEST_FAIL("[used_names[name]] shares a name with [reagent] ([name])")
		else
			used_names[name] = reagent
