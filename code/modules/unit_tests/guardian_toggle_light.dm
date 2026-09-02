/// The "Toggle Light" action should toggle an actual light that can be turned back off.
/datum/unit_test/guardian_toggle_light

/datum/unit_test/guardian_toggle_light/Run()
	var/mob/living/basic/guardian/ranged/test_guardian = allocate(/mob/living/basic/guardian/ranged)
	TEST_ASSERT_EQUAL(test_guardian.light_on, FALSE, "Guardian should start with their light off.")

	test_guardian.toggle_light()
	TEST_ASSERT_EQUAL(test_guardian.light_on, TRUE, "Toggling the light should turn it on.")

	test_guardian.toggle_light()
	TEST_ASSERT_EQUAL(test_guardian.light_on, FALSE, "Toggling the light again should turn it back off.")
