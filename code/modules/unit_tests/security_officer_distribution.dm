#define SECURITY_OFFICER_DEPARTMENTS list("a", "b", "c", "d")
#define SECURITY_OFFICER_DEPARTMENTS_TO_NAMES (list( \
	"a" = SEC_DEPT_ENGINEERING, \
	"b" = SEC_DEPT_MEDICAL, \
	"c" = SEC_DEPT_SCIENCE, \
	"d" = SEC_DEPT_SUPPLY, \
))

/// Test that security officers with specific distributions get their departments.
/datum/unit_test/security_officer_roundstart_distribution

/datum/unit_test/security_officer_roundstart_distribution/proc/test(
	list/preferences,
	list/expected,
)
	var/list/outcome = get_officer_departments(preferences, SECURITY_OFFICER_DEPARTMENTS)
	var/failure_message = "Tested with [json_encode(preferences)] and expected [json_encode(expected)], got [json_encode(outcome)]"

	if (outcome.len == expected.len)
		for (var/index in 1 to outcome.len)
			if (outcome[index] != expected[index])
				Fail(failure_message)
				return
	else
		Fail(failure_message)

/datum/unit_test/security_officer_roundstart_distribution/Run()
	test_distributions()
	test_with_mock_players()

/datum/unit_test/security_officer_roundstart_distribution/proc/test_distributions()
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

/datum/unit_test/security_officer_roundstart_distribution/proc/test_with_mock_players()
	var/mob/dead/new_player/officer_a = create_officer("a")
	var/mob/dead/new_player/officer_b = create_officer("b")
	var/mob/dead/new_player/officer_c = create_officer("c")
	var/mob/dead/new_player/officer_d = create_officer("d")

	var/list/outcome = SSticker.decide_security_officer_departments(
		list(officer_a, officer_b, officer_c, officer_d),
		SECURITY_OFFICER_DEPARTMENTS,
	)

	TEST_ASSERT_EQUAL(outcome[REF(officer_a.new_character)], SECURITY_OFFICER_DEPARTMENTS_TO_NAMES["a"], "Officer A's department outcome was incorrect.")
	TEST_ASSERT_EQUAL(outcome[REF(officer_b.new_character)], SECURITY_OFFICER_DEPARTMENTS_TO_NAMES["b"], "Officer B's department outcome was incorrect.")
	TEST_ASSERT_EQUAL(outcome[REF(officer_c.new_character)], SECURITY_OFFICER_DEPARTMENTS_TO_NAMES["b"], "Officer C's department outcome was incorrect.")
	TEST_ASSERT_EQUAL(outcome[REF(officer_d.new_character)], SECURITY_OFFICER_DEPARTMENTS_TO_NAMES["a"], "Officer D's department outcome was incorrect.")

/datum/unit_test/security_officer_roundstart_distribution/proc/create_officer(preference)
	var/mob/dead/new_player/new_player = allocate(/mob/dead/new_player)
	var/datum/client_interface/mock_client = new

	mock_client.prefs = new
	var/write_success = mock_client.prefs.write_preference(
		GLOB.preference_entries[/datum/preference/choiced/security_department],
		SECURITY_OFFICER_DEPARTMENTS_TO_NAMES[preference],
	)

	TEST_ASSERT(write_success, "Couldn't write department [SECURITY_OFFICER_DEPARTMENTS_TO_NAMES[preference]]")

	var/mob/living/carbon/human/new_character = allocate(/mob/living/carbon/human)
	new_character.mind_initialize()
	new_character.mind.set_assigned_role(SSjob.GetJobType(/datum/job/security_officer))

	new_player.new_character = new_character
	new_player.mock_client = mock_client
	return new_player

/// Test that latejoin security officers are put into the correct department
/datum/unit_test/security_officer_latejoin_distribution

/datum/unit_test/security_officer_latejoin_distribution/proc/test(
	preference,
	list/preferences_of_others,
	expected,
)
	var/list/distribution = list()

	for (var/officer_preference in preferences_of_others)
		var/mob/officer = allocate(/mob/living/carbon/human)
		distribution[officer] = officer_preference

	var/result = get_new_officer_distribution_from_late_join(
		preference,
		SECURITY_OFFICER_DEPARTMENTS,
		distribution,
	)

	var/failure_message = "Latejoin distribution was incorrect (preference = [preference], preferences_of_others = [json_encode(preferences_of_others)])."

	TEST_ASSERT_EQUAL(result, expected, failure_message)

/datum/unit_test/security_officer_latejoin_distribution/Run()
	test("a", list(), "a")
	test("b", list(), "b")
	test("a", list("b"), "b")
	test("a", list("a", "a"), "b")
	test("a", list("a", "a", "b"), "b")
	test("a", list("a", "a", "b", "b"), "c")
	test("a", list("a", "a", "b", "b", "c", "c", "d", "d"), "a")

#undef SECURITY_OFFICER_DEPARTMENTS
