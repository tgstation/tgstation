
/// The username to default to for NTNRC
/datum/preference/name/ntnrc_username
	explanation = NTRNC_USERNAME_PREF_NAME
	group = "_usernames" // Underscore puts it high up, but below `_real_names`
	savefile_key = "chat_client_username"


/datum/preference/name/ntnrc_username/create_default_value()
	return pick(GLOB.hacker_aliases)

/datum/preference/name/ntnrc_username/is_valid(value)
	return !isnull(permissive_sanitize_name(value))

/datum/preference/name/ntnrc_username/deserialize(input, datum/preferences/preferences)
	return permissive_sanitize_name(input)

/datum/preference/name/ntnrc_username/serialize(input)
	return permissive_sanitize_name(input)
