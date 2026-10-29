#define SECURITY_OFFICER_DEPARTMENTS list("a", "b", "c", "d")

/// Test that security officers are spread across departments
/datum/unit_test/security_officer_distribution

/datum/unit_test/security_officer_distribution/proc/test(
	preference,
	list/preferences_of_others,
	expected,
)
	var/list/distribution = list()

	for (var/officer_preference in preferences_of_others)
		var/mob/officer = allocate(/mob/living/carbon/human/consistent)
		distribution[officer] = officer_preference

	var/result = get_officer_department(
		preference,
		SECURITY_OFFICER_DEPARTMENTS,
		distribution,
	)

	var/failure_message = "Officer distribution was incorrect (preference = [preference], preferences_of_others = [json_encode(preferences_of_others)])."

	TEST_ASSERT_EQUAL(result, expected, failure_message)

/datum/unit_test/security_officer_distribution/Run()
	test("a", list(), "a")
	test("b", list(), "b")
	test(SEC_DEPT_NONE, list(), "a")
	test("a", list("b"), "a")
	test("a", list("a"), "b")
	test(SEC_DEPT_NONE, list("a", "b"), "c")
	test("a", list("a", "b", "c"), "d")
	test("b", list("a", "b", "c", "d"), "b")
	test("a", list("a", "a", "b", "c", "d"), "b")

#undef SECURITY_OFFICER_DEPARTMENTS
