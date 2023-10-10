/// Test to verify message mods are parsed correctly
/datum/unit_test/get_message_mods
	var/mob/host_mob

/datum/unit_test/get_message_mods/Run()
	host_mob = allocate(/mob/living/carbon/human/consistent)

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

/// This unit test translates a string from one language to another depending on if the person can understand the language
/datum/unit_test/translate_language
	var/mob/host_mob

/datum/unit_test/translate_language/Run()
	host_mob = allocate(/mob/living/carbon/human/consistent)
	var/surfer_quote = "surfing in the USA"

	host_mob.grant_language(/datum/language/beachbum, SPOKEN_LANGUAGE) // can speak but can't understand
	host_mob.add_blocked_language(subtypesof(/datum/language) - /datum/language/beachbum, LANGUAGE_STONER)
	TEST_ASSERT_NOTEQUAL(surfer_quote, host_mob.translate_language(host_mob, /datum/language/beachbum, surfer_quote), "Language test failed. Mob was supposed to understand: [surfer_quote]")

	host_mob.grant_language(/datum/language/beachbum, ALL) // can now understand
	TEST_ASSERT_EQUAL(surfer_quote, host_mob.translate_language(host_mob, /datum/language/beachbum, surfer_quote), "Language test failed. Mob was supposed NOT to understand: [surfer_quote]")

/// This runs some simple speech tests on a speaker and listener and determines if a person can hear whispering or speaking as they are moved a distance away
/datum/unit_test/speech
	var/list/handle_speech_result = null
	var/list/handle_hearing_result = null
	var/mob/living/carbon/human/speaker
	var/mob/living/carbon/human/listener
	var/obj/item/radio/speaker_radio
	var/obj/item/radio/listener_radio

/datum/unit_test/speech/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	TEST_ASSERT(speech_args[SPEECH_MESSAGE], "Handle speech signal does not have a message arg")
	TEST_ASSERT(speech_args[SPEECH_SPANS], "Handle speech signal does not have spans arg")
	TEST_ASSERT(speech_args[SPEECH_LANGUAGE], "Handle speech signal does not have a language arg")
	TEST_ASSERT(speech_args[SPEECH_RANGE], "Handle speech signal does not have a range arg")

	// saving hearing_args directly via handle_speech_result = speech_args won't work since the arg list
	// is a temporary variable that gets garbage collected after it's done being used by procs
	// therefore we need to create a new list and transfer the args
	handle_speech_result = list()
	handle_speech_result += speech_args

/datum/unit_test/speech/proc/handle_hearing(datum/source, list/hearing_args)
	SIGNAL_HANDLER

	// So it turns out that the `message` arg for COMSIG_MOVABLE_HEAR is super redundant and should probably
	// be gutted out of both the Hear() proc and signal since it's never used
	//TEST_ASSERT(hearing_args[HEARING_MESSAGE], "Handle hearing signal does not have a message arg")
	TEST_ASSERT(hearing_args[HEARING_SPEAKER], "Handle hearing signal does not have a speaker arg")
	TEST_ASSERT(hearing_args[HEARING_LANGUAGE], "Handle hearing signal does not have a language arg")
	TEST_ASSERT(hearing_args[HEARING_RAW_MESSAGE], "Handle hearing signal does not have a raw message arg")
	// TODO radio unit tests
	//TEST_ASSERT(hearing_args[HEARING_RADIO_FREQ], "Handle hearing signal does not have a radio freq arg")
	TEST_ASSERT(hearing_args[HEARING_SPANS], "Handle hearing signal does not have a spans arg")
	TEST_ASSERT(hearing_args[HEARING_MESSAGE_MODE], "Handle hearing signal does not have a message mode arg")

	// saving hearing_args directly via handle_hearing_result = hearing_args won't work since the arg list
	// is a temporary variable that gets garbage collected after it's done being used by procs
	// therefore we need to create a new list and transfer the args
	handle_hearing_result = list()
	handle_hearing_result += hearing_args

