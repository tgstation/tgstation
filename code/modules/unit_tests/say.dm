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

/datum/unit_test/say_signal/Run()
	var/mob/living/dummy = allocate(/mob/living)

	RegisterSignal(dummy, COMSIG_MOB_SAY, PROC_REF(check_say))
	dummy.say("Make sure the say signal gets the arglist say is past, no copies!")

/datum/unit_test/say_signal/proc/check_say(mob/living/source, list/say_args)
	SIGNAL_HANDLER

	TEST_ASSERT_EQUAL(REF(say_args), source.last_say_args_ref, "Say signal didn't get the argslist of say as a reference. \
		This is required for the signal to function in most places - do not create a new instance of a list when passing it in to the signal.")

// For the above test to track the last use of say's message args.
/mob/living
	var/last_say_args_ref
