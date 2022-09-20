/// Test to verify message mods are parsed correctly
/datum/unit_test/get_message_mods
	var/mob/host_mob

/datum/unit_test/get_message_mods/Run()
	host_mob = allocate(/mob/living/carbon/human)

	test("Hello", "Hello", list())
	test(";HELP", "HELP", list(MODE_HEADSET = TRUE))
	test(";%Never gonna give you up", "Never gonna give you up", list(MODE_HEADSET = TRUE, MODE_SING = TRUE))
	test(".s Gun plz", "Gun plz", list(RADIO_KEY = RADIO_KEY_SECURITY, RADIO_EXTENSION = RADIO_CHANNEL_SECURITY))
	test("...What", "...What", list())

/datum/unit_test/get_message_mods/proc/test(message, expected_message, list/expected_mods)
	var/list/mods = list()
	TEST_ASSERT_EQUAL(host_mob.get_message_mods(message, mods), expected_message, "Chopped message was not what we expected. Message: [message]")

	for (var/mod_key in mods)
		TEST_ASSERT_EQUAL(mods[mod_key], expected_mods[mod_key], "The value for [mod_key] was not what we expected. Message: [message]")
		expected_mods -= mod_key

	TEST_ASSERT(!expected_mods.len,
		"Some message mods were expected, but were not returned by get_message_mods: [json_encode(expected_mods)]. Message: [message]")

/datum/unit_test/translate_language
	var/mob/host_mob

/datum/unit_test/translate_language/Run()
	host_mob = allocate(/mob/living/carbon/human)
	var/surfer_quote = "surfing in the USA"

	host_mob.grant_language(/datum/language/beachbum, spoken=TRUE, understood=FALSE) // can speak but can't understand
	host_mob.add_blocked_language(subtypesof(/datum/language) - /datum/language/beachbum, LANGUAGE_STONER)
	TEST_ASSERT_NOTEQUAL(surfer_quote, host_mob.translate_language(host_mob, /datum/language/beachbum, surfer_quote), "Language test failed. Mob was supposed to understand: [surfer_quote]")

	host_mob.grant_language(/datum/language/beachbum, spoken=TRUE, understood=TRUE) // can now understand
	TEST_ASSERT_EQUAL(surfer_quote, host_mob.translate_language(host_mob, /datum/language/beachbum, surfer_quote), "Language test failed. Mob was supposed NOT to understand: [surfer_quote]")
