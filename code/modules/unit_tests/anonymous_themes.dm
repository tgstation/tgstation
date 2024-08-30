/// Ensure that anonymous themes works without changing your preferences
/datum/unit_test/anonymous_themes

/datum/unit_test/anonymous_themes/Run()
	GLOB.current_anonymous_theme = new /datum/anonymous_theme

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)

	var/datum/client_interface/client = new
	human.mock_client = client
	client.prefs = new(client)

	client.prefs.write_preference(GLOB.preference_entries[/datum/preference/name/real_name], "Prefs Biddle")

	human.apply_prefs_job(client, SSjob.GetJobType(/datum/job/assistant))

	TEST_ASSERT_NOTEQUAL(human.real_name, "Prefs Biddle", "apply_prefs_job didn't randomize human name with an anonymous theme")
	TEST_ASSERT_EQUAL(client.prefs.read_preference(/datum/preference/name/real_name), "Prefs Biddle", "Anonymous theme overrode original prefs")

/datum/unit_test/anonymous_themes/Destroy()
	QDEL_NULL(GLOB.current_anonymous_theme)
	return ..()
