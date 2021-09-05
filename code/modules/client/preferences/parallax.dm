/// Determines parallax, "fancy space"
/datum/preference/choiced/parallax
	savefile_key = "parallax"
	savefile_identifier = PREFERENCE_PLAYER
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES

/datum/preference/choiced/parallax/init_possible_values()
	return list(
		PARALLAX_INSANE,
		PARALLAX_HIGH,
		PARALLAX_MED,
		PARALLAX_LOW,
		PARALLAX_DISABLE,
	)

/datum/preference/choiced/parallax/create_default_value()
	return PARALLAX_HIGH

/datum/preference/choiced/parallax/apply_to_client(client/client, value)
	client.mob?.hud_used?.update_parallax_pref(client?.mob)

/datum/preference/choiced/parallax/deserialize(input, datum/preferences/preferences)
	// Old preferences were numbers, which causes annoyances when
	// sending over as lists that isn't worth dealing with.
	if (isnum(input))
		switch (input)
			if (-1)
				input = PARALLAX_INSANE
			if (0)
				input = PARALLAX_HIGH
			if (1)
				input = PARALLAX_MED
			if (2)
				input = PARALLAX_LOW
			if (3)
				input = PARALLAX_DISABLE

	return ..(input)
