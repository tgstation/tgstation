/datum/preference_middleware/tts_sample

/datum/preference_middleware/tts_sample/pre_set_preference(mob/user, preference, value)
	. = ..()
	if(preference == "tts_seed")
		//show a lil sample
		var/seed = GLOB.tts_names2seeds[value]
		INVOKE_ASYNC(GLOBAL_PROC, /proc/play_tts_directly, user, PREFERENCES_TEST_MESSAGE, seed)