/datum/unit_test/speech/Run()
	speaker = allocate(/mob/living/carbon/human/consistent)
	// Name changes to make understanding breakpoints easier
	speaker.name = "SPEAKER"
	listener = allocate(/mob/living/carbon/human/consistent)
	listener.name = "LISTENER"
	speaker_radio = allocate(/obj/item/radio)
	speaker_radio.name = "SPEAKER RADIO"
	listener_radio = allocate(/obj/item/radio)
	listener_radio.name = "LISTENER RADIO"
	// Hear() requires a client otherwise it will early return
	var/datum/client_interface/mock_client = new()
	listener.mock_client = mock_client

	RegisterSignal(speaker, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	RegisterSignal(listener, COMSIG_MOVABLE_HEAR, PROC_REF(handle_hearing))

	// speaking and whispering should be hearable
	conversation(distance = 1)
	// speaking should be hearable but not whispering
	conversation(distance = 5)
	// neither speaking or whispering should be hearable
	conversation(distance = 10)

	// Radio test
	radio_test()

	// Language test
	speaker.grant_language(/datum/language/beachbum)
	speaker.set_active_language(/datum/language/beachbum)
	listener.add_blocked_language(/datum/language/beachbum)
	// speaking and whispering should be hearable
	conversation(distance = 1)
	// speaking should be hearable but not whispering
	conversation(distance = 5)
	// neither speaking or whispering should be hearable
	conversation(distance = 10)

#define NORMAL_HEARING_RANGE 7
#define WHISPER_HEARING_RANGE 1

/datum/unit_test/speech/proc/conversation(distance = 0)
	speaker.forceMove(run_loc_floor_bottom_left)
	listener.forceMove(locate((run_loc_floor_bottom_left.x + distance), run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))

	var/pangram_quote = "The quick brown fox jumps over the lazy dog"

	// speaking
	speaker.say(pangram_quote)
	TEST_ASSERT(handle_speech_result, "Handle speech signal was not fired")
	TEST_ASSERT_EQUAL(islist(handle_hearing_result), distance <= NORMAL_HEARING_RANGE, "Handle hearing signal was not fired")

	if(handle_hearing_result)
		if(listener.has_language(handle_speech_result[SPEECH_LANGUAGE]))
			TEST_ASSERT_EQUAL(pangram_quote, handle_hearing_result[HEARING_RAW_MESSAGE], "Language test failed. Mob was supposed to understand: [pangram_quote] using language [handle_speech_result[SPEECH_LANGUAGE]]")
		else
			TEST_ASSERT_NOTEQUAL(pangram_quote, handle_hearing_result[HEARING_RAW_MESSAGE], "Language test failed. Mob was NOT supposed to understand: [pangram_quote] using language [handle_speech_result[SPEECH_LANGUAGE]]")

	handle_speech_result = null
	handle_hearing_result = null

	// whispering
	speaker.whisper(pangram_quote)
	TEST_ASSERT(handle_speech_result, "Handle speech signal was not fired")
	TEST_ASSERT_EQUAL(islist(handle_hearing_result), distance <= WHISPER_HEARING_RANGE, "Handle hearing signal was not fired")

	handle_speech_result = null
	handle_hearing_result = null

/datum/unit_test/speech/proc/radio_test()
	speaker.forceMove(run_loc_floor_bottom_left)
	listener.forceMove(locate((run_loc_floor_bottom_left.x + 10), run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))

	speaker_radio.forceMove(run_loc_floor_bottom_left)
	speaker_radio.set_broadcasting(TRUE)
	listener_radio.forceMove(locate((run_loc_floor_bottom_left.x + 10), run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	// Normally speaking, if there isn't a functional telecomms array on the same z-level, then handheld radios
	// have a short delay before sending the message. We use the centcom frequency to get around this.
	speaker_radio.set_frequency(FREQ_CENTCOM)
	speaker_radio.independent = TRUE
	listener_radio.set_frequency(FREQ_CENTCOM)
	listener_radio.independent = TRUE

	var/pangram_quote = "The quick brown fox jumps over the lazy dog"

	speaker.say(pangram_quote)
	TEST_ASSERT(handle_speech_result, "Handle speech signal was not fired (radio test)")
	TEST_ASSERT(islist(handle_hearing_result), "Listener failed to hear radio message (radio test)")
	TEST_ASSERT_EQUAL(speaker_radio.get_frequency(), listener_radio.get_frequency(), "Radio frequencies were not equal (radio test)")

	handle_speech_result = null
	handle_hearing_result = null

	speaker_radio.set_frequency(FREQ_CTF_RED)
	speaker.say(pangram_quote)
	TEST_ASSERT(handle_speech_result, "Handle speech signal was not fired (radio test)")
	TEST_ASSERT_NULL(handle_hearing_result, "Listener erroneously heard radio message (radio test)")
	TEST_ASSERT_NOTEQUAL(speaker_radio.get_frequency(), listener_radio.get_frequency(), "Radio frequencies were erroneously equal (radio test)")

	handle_speech_result = null
	handle_hearing_result = null
	speaker_radio.set_broadcasting(FALSE)

#undef NORMAL_HEARING_RANGE
#undef WHISPER_HEARING_RANGE
