/// Determines the look of a ghost orbiting
// MOTHBLOCKS TODO: Support for "content unlocked" specific preferences, show in UI as disabled dropdown
/datum/preference/choiced/ghost_orbit
	savefile_key = "ghost_orbit"
	savefile_identifier = PREFERENCE_PLAYER
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES

/datum/preference/choiced/ghost_orbit/init_possible_values()
	return GLOB.ghost_orbits

/datum/preference/choiced/ghost_orbit/apply_to_client(client/client, value)
	var/mob/dead/observer/ghost = client.mob
	if (!istype(ghost))
		return

	if (!client.is_content_unlocked())
		return

	ghost.ghost_orbit = value

/// Determines how to show other ghosts
/datum/preference/choiced/ghost_others
	savefile_key = "ghost_others"
	savefile_identifier = PREFERENCE_PLAYER
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES

/datum/preference/choiced/ghost_others/serialize(input)
	var/value = isnum(input) ? input : text2num(input)

	if (!(value in GLOB.ghost_others_options))
		return create_default_value()

	return value

/datum/preference/choiced/ghost_others/init_possible_values()
	return GLOB.ghost_others_options

/datum/preference/choiced/ghost_others/create_default_value()
	return GHOST_OTHERS_THEIR_SETTING

/datum/preference/choiced/ghost_others/apply_to_client(client/client, value)
	var/mob/dead/observer/ghost = client.mob
	if (!istype(ghost))
		return

	ghost.update_sight()
