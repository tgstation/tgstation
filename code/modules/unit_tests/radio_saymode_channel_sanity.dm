/// Makes sure we are not doubled up on any radio/saymode channel keys, and that every radio channel has an entry in GLOB.department_radio_keys
/datum/unit_test/radio_saymode_channel_sanity
	/// Assoc list of channels to keys (to allow duplicates we have to remap these from (key=>channel) to (channel=>key))
	var/list/say_keys_by_channel
	/// Assoc list of keys to channels (used to check for the dupes)
	var/list/checked_channel_keys

/datum/unit_test/radio_saymode_channel_sanity/Run()
	say_keys_by_channel = list()

	// We are getting our radio keys from GLOB.department_radio_keys mostly
	for(var/radio_key in GLOB.department_radio_keys)
		say_keys_by_channel.Add(list(
			GLOB.department_radio_keys[radio_key] = radio_key
		))

	// Check the radio obj channel keys for any missing entries in GLOB.department_radio_keys
	for(var/obj/item/radio as anything in typesof(/obj/item/radio))
		radio = new radio.type // initial doesn't work on lists, temporarily instantiate one
		check_radio_channels(radio)
		qdel(radio)

	// Add saymode tokens (like changeling :g, xeno :x, etc)
	for(var/datum/saymode/say_mode as anything in typesof(/datum/saymode))
		if(isnull(initial(say_mode.key)))
			continue
		say_keys_by_channel.Add(list(say_mode.mode = say_mode.key))

	// Now check for duplicate keys
	checked_channel_keys = list()
	for(var/channel in say_keys_by_channel)
		var/key = say_keys_by_channel[channel]
		check_for_duplicate_keys(channel, key)
		checked_channel_keys[key] = channel

/// Check if each radio channel actually appears in GLOB.department_radio_keys, which they should
/datum/unit_test/radio_saymode_channel_sanity/proc/check_radio_channels(obj/item/radio/radio_to_check)
	for(var/channel in radio_to_check.channels)
		var/channel_key = GLOB.department_radio_keys[channel]
		if(isnull(channel_key))
			say_keys_by_channel.Add(list(channel = channel_key))
			TEST_FAIL("Radio channel [channel] is missing an entry in GLOB.department_radio_keys! Please add it.")
	return TRUE

/// Check if we have the same keys appearing twice for any given chat channels
/datum/unit_test/radio_saymode_channel_sanity/proc/check_for_duplicate_keys(channel, key)
	if(checked_channel_keys[key])
		TEST_FAIL("Duplicate radio channel token found for [channel]! \":[key]\" is also being used by [checked_channel_keys[key]]!")
