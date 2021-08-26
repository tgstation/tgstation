/// Determines what accessories your ghost will look like they have.
/datum/preference/choiced/ghost_accessories
	savefile_key = "ghost_accs"
	savefile_identifier = PREFERENCE_PLAYER
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES

/datum/preference/choiced/ghost_accessories/init_possible_values()
	return list(GHOST_ACCS_NONE, GHOST_ACCS_DIR, GHOST_ACCS_FULL)

/datum/preference/choiced/ghost_accessories/create_default_value()
	return GHOST_ACCS_DEFAULT_OPTION

/datum/preference/choiced/ghost_accessories/apply_to_client(client/client, value)
	var/mob/dead/observer/ghost = client.mob
	if (!istype(ghost))
		return

	ghost.ghost_accs = value
	ghost.update_appearance()

// MOTHBLOCKS TODO: THIS MAKES NO FUCKING SENSE.
// WHAT IS DESERIALIZE? WHAT IS SERIALIZE?
// ARE THEY REVERSED? ARE THEY JUST CALLED IN STUPID PLACES?
// ANSWER ME!!!
/datum/preference/choiced/ghost_accessories/serialize(input)
	var/value = isnum(input) ? input : text2num(input)

	if (!(value in get_choices()))
		return create_default_value()

	return value

/// Determines what ghosts orbiting look like to you.
// MOTHBLOCKS TODO: Support for "content unlocked" specific preferences, show in UI as disabled dropdown
/datum/preference/choiced/ghost_orbit
	savefile_key = "ghost_orbit"
	savefile_identifier = PREFERENCE_PLAYER
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES

/datum/preference/choiced/ghost_orbit/init_possible_values()
	return list(
		GHOST_ORBIT_CIRCLE,
		GHOST_ORBIT_TRIANGLE,
		GHOST_ORBIT_SQUARE,
		GHOST_ORBIT_HEXAGON,
		GHOST_ORBIT_PENTAGON,
	)

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

// MOTHBLOCKS TODO: FUCK THIS SERIALIZE
/datum/preference/choiced/ghost_others/serialize(input)
	var/value = isnum(input) ? input : text2num(input)

	if (!(value in get_choices()))
		return create_default_value()

	return value

/datum/preference/choiced/ghost_others/init_possible_values()
	return list(
		GHOST_OTHERS_SIMPLE,
		GHOST_OTHERS_DEFAULT_SPRITE,
		GHOST_OTHERS_THEIR_SETTING,
	)

/datum/preference/choiced/ghost_others/create_default_value()
	return GHOST_OTHERS_DEFAULT_OPTION

/datum/preference/choiced/ghost_others/apply_to_client(client/client, value)
	var/mob/dead/observer/ghost = client.mob
	if (!istype(ghost))
		return

	ghost.update_sight()
