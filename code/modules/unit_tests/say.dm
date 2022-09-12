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

/// Test to verify COMSIG_MOB_SAY is sent the exact same list as the message args, as they're operated on
/datum/unit_test/say_signal
	var/test_message = "Make sure the say signal gets the arglist say is past, no copies!"
	var/arg_list_ref
	var/list/arglist_full

/datum/unit_test/say_signal/Run()
	var/mob/living/say_dummy/dummy = allocate(/mob/living/say_dummy)
	dummy.linked_test = src

	RegisterSignal(dummy, COMSIG_MOB_SAY, .proc/check_say)
	dummy.say(test_message)

/datum/unit_test/say_signal/proc/check_say(datum/source, list/say_args)
	SIGNAL_HANDLER

	TEST_ASSERT_EQUAL(say_args[SPEECH_MESSAGE], test_message, "Say signal's first arg of the arglist wasn't the expected message.")

	TEST_ASSERT_EQUAL(REF(say_args), arg_list_ref, "Say signal didn't get the argslist of say as a reference. \
		This is required for the signal to function in most places - do not create a new instance of a list when passing it in to the signal.")

/mob/living/say_dummy
	var/datum/unit_test/say_signal/linked_test

/mob/living/say_dummy/Destroy()
	linked_test = null
	return ..()

/mob/living/say_dummy/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced, filterproof)
	linked_test.arg_list_ref = REF(args)
	return ..()
