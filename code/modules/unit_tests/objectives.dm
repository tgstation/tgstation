/datum/unit_test/objectives_category/Run()
	var/datum/traitor_category_handler/category_handler = allocate(/datum/traitor_category_handler)
	var/list/objectives_that_exist = list()
	for(var/datum/traitor_objective_category/category as anything in category_handler.all_categories)
		for(var/value in category.objectives)
			TEST_ASSERT(isnum(category.objectives[value]), "[category.type] does not have a valid format for its objectives as an objective category! ([value] requires a weight to be assigned to it)")
			if(islist(value))
				recursive_check_list(category.type, value, objectives_that_exist)
			else
				objectives_that_exist += value

	for(var/datum/traitor_objective/objective_typepath as anything in subtypesof(/datum/traitor_objective))
		if(initial(objective_typepath.abstract_type) == objective_typepath)
			continue
		if(!(objective_typepath in objectives_that_exist))
			Fail("[objective_typepath] is not in a traitor category and isn't an abstract type! Place it into a [/datum/traitor_objective_category] or remove it from code.")

/datum/unit_test/objectives_category/proc/recursive_check_list(base_type, list/to_check, list/to_add_to)
	for(var/value in to_check)
		TEST_ASSERT(isnum(to_check[value]), "[base_type] does not have a valid format for its objectives as an objective category! ([value] requires a weight to be assigned to it)")
		if(islist(value))
			recursive_check_list(base_type, value, to_add_to)
		else
			to_add_to += value
