/// Middleware that handles telling the UI which name to show, and waht names
/// they have.
/datum/preference_middleware/names
	action_delegations = list(
		"randomize_name" = .proc/randomize_name,
	)

/datum/preference_middleware/names/get_constant_data()
	var/list/data = list()

	var/list/types = list()

	for (var/preference_type in GLOB.preference_entries)
		var/datum/preference/name/name_preference = GLOB.preference_entries[preference_type]
		if (!istype(name_preference))
			continue

		types[name_preference.savefile_key] = list(
			"can_randomize" = name_preference.is_randomizable(),
			"explanation" = name_preference.explanation,
			"group" = name_preference.group,
		)

	data["types"] = types

	return data

/datum/preference_middleware/names/get_ui_data(mob/user)
	var/list/data = list()

	data["name_to_use"] = get_name_to_use()

	return data

/datum/preference_middleware/names/proc/get_name_to_use()
	var/highest_priority_job = preferences.get_highest_priority_job()

	for (var/preference_type in GLOB.preference_entries)
		var/datum/preference/name/name_preference = GLOB.preference_entries[preference_type]
		if (!istype(name_preference))
			continue

		if (isnull(name_preference.relevant_job))
			continue

		if (istype(highest_priority_job, name_preference.relevant_job))
			return name_preference.savefile_key

	return "real_name"

/datum/preference_middleware/names/proc/randomize_name(list/params, mob/user)
	var/datum/preference/name/name_preference = GLOB.preference_entries_by_key[params["preference"]]
	if (!istype(name_preference))
		return FALSE

	return preferences.update_preference(name_preference, name_preference.create_random_value(preferences))
