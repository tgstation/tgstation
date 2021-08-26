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

/datum/preference/choiced/ghost_accessories/deserialize(input)
	// Old ghost preferences used to be 1/50/100.
	// Whoever did that wasted an entire day of my time trying to get those sent
	// properly, so I'm going to buck them.
	if (isnum(input))
		switch (input)
			if (1)
				input = GHOST_ACCS_NONE
			if (50)
				input = GHOST_ACCS_DIR
			if (100)
				input = GHOST_ACCS_FULL

	return ..(input)

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

/datum/preference/choiced/ghost_others/deserialize(input)
	// Old ghost preferences used to be 1/50/100.
	// Whoever did that wasted an entire day of my time trying to get those sent
	// properly, so I'm going to buck them.
	if (isnum(input))
		switch (input)
			if (1)
				input = GHOST_OTHERS_SIMPLE
			if (50)
				input = GHOST_OTHERS_DEFAULT_SPRITE
			if (100)
				input = GHOST_OTHERS_THEIR_SETTING

	return ..(input)
