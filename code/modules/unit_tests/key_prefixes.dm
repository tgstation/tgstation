/// A unit test to ensure radio and language prefix keys don't overlap
/datum/unit_test/key_prefixes

/datum/unit_test/key_prefixes/Run()
	// Languages first
	// Assoc list of key:lang type
	var/list/language_keys = list()
	for(var/datum/language/language_type as anything in subtypesof(/datum/language))
		if(initial(language_type.key) in language_keys)
			TEST_FAIL("[language_type] language has the same prefix key ([initial(language_type.key)]) as [language_keys[initial(language_type.key)]]")
		language_keys[initial(language_type.key)] = language_type

	// Now radioes

	// Assoc list of key:name (or type in the cases of saymodes)
	var/list/radio_keys = list()

	for(var/radio_key in GLOB.department_radio_keys)
		if(radio_key in radio_keys)
			TEST_FAIL("[GLOB.department_radio_keys[radio_key]] radio channel has the same prefix key ([radio_key]) as [GLOB.department_radio_keys[radio_keys.Find(radio_key)]]")
		radio_keys[radio_key] = GLOB.department_radio_keys[radio_key]

	for(var/datum/saymode/say_type as anything in subtypesof(/datum/saymode))
		if(initial(say_type.key) in radio_keys)
			TEST_FAIL("[say_type] saymode has the same prefix key ([initial(say_type.key)]) as [radio_keys[initial(say_type.key)]]")
		radio_keys[initial(say_type.key)] = say_type
