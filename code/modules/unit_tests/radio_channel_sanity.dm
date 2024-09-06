/// Makes sure we are not doubled up on any radio channel keys
/datum/unit_test/radio_channel_sanity

/datum/unit_test/radio_channel_sanity/Run()
	var/list/checked_channel_keys = list()
	for(var/radio_key in GLOB.department_radio_keys)
		var/radio_channel = GLOB.department_radio_keys[radio_key]
		if(checked_channel_keys[radio_key])
			TEST_FAIL("Duplicate radio channel token found for [radio_channel]! \":[radio_key]\" is also being used by [checked_channel_keys[channel_token]]!")
		checked_channel_keys[channel_token] = radio_channel
