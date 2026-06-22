/// Test that `TGUI_CREATE_MESSAGE` is correctly implemented
/datum/unit_test/tgui_create_message

/datum/unit_test/tgui_create_message/Run()
	var/type = "something/here"
	var/list/payload = list(
		"name" = "Terry McTider",
		"heads_caved" = 100,
		"accomplishments" = list(
			"nothing",
			"literally nothing",
			list(
				"something" = "just kidding",
			),
		),
	)

	var/message = TGUI_CREATE_MESSAGE(type, payload)

	// Ensure consistent output to compare by performing a round-trip.
	var/output = json_encode(json_decode(url_decode(message)))

	var/expected = json_encode(list(
		"type" = type,
		"payload" = payload,
	))

	TEST_ASSERT_EQUAL(expected, output, "TGUI_CREATE_MESSAGE didn't round trip properly")

/// Test that TGUI_PANEL_FOCUS_MESSAGE matches what TGUI_CREATE_MESSAGE would produce
/datum/unit_test/tgui_panel_focus_message

/datum/unit_test/tgui_panel_focus_message/Run()
	var/expected = TGUI_CREATE_MESSAGE("verbs/focus", null)
	TEST_ASSERT_EQUAL(expected, TGUI_PANEL_FOCUS_MESSAGE, "TGUI_PANEL_FOCUS_MESSAGE doesn't match TGUI_CREATE_MESSAGE(\"verbs/focus\", null)")
