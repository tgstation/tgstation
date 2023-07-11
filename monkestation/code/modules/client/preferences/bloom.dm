
/// Whether or not to toggle ambient occlusion, the shadows around people
/datum/preference/toggle/bloom
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_key = "seebloom"
	savefile_identifier = PREFERENCE_PLAYER
	default_value = TRUE

/datum/preference/toggle/bloom/apply_to_client(client/client, value)
	client.mob?.update_sight()
