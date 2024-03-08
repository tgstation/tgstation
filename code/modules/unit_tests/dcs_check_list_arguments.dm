/**
 * list arguments for bespoke elements are treated as a text ref in the ID, like any other datum.
 * Which means that, unless cached, using lists as arguments will lead to multiple instance of the same element
 * being created over and over.
 *
 * Because of how it works, this unit test checks that these list datum args
 * do not share similar contents (when rearranged in descending alpha-numerical order), to ensure that
 * the least necessary amount of elements is created. So, using static lists may not be enough,
 * for example, in the case of two different critters using the death_drops element to drop ectoplasm on death, since,
 * despite being static lists, the two are different instances assigned to different mob types.
 *
 * Most of the time, you won't encounter two different static lists with similar contents used as element args,
 * meaning using static lists is accepted. However, should that happen, it's advised to replace the instances
 * with various string_x procs: lists, assoc_lists, assoc_nested_lists or numbers_list, depending on the type.
 *
 * In the case of an element where the position of the contents of each datum list argument is important,
 * ELEMENT_DONT_SORT_LIST_ARGS should be added to its flags, to prevent such issues where the contents are similar
 * when sorted, but the element instances are not.
 *
 * In the off-chance the element is not compatible with this unit test (such as for connect_loc et simila),
 * you can also use ELEMENT_NO_LIST_UNIT_TEST so that they won't be processed by this unit test at all.
 */
/datum/unit_test/dcs_check_list_arguments
	/**
	 * This unit test requires every (unless ignored) atom to have been created at least once
	 * for a more accurate search, which is why it's run after create_and_destroy is done running.
	 */
	priority = TEST_AFTER_CREATE_AND_DESTROY

/datum/unit_test/dcs_check_list_arguments/Run()
	var/we_failed = FALSE
	for(var/element_type in SSdcs.arguments_that_are_lists_by_element)
		// Keeps track of the lists that shouldn't be compared with again.
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
				we_failed = TRUE
				//Include the original, unsorted list in the report. It should be easier to find by the contributor.
				var/list/unsorted_list = superlist[current]
				TEST_FAIL("Found [length(bad_lists)] datum list arguments with similar contents for [element_type]. Contents: [json_encode(unsorted_list)].")
	///Let's avoid sending the same instructions over and over, as it's just going to clutter the CI and confuse someone.
	if(we_failed)
		TEST_FAIL("Ensure that each list is static or cached. string_lists() (as well as similar procs) is your friend here.\n\
			Check the documentation from dcs_check_list_arguments.dm for more information!")
