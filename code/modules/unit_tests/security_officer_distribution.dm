/// Test that security officers with specific distributions get their departments.
/datum/unit_test/security_officer_distribution
	var/list/departments = list("a", "b", "c", "d")

TEST_FOCUS(/datum/unit_test/security_officer_distribution)

/datum/unit_test/security_officer_distribution/proc/test(
	list/preferences,
	list/expected,
)
	var/list/outcome = get_officer_departments(preferences, departments)
	var/failure_message = "Tested with [json_encode(preferences)] and expected [json_encode(expected)], got [json_encode(outcome)]"

	if (outcome.len == expected.len)
		for (var/index in 1 to outcome.len)
			if (outcome[index] != expected[index])
				Fail(failure_message)
				return
	else
		Fail(failure_message)

/datum/unit_test/security_officer_distribution/Run()
	test_distributions()
	test_with_mock_players()

/datum/unit_test/security_officer_distribution/proc/test_distributions()
	test(list("a"), list("a"))
	test(list("a", "b"), list("a", "a"))
	test(list("a", "b", "c"), list("a", "a", "a"))
	test(list("a", "a", "b"), list("a", "a", "a"))
	test(list("a", "a", "b", "b"), list("a", "a", "b", "b"))
	test(list("a", "a", "a", "b"), list("a", "a", "b", "b"))
	test(list("a", "b", "c", "d"), list("a", "b", "b", "a"))
	test(list(SEC_DEPT_NONE), list("d"))
	test(list("a", SEC_DEPT_NONE), list("a", "a"))
	test(list(SEC_DEPT_NONE, SEC_DEPT_NONE, SEC_DEPT_NONE, SEC_DEPT_NONE), list("d", "d", "c", "c"))

/datum/unit_test/security_officer_distribution/proc/test_with_mock_players()
	var/officer_a = create_officer("a")
	var/officer_b = create_officer("b")
	var/officer_c = create_officer("c")
	var/officer_d = create_officer("d")

	var/list/outcome = SSticker.decide_security_officer_departments(
		list(officer_a, officer_b, officer_c, officer_d),
		departments,
	)

	TEST_ASSERT_EQUAL(outcome[officer_a], "a")
	TEST_ASSERT_EQUAL(outcome[officer_b], "b")
	TEST_ASSERT_EQUAL(outcome[officer_c], "b")
	TEST_ASSERT_EQUAL(outcome[officer_d], "a")

/datum/unit_test/security_officer_distribution/proc/create_officer(preference)
	var/mob/dead/new_player/new_player = allocate(/mob/dead/new_player)
	var/datum/client_interface/mock_client = allocate(/datum/client_interface)

	mock_client.prefs = new
	mock_client.prefs.prefered_security_department = preference

	var/mob/living/carbon/human/new_character = allocate(/mob/living/carbon/human)
	new_character.mind_initialize()
	new_character.mind.assigned_role = "Security Officer"

	new_player.mock_client = mock_client
	return new_player
