/**
 * list arguments for bespoke elements are treated just like any other datum: as a text ref in the ID.
 * Using un-cached lists in AddElement() and RemoveElement() calls will just create new elements over
 * and over. That's what this unit test is for. It's not a catch-all, but it does a decent job at it.
 */
/datum/unit_test/dcs_check_list_arguments
	/**
	 * This unit test requires every (tangible) atom to have been created at least once
	 * so its search is more accurate. That's why it's run after create_and_destroy.
	 */
	priority = TEST_AFTER_CREATE_AND_DESTROY

/datum/unit_test/dcs_check_list_arguments/Run()
	for(var/element_type in SSdcs.arguments_that_are_lists_by_element)
		// Keeps tracks of the lists that shouldn't be compared with again.
		var/list/to_ignore = list()
		var/list/superlist = SSdcs.arguments_that_are_lists_by_element[element_type]
		for(var/list/current as anything in superlist)
			to_ignore[current] = TRUE
			var/list/bad_lists
			for(var/list/compare as anything in superlist)
				if(to_ignore[compare])
					continue
				if(deep_compare_list(current, compare))
					if(!bad_lists)
						bad_lists = list(list(current))
					bad_lists += list(compare)
					to_ignore[compare] = TRUE
			if(bad_lists)
				//Include the original, unsorted list in the report. It should be easier to find by the contributor.
				var/list/unsorted_list = superlist[current]
				TEST_FAIL("found [length(bad_lists)] identical lists used as argument for element [element_type]. List: [json_encode(unsorted_list)].\n\
					Make sure it's a cached list, or use one of the string_list proc. Also, use the ELEMENT_DONT_SORT_LIST_ARGS flag if the key position of your lists matters.")
