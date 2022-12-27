/// Tests that DCS' GetIdFromArguments works as expected with standard and odd cases
/datum/unit_test/dcs_get_id_from_arguments

/datum/unit_test/dcs_get_id_from_arguments/Run()
	assert_equal(list(1), list(1))
	assert_equal(list(1, 2), list(1, 2))
	assert_equal(list(src), list(src))

	assert_equal(
		list(a = "x", b = "y", c = "z"),
		list(b = "y", a = "x", c = "z"),
		list(c = "z", a = "x", b = "y"),
	)

	TEST_ASSERT_NOTEQUAL(get_id_from_arguments(list(1, 2)), get_id_from_arguments(list(2, 1)), "Swapped arguments should not return the same id")
	TEST_ASSERT_NOTEQUAL(get_id_from_arguments(list(1, a = "x")), get_id_from_arguments(list(1)), "Named arguments were ignored when creating ids")
	TEST_ASSERT_NOTEQUAL(get_id_from_arguments(list(1, a = "x")), get_id_from_arguments(list(a = "x")), "Unnamed arguments were ignored when creating ids")
	TEST_ASSERT_NOTEQUAL(get_id_from_arguments(list(src)), get_id_from_arguments(list(world)), "References to different datums should not return the same id")

	TEST_ASSERT_NOTEQUAL(get_id_from_arguments(list()), SSdcs.GetIdFromArguments(list(/datum/element/dcs_get_id_from_arguments_mock_element2)), "Different elements should not match the same id")

/datum/unit_test/dcs_get_id_from_arguments/proc/assert_equal(reference, ...)
	var/result = get_id_from_arguments(reference)

	// Start at 1 so the 2nd argument is 2
	var/index = 1

	for (var/other_case in args)
		index += 1

		var/other_result = get_id_from_arguments(other_case)

		if (other_result == result)
			continue

		TEST_FAIL("Case #[index] produces a different GetIdFromArguments result from the first. [other_result] != [result]")

/datum/unit_test/dcs_get_id_from_arguments/proc/get_id_from_arguments(list/arguments)
	return SSdcs.GetIdFromArguments(list(/datum/element/dcs_get_id_from_arguments_mock_element) + arguments)

// Necessary because GetIdFromArguments uses argument_hash_start_idx from an element type
/datum/element/dcs_get_id_from_arguments_mock_element
	argument_hash_start_idx = 2

/datum/element/dcs_get_id_from_arguments_mock_element2
	argument_hash_start_idx = 2
