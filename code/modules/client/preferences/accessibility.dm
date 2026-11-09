/// When toggled, being flashed will show a dark screen rather than a light one.
/datum/preference/toggle/darkened_flash
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	default_value = FALSE
	savefile_key = "darkened_flash"
	savefile_identifier = PREFERENCE_PLAYER

/// When toggled, will darken the screen on screen shake
/datum/preference/toggle/screen_shake_darken
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	default_value = FALSE
	savefile_key = "screen_shake_darken"
	savefile_identifier = PREFERENCE_PLAYER

/// When toggled, removes some double-click reliant actions.
/datum/preference/toggle/remove_double_click
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	default_value = FALSE
	savefile_key = "remove_double_click"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/numeric/min_recoil_multiplier
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	maximum = 200
	minimum = 0
	savefile_key = "min_recoil_multiplier"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/numeric/min_recoil_multiplier/create_default_value()
	return 100

/// When toggled, enables staircase indicators
/datum/preference/toggle/stair_indicator
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	default_value = TRUE
	savefile_key = "stair_indicator"
	savefile_identifier = PREFERENCE_PLAYER

/datum/preference/toggle/stair_indicator/apply_to_client_updated(client/client, value)
	if(value || !isliving(client.mob)) // only hide, showing is more trouble than it's worth
		return

	var/datum/weakref/climber_ref = WEAKREF(client.mob)
	for(var/obj/structure/stairs/stair as anything in GLOB.stairs)
		stair.clear_climber_image(climber_ref)
