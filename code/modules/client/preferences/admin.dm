// MOTHBLOCKS TODO: Don't show any of these when you're not an admin.

// MOTHBLOCKS TODO: Don't show this when allow_admin_asaycolor is not enabled.
/datum/preference/color/asay_color
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "asaycolor"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/color/asay_color/apply_to_client(client/client, value)
	return

/datum/preference/color/asay_color/create_default_value()
	return DEFAULT_ASAY_COLOR

/// What outfit to equip when spawning as a briefing officer for an ERT
/datum/preference/choiced/brief_outfit
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "brief_outfit"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/choiced/brief_outfit/deserialize(input)
	var/path = text2path(input)
	if (!ispath(path, /datum/outfit))
		return create_default_value()

	return path

/datum/preference/choiced/brief_outfit/serialize(input)
	return "[input]"

/datum/preference/choiced/brief_outfit/create_default_value()
	return /datum/outfit/centcom/commander

/datum/preference/choiced/brief_outfit/init_possible_values()
	return subtypesof(/datum/outfit)

/datum/preference/choiced/brief_outfit/apply_to_client(client/client, value)
	return
