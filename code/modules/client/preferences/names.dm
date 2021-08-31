/// A preference for a name. Used not just for normal names, but also for clown names, etc.
/datum/preference/name
	category = "names"
	savefile_identifier = PREFERENCE_CHARACTER
	abstract_type = /datum/preference/name

	/// The display name when showing on the "other names" panel
	var/explanation

	/// These will be grouped together on the preferences menu
	var/group

/datum/preference/name/apply_to_human(mob/living/carbon/human/target, value)
	target.real_name = value
	target.name = value

/datum/preference/name/deserialize(input)
	return reject_bad_name(input) || create_default_value()

/datum/preference/name/serialize(input)
	// `is_valid` should always be run before `serialize`, so it should not
	// be possible for this to return `null`.
	return reject_bad_name(input)

/datum/preference/name/is_valid(value)
	return !isnull(reject_bad_name(value))

// MOTHBLOCKS TODO: constant data
/datum/preference/name/compile_ui_data(mob/user, value)
	return list(
		"explanation" = explanation,
		"group" = group,
		"value" = value,
	)

/// A character's real name
/datum/preference/name/real_name
	explanation = "Name"
	savefile_key = "real_name"
	priority = PREFERENCE_PRIORITY_NAMES

/datum/preference/name/real_name/create_informed_default_value(datum/preferences/preferences)
	var/species_type = preferences.read_preference(/datum/preference/choiced/species)
	var/gender = preferences.read_preference(/datum/preference/choiced/gender)

	var/datum/species/species = new species_type

	return species.random_name(gender, unique = TRUE)
