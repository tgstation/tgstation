/// Middleware for handling randomization preferences
/datum/preference_middleware/random
	action_delegations = list(
		"randomize_character" = PROC_REF(randomize_character),
		"set_random_preference" = PROC_REF(set_random_preference),
	)

/datum/preference_middleware/random/get_character_preferences(mob/user)
	return list(
		"randomization" = preferences.randomise,
	)

/datum/preference_middleware/random/get_constant_data()
	var/list/randomizable = list()

	for (var/preference_type in GLOB.preference_entries)
		var/datum/preference/preference = GLOB.preference_entries[preference_type]
		if (!preference.is_randomizable())
			continue

		randomizable += preference.savefile_key

	return list(
		"randomizable" = randomizable,
	)

/datum/preference_middleware/random/proc/randomize_character()
	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (preferences.should_randomize(preference))
			preferences.write_preference(preference, preference.create_random_value(preferences))

	preferences.character_preview_view.update_body()

	return TRUE

/datum/preference_middleware/random/proc/set_random_preference(list/params, mob/user)
	var/requested_preference_key = params["preference"]
	var/value = params["value"]

	var/datum/preference/requested_preference = GLOB.preference_entries_by_key[requested_preference_key]
	if (isnull(requested_preference))
		return FALSE

	if (!requested_preference.is_randomizable())
		return FALSE

	if (value == RANDOM_ANTAG_ONLY)
		preferences.randomise[requested_preference_key] = RANDOM_ANTAG_ONLY
	else if (value == RANDOM_ENABLED)
		preferences.randomise[requested_preference_key] = RANDOM_ENABLED
	else if (value == RANDOM_DISABLED)
		preferences.randomise -= requested_preference_key
	else
		return FALSE

	return TRUE

/// Returns if a preference should be randomized.
/datum/preferences/proc/should_randomize(datum/preference/preference, is_antag)
	if (!preference.is_randomizable())
		return FALSE

	var/requested_randomization = randomise[preference.savefile_key]

	if (istype(preference, /datum/preference/name))
		requested_randomization = read_preference(/datum/preference/choiced/random_name)

	switch (requested_randomization)
		if (RANDOM_ENABLED)
			return TRUE
		if (RANDOM_ANTAG_ONLY)
			return is_antag
		else
			return FALSE

/// Given randomization flags, will return whether or not this preference should be randomized.
/datum/preference/proc/included_in_randomization_flags(randomize_flags)
	return TRUE

/datum/preference/name/included_in_randomization_flags(randomize_flags)
	return !!(randomize_flags & RANDOMIZE_NAME)

/datum/preference/choiced/species/included_in_randomization_flags(randomize_flags)
	return !!(randomize_flags & RANDOMIZE_SPECIES)
