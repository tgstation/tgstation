/// A preference for a name. Used not just for normal names, but also for clown names, etc.
/datum/preference/name
	category = "names"
	abstract_type = /datum/preference/name

	/// The display name when showing on the "other names" panel
	var/explanation

/datum/preference/name/apply(mob/living/carbon/human/target, value)
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

/datum/preference/name/compile_ui_data(mob/user, value)
	return list(
		"explanation" = explanation,
		"value" = value,
	)

/// A character's real name
/datum/preference/name/real_name
	explanation = "Name"
	savefile_key = "real_name"

/datum/preference/name/real_name/create_default_value()
	// MOTHBLOCKS TODO: Use gender
	return random_unique_name()
