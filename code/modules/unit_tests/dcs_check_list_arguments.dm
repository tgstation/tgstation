/**
 * list arguments for bespoke elements are treated just like any other datum: as a text ref in the ID.
 * Using un-cached lists in AddElement() and RemoveElement() calls will just create new elements over
 * and over. That's what this unit test is for. It's not a catch-all, but it does a decent job at it.
 */
/datum/unit_test/dcs_check_list_arguments
	/**
	 * This unit test requires every (tangible) atom to have been created at least once
	 * so its search can be most accurate. That's why it's run after create_and_destroy.
	 */
	priority = TEST_AFTER_CREATE_AND_DESTROY

/datum/unit_test/dcs_check_list_arguments/Run()
	/**
	 * An assoc list of element types and the lists that've been used as arguments to add or remove them,
	 * that will get populated by said lists after they're sorted.
	 */
	var/list/processed_lists_by_element = list()

	//looping through every element type in the list, in turn looping through all the lists within the nested list.
	for(var/datum/element/ele_type as anything in SSdcs.arguments_that_are_lists_by_element)
		if(initial(ele_type.element_flags) & ELEMENT_NO_LIST_UNIT_TEST) // nope
			continue
		var/list/ele_type_superlist = list()
		processed_lists_by_element[ele_type] = ele_type_superlist

		var/list/superlist = SSdcs.arguments_that_are_lists_by_element[ele_type]
		var/dont_sort = initial(ele_type.element_flags) & ELEMENT_DONT_SORT_LIST_ARGS

		for(var/list/list_arg as anything in superlist)
			var/list/sorted = list_arg
			if(!dont_sort)
				sorted = sortTim(list_arg.Copy(), GLOBAL_PROC_REF(cmp_embed_text_asc))

			ele_type_superlist[sorted] = list_arg

	// Now, let's start comparing these lists.
	for(var/ele_type in processed_lists_by_element)
		//after we're done  comparing one list to everything else, we add it to this list
		//as well as any identical list.
		var/list/to_ignore = list()
		var/list/superlist = processed_lists_by_element[ele_type]
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
				//report the original list that wasn't sorted. It should be easier to find.
				var/list/unsorted_list = superlist[current]
				TEST_FAIL("found [length(bad_lists)] identical lists as argument for element [ele_type]. List: [json_encode(unsorted_list)].\n\
				Make sure it's a cached list, or use one of the string_list proc. Also, use the ELEMENT_DONT_SORT_LIST_ARGS flag if the key position of your lists matters.")
