/// ensures all json_entries have a unique category identifier
/datum/unit_test/json_logging_category_unique

/datum/unit_test/json_logging_category_unique/Run()
	var/list/used = list()
	for(var/datum/log_entry/entry as anything in subtypesof(/datum/log_entry))
		var/entry_category = UNLINT(initial(entry.category))
		if(!entry_category)
			TEST_FAIL("[entry] has no category")
			continue
		if(entry_category in used)
			TEST_FAIL("[entry] has a duplicate category")
			continue
		used += entry_category
